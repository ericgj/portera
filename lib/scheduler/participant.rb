
module Scheduler

  class Participant < Struct.new(:name, :email)
  
    def availables; @availables ||= []; end
              
    def available(&sched_proc)
      Builder.new(self.availables).instance_eval(&sched_proc)
      self
    end
    
    def available_for?(event, slot)
      availables.any? do |avail|
        avail.for_range(event.range).any? {|free| free.subsume?(slot)}
      end
    end
    
    class Builder
      
      def initialize(collect)
        @collect = collect
      end
      
      # Example:
      #   on [2,3,5], :from => '9:00am', :to => '9:30am', :utc_offset => '-05:00'
      #
      # Note that time is assumed to be **UTC** if not specified, _not the local offset_!
      def on(days, time={})
        @collect << Availability.new( Array(days), 
                                      time[:from], 
                                      time[:to], 
                                      time[:utc_offset] || 0
                                    )
      end
      
      # sugar for `on( [1,2,3,4,5], time)`
      def weekdays(time={})
        on( [1,2,3,4,5], time)
      end
      
      # sugar for `on( [], time)`
      def any_day(time={})
        on( [], time)
      end
      
    end
    
    # This wrapper stores the parameters for participant availability rules
    # 
    # [+days+]       array of wday numbers, or empty array for all days
    # [+from+]       start time (parseable time string)
    # [+to+]         end time (parseable time string)
    # [+utc_offset+] offset string or seconds from utc, if not specified assumes process-local offset
    #
    # An iterator is returned when you call `for_range`
    class Availability < Struct.new(:days, :from, :to, :utc_offset)
      
      def initialize(*args)
        super
        self.days ||= []
      end
      
      def for_range(range)
        apply_time_range(for_day_range(range))
      end
      
      def for_day_range(range)
        r = range.extend(Tempr::DateTimeRange)
        if self.days.empty?
          r.each_days_of_week
        else
          r.each_days_of_week(*self.days)
        end
      end
      
      private
      
      def apply_time_range(expr)
        if self.from && self.to
          expr.between_times(self.from, self.to, self.utc_offset)
        else
          expr
        end
      end
      
    end
    
  end

end