module Schools
  
  class Jianli < Base
    
    def name
      "乔布堂 简历修改"
    end
    
    
    def universities
      University.data.map { |u| u[:id] }
    end
    
    
    def edu_levels
      EduLevel.data.map { |e| e[:id] }
    end
    
    
    def resume_domains
      [10]
    end
    
  end
  
end
