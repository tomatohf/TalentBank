module Paperclip
  module Interpolations
    
    def created_year(attachment, style)
      attachment.instance.created_at.year
    end
    
    def created_month(attachment, style)
      attachment.instance.created_at.month
    end
    
    def created_mday(attachment, style)
      attachment.instance.created_at.mday
    end
    
  end
end
