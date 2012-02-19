module Scheduler

  # Event model - see README for usage
  class Event
    attr_accessor :duration, :range
    def participants; @participants ||= []; end
    
    # Define events using a block passed to the constructor, e.g.
    #     
    #     Event.new do
    #       duration 60
    #       week_of  Date.civil(2012,2,13)
    #     end
    def initialize(&proc)
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
      iterate(interval).each_with_object([]) do |slot, accum|
        avails = []
        self.participants.each do |person|
          if person.available_for?(self, slot)
            avails << person
          end
        end
        if !avails.empty? || keep_all
          accum << [ slot, avails.sort_by(&:name) ]
        end
      end
    end
    
    # sort timeslot availability by 
    # 1. most participants available
    # 2. timeslot date/time
    def best(params={})
      list = availability(params).sort do |a, b|
        comp = b[1].count <=> a[1].count
        comp.zero? ? (a[0].begin <=> b[0].begin) : comp
      end
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
  
end