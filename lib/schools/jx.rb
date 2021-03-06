module Schools
  
  class Jx < Base
    
    def name
      "上海市共青团见习计划"
    end
    
    
    def volunteer
      true
    end
    def jx
      true
    end
    
    
    def universities
      University.data.map { |u| u[:id] }
    end
    
    
    def edu_levels
      EduLevel.data.map { |e| e[:id] }
    end
    
    
    def resume_domains
      [20]
    end
    
    
    def job_districts
      super.select{ |district| district[:id] < 200 }
    end
    
    
    def intern_register_labels
      {
        :title => "青年岗位见习行动暨世博会志愿者职业发展服务申请表",
        :number => "志愿者证号",
        :intern => "见习"
      }
    end
    def use_phone_as_number
      true
    end
    
  end
  
end
