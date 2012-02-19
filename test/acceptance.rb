require File.expand_path('test_helper',File.dirname(__FILE__))

describe 'simple schedule' do

  let(:schedule) do 
    schedule = Scheduler::Event.new do 
      week_of       Date.civil(2010,11,21)
      duration      90
    end
  end
    
  let(:malcolm) do
    Scheduler::Participant.new('Malcolm Reynolds').available do
      on(1,    :from => "15:00", :to => "18:00" )
      on(3,    :from => "20:00", :to => "23:00" )
      on(5,    :from => "16:00", :to => "19:00" )
    end
  end
  
  let(:hoban) do
    Scheduler::Participant.new('Hoban Washburne').available do
      on(1,    :from => "15:00", :to => "18:00" )
      on(3,    :from => "20:00", :to => "23:00" )
      on(4,    :from => "15:00", :to => "18:30" )
    end
  end
  
  let(:jayne) do
    Scheduler::Participant.new('Jayne Cobb').available do
      weekdays(:from => "15:00", :to => "18:00" )
    end
  end
  
  let(:zoe) do
    Scheduler::Participant.new('Zoe Washburne').available do
      on([1, 2, 4], :from => "15:00", :to => "18:00" )
    end
  end
  
  let(:inara) do
    Scheduler::Participant.new('Inara Serra').available do
      on([1, 2, 4])
    end
  end
  
  before do
    schedule.participants << malcolm << hoban << jayne << zoe << inara
  end
  
  it 'should return best' do
    require 'pp'
    pp schedule.best
  end
  
end
