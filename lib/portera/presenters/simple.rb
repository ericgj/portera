require 'erubis'
require 'tilt'

module Portera

  #TODO: delegation to event; extract base class
  module Presenters
  
    class Simple
      include Enumerable
      
      attr_accessor :template, :view_path
      def template; @template ||= 'simple'; end
      def view_path
        @view_path ||=  File.expand_path('../views', File.dirname(__FILE__))
      end
      
      def initialize(e)
        self.event = e
      end
      
      def name
        event.name
      end
      
      def description
        present_event(event)
      end
      
      def best
        event.coalesced.best
      end
      
      def each
        best.each do |timeslot|
          yield present_time_range(timeslot.range),
                timeslot.participants.map {|p| present_participant(p)}
        end
      end
      
      # shortcut for typical case
      def minimum_participants(min=2)
        select { |timeslot, participants|
          participants.count >= min
        }
      end
      
      def render
        Tilt.new(Dir.glob(File.join(view_path, template + '.*')).first)
          .render(self)
      end
      
      private
      attr_accessor :event
      
      def present_event(e)
         "best times #{present_date_range(e.range)} (#{e.duration} mins)"
      end
      
      def present_date_range(r)
        if r.end - r.begin == 7
          "week of #{present_date(r.begin)}"
        else
          "between #{present_date(r.begin)} and #{present_date(r.end-1)}"
        end
      end
      
      def present_time_range(r)
        "#{present_time(r.begin)} - #{present_time(r.end)}"
      end
      
      def present_date(d)
        d.strftime("%a %-d %b")
      end
      
      def present_time(t)
        t.getutc.strftime("%l:%M%P %Z")
      end
      
      def present_participant(p)
        p.to_s
      end
      
    end
    
  end
  
end