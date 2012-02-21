module Portera

  def self.view(type, *args)
    Presenters.get(type).new(*args).render
  end
  
  module Presenters
    
    def self.get(type)
      self.const_get(type.to_s.capitalize)
    end
  
  end

end
