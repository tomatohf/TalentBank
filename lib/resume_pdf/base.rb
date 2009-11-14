require "prawn"

module ResumePdf
  
  class Base
    
    def initialize(styles = {})
      @styles = default_styles.merge(styles)
    end
    
    def render(resume, filename)
      pdf = self.draw(resume)
      filename.blank? ? pdf.render : pdf.render_file(filename)
    end
    
    def draw(resume)
      raise(NotImplementedError, "draw(resume) is not implemented")
    end
    
    
    private
    
    def default_styles
      {}
    end
    
  end
  
  
  def self.generate(resume, options = {})
    template = options[:template] || Standard
    styles = options[:styles] || {}
    filename = options[:filename]
    
    template.new(styles).render(resume, filename)
  end
  
end


Dir.glob("#{RAILS_ROOT}/lib/resume_pdf/*.rb").each do |file|
  # require_dependency "resume_pdf/#{Pathname.new(file).basename.to_s[0..-4]}" unless file == __FILE__
  require_dependency file[0..-4] unless file == __FILE__
end
