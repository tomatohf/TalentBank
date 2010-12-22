module Schools
  
  class Qiaobutang < Base
    
    def name
      "乔布堂"
    end
    
    
    def universities
      University.data.map { |u| u[:id] }
    end
    
    
    def edu_levels
      EduLevel.data.map { |e| e[:id] }
    end
    
    
    def resume_domains
      # TODO - MUST BE OVERRIDED
      [10, 110, 120, 130, 140, 150, 160, 170, 180, 200, 210, 220]
    end
    
  end
  
end
