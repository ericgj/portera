require File.expand_path('test_helper',File.dirname(__FILE__))

describe 'invalid days' do

  let(:malcolm) do
    Portera::Participant.new('Malcolm Reynolds').available do
      on(:Mon,    :from => "15:00", :to => "18:00" )
      on(:Wed,    :from => "20:00", :to => "23:00" )
      on(:Fs,    :from => "16:00", :to => "19:00" )
    end
  end
  
  let(:hoban) do
    Portera::Participant.new('Hoban Washburne').available do
      on(:monday,    :from => "15:00", :to => "18:00" )
      on(:wednesday, :from => "20:00", :to => "23:00" )
      on(7,  :from => "15:00", :to => "18:30" )
    end
  end

  let(:zoe) do
    Portera::Participant.new('Zoe Washburne').available do
      on([1, 2, -1], :from => "15:00", :to => "18:00" )
    end
  end
  
  it 'should raise ArgumentError when unknown symbol' do
    assert_raises(ArgumentError) { malcolm }
  end
  
  it 'should raise ArgumentError when day > 6' do
    assert_raises(ArgumentError) { hoban }  
  end
  
  it 'should raise ArgumentError when day < 0' do
    assert_raises(ArgumentError) { zoe }  
  end
  
end