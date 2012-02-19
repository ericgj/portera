require 'tempr'

%w[ scheduler/version
    scheduler/event
    scheduler/participant
  ].each do |f|
      require File.expand_path(f, File.dirname(__FILE__))
    end
