require "open-uri"
require "prawn"
require "prawn/layout"
require "prawn/measurement_extensions"

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
      doc
    end
    
    
    ########## util methods ##########
    
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
    
    
    ##########
    
    # custom method for adding table which is composed by cells
    # notice : content_list is a two dimensions array
    def add_table(doc, content_list, config_map = {})
      content_list.each do |line|
        next_left = config_map[:left_position] || 0
        temcursor = config_map[:top_position] || get_cursor(doc)
        line.each_index do |i|
          content = line[i]
          vertical_padding = config_map[:vertical_padding] || (config_map[:vertical_paddings] && config_map[:vertical_paddings][i])
          add_cell(doc, [next_left,temcursor],content,
                    {:width => (config_map[:width] || (config_map[:widths] && config_map[:widths][i])), :height => (config_map[:height] || (config_map[:heights] && config_map[:heights][i])),
                    :if_bg => config_map[:if_bg], :vertical_padding => vertical_padding,
                    :font => (config_map[:font_config] && config_map[:font_config][:font]) || (config_map[:font_configs] && config_map[:font_configs][i] && config_map[:font_configs][i][:font]),
                    :font_size => (config_map[:font_config] && config_map[:font_config][:font_size]) || (config_map[:font_configs] && config_map[:font_configs][i] && config_map[:font_configs][i][:font_size]),
                    :font_style => (config_map[:font_config] && config_map[:font_config][:font_style]) || (config_map[:font_configs] && config_map[:font_configs][i] && config_map[:font_configs][i][:font_style])}) do |cell|
            next_left += cell.width
            if(config_map[:align] || (config_map[:aligns] && config_map[:aligns][i]))
              cell.align = config_map[:align] || (config_map[:aligns] && config_map[:aligns][i])
            end
          end
        end
      end
    end
    
    # if set width and height to nil they will be automatically expanded,
    # but remember dont set to 0
    def add_cell(doc, point, text_str, config_map ={}, &block)
     doc.font config_map[:font],:style => config_map[:font_style]  if config_map[:font]
     doc.font_size config_map[:font_size] if config_map[:font_size]
     border_width = config_map[:border_width] || 0
     vertical_padding = config_map[:vertical_padding]
     cell = Prawn::Table::Cell.new(:point => point,:document => doc,:width => config_map[:width],:height => config_map[:height],:text => text_str,:vertical_padding => vertical_padding,:border_width => border_width)
     cell.background_color = config_map[:bg_color] || "EEEEEE" if config_map[:if_bg]
     cell.align = config_map[:align] if config_map[:align]
     block.call(cell) if block_given?
     cell.draw
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
