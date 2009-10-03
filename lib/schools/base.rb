module Schools
  
  def self.get_school(school_abbr)
    "#{self.name}::#{school_abbr.to_s.camelize}".constantize.instance
  end
  
  
  class Base
    include Singleton
    
    
    def abbr
      self.class.name.demodulize.underscore
    end
    
    
    def page_title(sub_title)
      "#{sub_title} - 人才库 - 乔布堂"
    end
    
    
    def logo
      # must be implemented in subclass
    end
    
    def logo_title
      ""
    end
    
    
  end
  

  Dir.glob("#{RAILS_ROOT}/lib/schools/*.rb").each do |file|
    # require_dependency "schools/#{Pathname.new(file).basename.to_s[0..-4]}" unless file == __FILE__
    require_dependency file[0..-4] unless file == __FILE__
  end

end
