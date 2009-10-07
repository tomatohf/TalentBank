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
    
    
    def edu_levels
      [30, 20, 40]
    end
    
    
    def resume_domains
      [ResumeDomain.general_version_id, 110, 120]
    end
    
  end
  
end
