require "open-uri"
require "prawn"
require "prawn/layout"
require "prawn/measurement_extensions"
require "prawn/format"

module PdfExport
  
  class Base
    
    def initialize(styles = {})
      @styles = default_styles.merge(styles)
    end
    
    def render(model, filename)
      pdf = draw(model)
      filename.blank? ? pdf.render : pdf.render_file(filename)
    end
    
    def draw(model)
      raise(NotImplementedError, "draw(model) is not implemented")
    end
    
    
    private
    
    def default_styles
      {
        :page_size => "A4", # 595.28 x 841.89
        :page_layout => :portrait,
        # :margin => [], # can use css-style value as array
        
        :Producer => "乔布堂",
        :CreationDate => Time.now,
        
        :Creator => "乔布堂 人才库",
        :Title => "",
        :Author => "乔布堂",
        
        :fonts => {
          :zh => {
            :normal => "#{RAILS_ROOT}/lib/pdf_export/simsun.ttf",
            :bold   => "#{RAILS_ROOT}/lib/pdf_export/simhei.ttf"
          }
        },
        
        :font_size_content => 10
      }
    end
    
    def init_document
      doc = Prawn::Document.new(
        :page_size => @styles[:page_size],
        :page_layout => @styles[:page_layout],
        :info => {
          :Producer => @styles[:Producer],
          :CreationDate => @styles[:CreationDate],
          :Subject => @styles[:Subject],
          :Creator => @styles[:Creator],
          :Title => @styles[:Title],
          :Author => @styles[:Author]
        },
        :text_options => {
          :wrap => :character
        }
      )
      
      doc.font_families.update(@styles[:fonts])
      doc.font(:zh, :size => @styles[:font_size_content])
      
      doc
    end
    
    
    ########## util methods ##########
    
    HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }
    def html_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
    alias h html_escape
    
    
    def lines(text, remove_empty = true)
      Utils.lines(text, remove_empty)
    end
    
    
    def safe_image(doc, image, options)
      begin
        doc.image(image, options)
      rescue StandardError
        false
      end
    end
    
    
    def zh_text(doc, text, options = {})
      doc.font(:zh)
      doc.text(
        text,
        {
          :size => @styles[:font_size_content],
          :style => :normal
        }.merge(options)
      )
    end
    
    
    # get current y axis position,
    # it's recommended to get doc.cursor by this method to control paganition
    def get_cursor(doc)
      doc.start_new_page if doc.cursor < 0
      doc.cursor
    end
    
    
    def move_down(doc, n)
      doc.move_down(n)
    end
    
  end
  
  
  def self.generate(model, options = {})
    (
      options[:template] || self.const_get("#{model.class.name}Standard")
    ).new(options[:styles] || {}).render(model, options[:filename])
  end
  
end


Dir.glob("#{RAILS_ROOT}/lib/pdf_export/*.rb").each do |file|
  # require_dependency "pdf_export/#{Pathname.new(file).basename.to_s[0..-4]}" unless file == __FILE__
  require_dependency file[0..-4] unless file == __FILE__
end
