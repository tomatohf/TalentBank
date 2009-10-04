module Schools
  
  class Qiaobutang < Base
    
    def name
      "乔布堂学院"
    end
    
    def page_title(sub_title)
      sub_title += " - " if sub_title && sub_title != ""
      "#{sub_title}人才库_#{self.name}"
    end
    
    
    def logo
      "/images/school/qiaobutang_logo.png"
    end
    
    def logo_title
      "#{self.name} 人才库"
    end
    
  end
  
end
