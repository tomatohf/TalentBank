module SkillValueTypes
  
  def self.get_type(value_type)
    "#{self.name}::#{value_type.camelize}".constantize.instance
  end
  
  
  class Base
    include Singleton
    
    
    def default_value
      0
    end
    
    
    def render_input(data, value, element_id)
      ""
    end
    
    
    def render_label(data, value)
      ""
    end
    
    
  end
  

  Dir.glob("#{RAILS_ROOT}/lib/skill_value_types/*.rb").each do |file|
    # require_dependency "skill_value_types/#{Pathname.new(file).basename.to_s[0..-4]}" unless file == __FILE__
    require_dependency file[0..-4] unless file == __FILE__
  end

end
