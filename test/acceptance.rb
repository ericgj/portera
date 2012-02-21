require File.expand_path('test_helper',File.dirname(__FILE__))

describe 'simple schedule' do

  let(:schedule) do 
    schedule = Portera::Event.new("Meeting on Frobartz project") do 
      week_of       Date.civil(2010,11,21)
      duration      90
    end
  end
    
  let(:malcolm) do
    Portera::Participant.new('Malcolm Reynolds').available do
      on(:Mon,    :from => "15:00", :to => "18:00" )
      on(:Wed,    :from => "20:00", :to => "23:00" )
      on(:Fri,    :from => "16:00", :to => "19:00" )
    end
  end
  
  let(:hoban) do
    Portera::Participant.new('Hoban Washburne').available do
      on(:monday,    :from => "15:00", :to => "18:00" )
      on(:wednesday, :from => "20:00", :to => "23:00" )
      on(:thursday,  :from => "15:00", :to => "18:30" )
    end
  end
  
  let(:jayne) do
    Portera::Participant.new('Jayne Cobb').available do
      weekdays(:from => "15:00", :to => "18:00" )
    end
  end
  
  let(:zoe) do
    Portera::Participant.new('Zoe Washburne').available do
      on([1, 2, 4], :from => "15:00", :to => "18:00" )
    end
  end
  
  let(:inara) do
    Portera::Participant.new('Inara Serra').available do
      on([:Monday, :tue, :Thu])
    end
  end
  
  before do
    schedule.participants << malcolm << hoban << jayne << zoe << inara
  end
  
  it 'should return best timeslots' do
    puts
    puts schedule.availability.best
  end
  
  it 'should return best with coalesced timeslots' do
    puts
    puts schedule.coalesced.best
  end
  
  it 'should display simple report' do
    puts
    puts Portera::Presenters::Simple.new(schedule).render
  end
  
end
