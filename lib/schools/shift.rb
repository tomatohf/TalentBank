module Schools
  
  class Shift < Base
    
    def name
      "上海对外贸易学院"
    end
    
    def page_title(sub_title)
      sub_title += " - " if sub_title && sub_title != ""
      "#{sub_title}人才库_#{self.name}"
    end
    
    
    def logo
      "/images/school/shift_logo.jpg"
    end
    
    def logo_title
      "#{self.name} 人才库"
    end
    
    
    def edu_levels
      [100300]
    end
    
  end
  
end
