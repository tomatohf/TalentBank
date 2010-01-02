module ReviseResumesHelper

  def revision_diff_with(revision_action, part_type, part_id)
    if revision_action == "add"
      model_class = part_type[:add_as] || part_type[:model]
      model_class && model_class.new
    else
      part_type[:model] && part_type[:model].try_find(part_id)
    end
  end
  
  
  def diff_content_list(target, source)
    # Differ.diff_by_line(target, source).format_as(Differ::Format::HTMLList)
		
		Differ.diff_by_char(
		  compact_newline(target),
		  compact_newline(source)
		).format_as(Differ::Format::HTMLList)
  end
  
  
  def compact_newline(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n+/, "\n")
  end
  
  
  def skill_name_and_level(resume_skill)
    return [] unless resume_skill
    
    if resume_skill.respond_to?(:name) && resume_skill.respond_to?(:level)
      [resume_skill.name, resume_skill.level]
    else
      skill = Skill.find(resume_skill.skill_id)
      [
        skill[:name],
        SkillValueTypes.get_type(skill[:value_type]).render_label(skill[:data], resume_skill.value)
      ]
    end
  end
  
end
