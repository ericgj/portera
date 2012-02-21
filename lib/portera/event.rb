require 'set'

module Portera

  # Event model - see README for usage
  class Event
    attr_accessor :name, :duration, :range
    def participants; @participants ||= []; end
    
    # Define events using a block passed to the constructor, e.g.
    #     
    #     Event.new do
    #       duration 60
    #       week_of  Date.civil(2012,2,13)
    #     end
    def initialize(name=nil,&proc)
      self.name = name
      Builder.new(self).instance_eval(&proc)
    end
    
    # iterate over each timeslot in range (week),
    # gathering participant availability for each slot
    # parameters:
    #    [+interval+]:  duration of timeslots in minutes (default 15)
    #    [+all+]:       return all timeslots even if no participants available (default false)
    def availability(params={})
      interval = params.fetch(:interval,15)
      keep_all = params.fetch(:all,false)
      iterate(interval).each_with_object(TimeslotEnum.new) do |slot, accum|
        avails = []
        self.participants.each do |person|
          if person.available_for?(self, slot)
            avails << person
          end
        end
        if !avails.empty? || keep_all
          accum << Timeslot.new(slot, ::Set.new(avails.sort_by(&:name)))
        end
      end
    end
    
    def coalesced(params={})
      availability(params).coalesced
    end
    
    private
    
    def iterate(i)
      self.range.dup.extend(Tempr::DateTimeRange).each_minute(i,0,self.duration)
    end
    
    # Internal builder class for events
    class Builder

      def initialize(event)
        @event = event
      end

      # duration in minutes of the proposed event
      def duration(minutes)
        @event.duration = minutes
      end

      # range of possible dates for the proposed event
      # for a weekly event, use `week_of` instead of explicit date range
      def range(dates)
        @event.range = dates
      end
      
      # first date of week for the proposed event
      def week_of(date)
        range date...(date+7)
      end

    end

  end
  
  class Timeslot < Struct.new(:range, :participants)
  
    # temporary, TODO use views/presenters instead
    def to_s
      ["#{self.range}",
       self.participants.empty? ? nil : " #{self.participants.to_a.join("\n ")}"
      ].compact.join("\n")
    end
    
  end
  
  class TimeslotEnum
    include Enumerable
    
    def <<(timeslot)
      timeslots << timeslot
      self
    end
    
    def each(&b)
      timeslots.each(&b)
    end
        
    # join intersecting timeslots with identical participants
    # note that this returns a new TimeslotEnum, so that you can call
    #  [+enum.best+]            all timeslots sorted by highest participation
    #  [+enum.coalesced.best+]  joined timeslots sorted by highest participation
    #
    # Note assumes timeslots are appended in ascending order by range.begin
    # TODO could use some refactoring
    def coalesced
      accum = self.class.new
      inject(nil) do |last_slot, this_slot|
        if last_slot
          rng       = this_slot.range
          last_rng  = last_slot.range
          if (rng.intersects?(last_rng) || rng.succeeds?(last_rng)) &&
             (this_slot.participants ==  last_slot.participants)
            Timeslot.new(last_rng.begin...rng.end, 
                         this_slot.participants)
          else
            accum << last_slot
            this_slot
          end
        else
          this_slot
        end
      end
      accum
    end

    # sort timeslot availability by 
    # 1. most participants available
    # 2. timeslot date/time
    def best
      sort do |a, b|
        comp = b.participants.count <=> a.participants.count
        comp.zero? ? (a.range.begin <=> b.range.begin) : comp
      end
    end
    
    private
    def timeslots; @timeslots ||= []; end
    
  end
    
end