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
      when :edu_level_id
        "level"
      when :graduation_year
        "graduation"
      else
        group_by.to_s.gsub(/_id$/, "")
    end
  end
  
end
