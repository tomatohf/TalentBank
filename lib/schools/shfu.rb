module Schools
  
  class Shfu < Base
    
    def name
      "上海海洋大学"
    end
    
    
    def edu_levels
      # TODO - MUST BE OVERRIDED
      [30]
    end
    
    
    def resume_domains
      # TODO - MUST BE OVERRIDED
      [10, 110, 120]
    end
    
    
    def all_graduation_years
      # TODO - MUST BE OVERRIDED
      super
    end
    
  end
  
end