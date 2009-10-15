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
    
    
    def render_label(data, value)
      value ||= default_value
      
      record = select_one(data, :value, value)
      record && record[:label]
    end
    
    
    private
    
    def select_one(array, field, value)
      (array || []).each do |record|
        return record if record[field] == value
      end
      
      # NOT found
      nil
    end
    
  end
  
end
