module TeacherStatisticsHelper
  
  Pie_Chart_Colors = [
    "#058DC7", "#50B432", "#ED561B", "#EDEF00", "#24CBE5",
    "#64E572", "#FF9655", "#FFF263", "#6AF9C4", "#B2DEFF"
  ]

  def get_pie_chart_color(index)
    index < Pie_Chart_Colors.size ? Pie_Chart_Colors[index] : "#BBBBBB"
  end
  
  
  def get_compared_to(from, to , compared_from)
    compared_from + (to - from)
  end
  
  
  def get_group_by_field(group_by)
    case group_by
      when :corporation_id
        "corp"
      when :exp_tag_id
        "tag"
      when :edu_level_id
        "level"
      when :graduation_year
        "graduation"
      else
        group_by.to_s.gsub(/_id$/, "")
    end
  end
  
  
  def render_filters(filter_infos)
    filter_infos.collect { |filter_info|
      filter_html = %Q!
        <a href="#" class="none" title="过滤#{filter_info[1]}" id="#{filter_info[0]}_filter_link">
          #{filter_info[1]}</a>
      !
			
      record = self.instance_variable_get("@#{filter_info[0]}")
      unless record.blank?
        record_name = if record.kind_of?(Integer)
          record
        elsif record.respond_to?(:name)
          if record.respond_to?(:uid)
						h(record.get_name)
					else
						h(record.name)
					end
				else
					record[:name]
				end
				filter_html += %Q!
					<span title="#{record_name}" style="color: #333333; margin-right: 1px;">
						:
						#{truncate(record_name, :length => 20)}
					</span>
					<a href="#" title="清除过滤" id="remove_#{filter_info[0]}_filter_link">
						<img alt="清除" src="/images/teachers/delete_icon.gif" border="0" /></a>
				!
			end
			
			filter_html
		}.join(
			%Q!
				<span class="info" style="margin: 0px 2px;">|</span>
			!
		)
  end
  
end
