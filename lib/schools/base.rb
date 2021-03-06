module Schools
  
  def self.get_school(school_abbr)
    "#{self.name}::#{school_abbr.to_s.camelize}".constantize.instance
  end
  
  
  module Helpers
    
    def coming_graduation_year
      today = Date.today
      (today.month > 8) ? (today.year + 1) : today.year
    end
    
  end
  
  
  class Base
    include Singleton
    include Helpers
    
    
    def abbr
      self.class.name.demodulize.underscore
    end
    
    
    def name
      raise "Not Implemented"
    end
    
    def page_title(sub_title)
      sub_title << " - " unless sub_title.blank?
      %Q!#{sub_title}人才库_#{self.name}!
    end
    
    def logo_title
      "#{self.name} 人才库"
    end
    
    
    def universities
      []
    end
    
    
    def edu_levels
      []
    end
    
    
    def resume_domains
      []
    end
    
    
    def graduation_years
      year = self.coming_graduation_year
      ((year - 4)..(year + 4)).to_a
    end
    
    
    def job_districts
      JobDistrict.data
    end
    
    
    def intern_register_labels
      {
        :title => "实习岗位申请表",
        :number => "学号",
        :intern => "实习"
      }
    end
    def use_phone_as_number
      false
    end
    
  end

end


Dir.glob("#{RAILS_ROOT}/lib/schools/*.rb").each do |file|
  # require_dependency "schools/#{Pathname.new(file).basename.to_s[0..-4]}" unless file == __FILE__
  require_dependency file[0..-4] unless file == __FILE__
end
