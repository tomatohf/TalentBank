module ResumePdf
  
  class Standard < Base
    
    def draw(resume)
      pdf = Prawn::Document.new(
        :page_size => @styles[:page_size],
        :page_layout => @styles[:page_layout],
        :info => {
          :Producer => @styles[:Producer],
          :CreationDate => @styles[:CreationDate],
          :Subject => @styles[:Subject],
          :Creator => @styles[:Creator],
          :Title => @styles[:Title],
          :Author => @styles[:Author]
        }
      )
      pdf.font_families.update(@styles[:fonts])
      
      pdf.font(:zh)
      pdf.text("导出 PDF 成功")
      pdf
    end
    
    
    private
    
    def default_styles
      {
        :page_size => "A4", # 595.28 x 841.89
        :page_layout => :portrait,
        # :margin => [], # can use css-style value as array
        
        :Producer => "乔布堂",
        :CreationDate => Time.now,
        :Subject => "简历",
        
        :Creator => "乔布堂 人才库",
        :Title => "",
        :Author => "乔布堂",
        
        :fonts => {
          :zh => {
            :normal => "#{RAILS_ROOT}/lib/resume_pdf/fonts/Arial Unicode.ttf",
            :bold   => "#{RAILS_ROOT}/lib/resume_pdf/fonts/Arial Unicode.ttf"
          }
        }
      }
    end
    
  end
  
end