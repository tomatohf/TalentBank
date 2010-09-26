module Schools
  
  class Jx < Base
    
    def name
      "上海市共青团见习计划"
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
