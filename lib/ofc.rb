module OpenFlashChartHelpers
  
  def ofc_chart_data(options = {})
    {
      # :title => {
      #   :text => "",
      #   :style => {
      #     "font-size" => "20px",
      #     :color => "#0000FF",
      #     "font-family" => "Verdana",
      #     "text-align" => "center"
      #   }
      # },

      :bg_colour => options.delete(:bg_colour) || "#FFFFFF",

      :tooltip => {
        :shadow => true,
        :rounded => 15,
        :stroke => 2,
        :colour => "#555555",
        :background => "#FEFEFE",
        # :title => "{font-size:12px;}",
        # :body => "{font-size:12px;}"
      }.merge(options.delete(:tooltip) || {}),

      :num_decimals => options.delete(:num_decimals) || 0,
      :is_fixed_num_decimals_forced => (fndf = options.delete(:is_fixed_num_decimals_forced)).nil? ? true : fndf,
      :is_decimal_separator_comma => (dsc = options.delete(:is_decimal_separator_comma)).nil? ? false : dsc,
      :is_thousand_separator_disabled => (tsd = options.delete(:is_thousand_separator_disabled)).nil? ? false : tsd,

      :x_axis => {
        :stroke => 2,
        "tick-height" => 5,
        :colour => "#878787",
        "grid-colour" => "#D2D2D2",
        :steps => 1,
        :labels => {
          :labels => [],
          :steps => 1,
          "visible-steps" => 2,
          :colour => "#333333",
          :size => 10
        }.merge((options[:x_axis] && options[:x_axis].delete(:labels)) || {})
      }.merge(options.delete(:x_axis) || {}),

      :y_axis => {
        :stroke => 2,
        "tick-length" => 5,
        :colour => "#7F7F7F",
        "grid-colour" => "#D2D2D2",
        :labels => {
          :text => "#val#",
          :colour => "#333333",
          :size => 10
        }.merge((options[:y_axis] && options[:y_axis].delete(:labels)) || {}),
        :min => 0,
        :max => 1000,
        :steps => 100
      }.merge(options.delete(:y_axis) || {}),

      :elements => (options.delete(:elements) || []).collect { |element|
        if ["line", "area"].include?(element[:type])
          line_element(element)
        else
          element
        end
      }
    }
  end
  
  
  private
  
  def line_element(element)
    {
		  :type => "line",
		  :colour => "#666666",
		  :width => 3,
		  :text => "",
		  "font-size" => 12,
		  "dot-style" => {
		    :type => "solid-dot",
		    "dot-size" => 4,
		    "halo-size" => 1,
		    :colour => "#666666",
		    "on-click" => "//line_click(x_index)"
		  }.merge(element.delete("dot-style") || {}),
		  :values => [
		    {
	        :value => 500,
	        :tip => "500"
	      }
	    ]
		}.merge(element || {})
  end
  
end
