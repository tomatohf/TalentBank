module Schools
  
  def self.get_school(school_abbr)
    "#{self.name}::#{school_abbr.to_s.camelize}".constantize.instance
  end
  
  
  class Base
    include Singleton
    
    
    def logo
      ""
    end
    
    
  end
  

  Dir.glob("#{RAILS_ROOT}/lib/schools/*.rb").each do |file|
    require_dependency "schools/#{file[0..-4]}" unless file == __FILE__
  end

end
