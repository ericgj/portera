require 'tempr'

%w[ portera/version
    portera/event
    portera/participant
    portera/presenters
  ].each do |f|
      require File.expand_path(f, File.dirname(__FILE__))
    end

Dir[File.expand_path('portera/presenters/*', File.dirname(__FILE__))].each do |f|
  require f
end