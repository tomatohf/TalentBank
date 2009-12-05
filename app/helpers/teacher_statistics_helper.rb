module TeacherStatisticsHelper
  
  Pie_Chart_Colors = [
    "#058DC7", "#50B432", "#ED561B", "#EDEF00", "#24CBE5",
    "#64E572", "#FF9655", "#FFF263", "#6AF9C4", "#B2DEFF"
  ]

  def get_pie_chart_color(index)
    index < Pie_Chart_Colors.size ? Pie_Chart_Colors[index] : "#BBBBBB"
  end
  
end
