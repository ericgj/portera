require File.expand_path('test_helper',File.dirname(__FILE__))

module CoalescedTests

  module Helpers
  
    def new_participants
      ('A'..'Z').map {|name| Portera::Participant.new(name) }
    end
    
    def participant_set(partic, indexes)
      indexes = Array(indexes)
      ::Set.new( indexes.map {|i| partic[i]} )
    end
    
    def new_timeslot(range, partic)
      range.extend(Tempr::DateTimeRange)
      Portera::Timeslot.new( range , partic )
    end
    
    def assert_timeslot(exp_range, exp_partic, act)
      assert  exp_range  == act.range &&
              exp_partic == act.participants,
              "Timeslot expected to be for range #{exp_range} "+
              "with participants #{exp_partic.to_a}, instead was " +
              "#{act}"
    end
    
  end
  
  describe 'coalescing' do
    include Helpers
    
    before do
      @subject = Portera::TimeslotEnum.new
      @all_partic = new_participants
      
      [ new_timeslot(
          (  Time.utc(2012,01,02,03,00,00)...
             Time.utc(2012,01,02,03,30,00)),
          participant_set(@all_partic, (0..5))
        ),
        new_timeslot(                             # coalesce
          (  Time.utc(2012,01,02,03,15,00)...
             Time.utc(2012,01,02,03,45,00)),
          participant_set(@all_partic, (0..5))
        ),        
        new_timeslot(                             # coalesce
          (  Time.utc(2012,01,02,03,44,59)...
             Time.utc(2012,01,02,04,00,00)),
          participant_set(@all_partic, (0..5))
        ),
        new_timeslot(                             # not coalesce
          (  Time.utc(2012,01,02,03,45,00)...
             Time.utc(2012,01,02,04,00,00)),
          participant_set(@all_partic, (4..9))
        ),
        new_timeslot(                             # not coalesce
          (  Time.utc(2012,01,02,03,45,00)...
             Time.utc(2012,01,02,04,00,00)),
          participant_set(@all_partic, (10..15))
        ),
        new_timeslot(                             # coalesce
          (  Time.utc(2012,01,02,04,00,00)...
             Time.utc(2012,01,02,04,15,00)),
          participant_set(@all_partic, (10..15))
        ),
        new_timeslot(                             # coalesce
          (  Time.utc(2012,01,02,04,15,00)...
             Time.utc(2012,01,02,04,30,00)),
          participant_set(@all_partic, (10..15))
        ),        
        new_timeslot(                             # not coalesce
          (  Time.utc(2012,01,02,04,30,00)...
             Time.utc(2012,01,02,05,00,00)),
          participant_set(@all_partic, (15..16))
        ),
        new_timeslot(                             # not coalesce
          (  Time.utc(2012,01,02,05,30,00)...
             Time.utc(2012,01,02,06,00,00)),
          participant_set(@all_partic, (15..16))
        ),
        new_timeslot(                             # not coalesce
          (  Time.utc(2012,01,02,06,30,00)...
             Time.utc(2012,01,02,07,00,00)),
          participant_set(@all_partic, (16..17))
        ),        
      ].each do |slot|
        @subject << slot
      end
      
    end
    
    it 'should have the correct number of coalesced timeslots' do
      actual = @subject.coalesced.to_a
      puts actual
      assert_equal 6, actual.count
    end
    
    it 'should coalesce overlapping ranges with same participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,03,00,00)...
                         Time.utc(2012,01,02,04,00,00)),
                       participant_set(@all_partic, (0..5)),
                       actual[0]
    end
    
    it 'should not coalesce overlapping ranges with different participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,03,45,00)...
                         Time.utc(2012,01,02,04,00,00)),
                       participant_set(@all_partic, (4..9)),
                       actual[1]
    end

    it 'should coalesce adjacent ranges with same participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,03,45,00)...
                         Time.utc(2012,01,02,04,30,00)),
                       participant_set(@all_partic, (10..15)),
                       actual[2]
    end

    it 'should not coalesce adjacent ranges with different participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,04,30,00)...
                         Time.utc(2012,01,02,05,00,00)),
                       participant_set(@all_partic, (15..16)),
                       actual[3]    
    end

    it 'should not coalesce non-overlapping non-adjacent ranges with same participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,05,30,00)...
                         Time.utc(2012,01,02,06,00,00)),
                       participant_set(@all_partic, (15..16)),
                       actual[4]    
    end

    it 'should not coalesce non-overlapping non-adjacent ranges with different participants' do
      actual = @subject.coalesced.to_a
      assert_timeslot (  Time.utc(2012,01,02,06,30,00)...
                         Time.utc(2012,01,02,07,00,00)),
                       participant_set(@all_partic, (16..17)),
                       actual[5]    
    end
    
  end

  
end