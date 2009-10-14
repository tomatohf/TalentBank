module SkillValueTypes
  
  class Level < Base
    
    def render_input(data, value, element_id)
      value ||= default_value
      
      html = ""
      html << %Q!<select name="#{element_id}" id="#{element_id}" class="dropdown_list">!      
      data.each do |level|
        html << %Q!<option value="#{level[:value]}"!
        html << %Q! selected="selected"! if level[:value] == value
        html << %Q!>#{level[:label]}</option>!
      end
      html << %Q!</select>!
      html
    end
    
  end
  
end
