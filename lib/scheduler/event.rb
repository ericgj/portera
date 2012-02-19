module Scheduler

  class Event
    attr_accessor :duration, :range
    def participants; @participants ||= []; end
    
    def initialize(&proc)
      Builder.new(new).instance_eval(&proc)
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
        range date..date+7
      end

    end

  end
  
end