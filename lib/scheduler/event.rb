module Scheduler

  class Event
    attr_accessor :duration, :range
    def participants; @participants ||= []; end
    
    def initialize(&proc)
      Builder.new(self).instance_eval(&proc)
    end
    
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
    
    def best(params={}, &selector)
      list = availability(params).sort do |a, b|
        comp = b[1].count <=> a[1].count
        comp.zero? ? (a[0].begin <=> b[0].begin) : comp
      end
      if block_given?
        list.select(&selector)
      else
        list
      end
    end
    
    private
    
    def iterate(i)
      self.range.dup.extend(Tempr::DateTimeRange).each_minute(i,0,self.duration)
    end
    
    class Builder

      def initialize(event)
        @event = event
      end

      # duration in minutes of the proposed event
      def duration(minutes)
        @event.duration = minutes
      end

      # range of possible dates/times for the proposed event
      def range(dates)
        @event.range = dates
      end
      
      # week of proposed meeting
      def week_of(date)
        range date...(date+7)
      end

    end

  end
  
end