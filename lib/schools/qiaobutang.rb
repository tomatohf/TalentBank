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
      ResumeDomain.data.map { |rd| rd[:id] }
    end
    
  end
  
end
