# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def format_datetime(datetime)
    datetime && datetime.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def format_date(date)
    date && date.strftime("%Y-%m-%d")
  end
  
  def format_time(date)
    date && date.strftime("%H:%M:%S")
  end
  
  
  def paging_buttons(collection, params = {})
    will_paginate(
      collection,
      :previous_label => "« 上一页",
      :next_label => "下一页 »",
      :param_name => :page, # parameter name for page number in URLs (default: :page)
      :page_links => true, # when false, only previous/next links are rendered (default: true) 
      # :separator => "", # string separator for page HTML elements (default: single space)
      # :inner_window => 4, # how many links are shown around the current page (default: 4)
      # :outer_window => 1, # how many links are around the first and the last page (default: 1)
      :class => "pagination", # CSS class name for the generated DIV (default: "pagination")
      :params => params # additional parameters when generating pagination links (eg. :controller => "foo", :action => nil)
    )
  end
  
  
  def render_school_view(template, school_abbr)
    school_abbr = ::DEFAULT_SCHOOL_VIEW unless File.exist?("#{RAILS_ROOT}/app/views#{template}/_#{school_abbr}.html.erb")
    render(:partial => "#{template}/#{school_abbr}")
  end
  
  
  def talent_page_title(page_title)
    content_for(:page_title) { page_title }
  end
  
  
  def list_model_validate_errors(model)
    errors = ""
    model.errors.each do |attr, error|
      errors += "#{error}<br />"
    end
    errors
  end
  
  
  def required_mark(bracket = true)
    %Q!
      #{"(" if bracket}<font color="red">*</font>#{")" if bracket}
    !
  end
  
  
  def a(text)
    # remove single quotes, so that it can be used in html attribute safely
    text.gsub("'", "")
  end
  
  
  def chart_data
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
      
      :bg_colour => "#FFFFFF",
      
      :tooltip => {
        :shadow => true,
        :rounded => 15,
        :stroke => 2,
        :colour => "#555555",
        :background => "#FEFEFE",
        :title => "{font-size:12px;color:#0077CC;}",
        :body => "{font-size:12px;color:#333333;}"
      },
      
      :num_decimals => 0,
      :is_fixed_num_decimals_forced => true,
      :is_decimal_separator_comma => false,
      :is_thousand_separator_disabled => false,
      
      :x_axis => {
        :stroke => 2,
        "tick-height" => 5,
        :colour => "#878787",
        "grid-colour" => "#D2D2D2",
        :steps => 1,
        :labels => {
          :labels => ["2009-01-02","2009-01-03","2009-01-04","2009-01-05","2009-01-06","2009-01-07","2009-01-08","2009-01-09","2009-01-10"],
          :steps => 1,
          "visible-steps" => 2,
          :colour => "#333333",
          :size => 10
        }
      },
      
      :y_axis => {
        :stroke => 2,
        "tick-length" => 10,
        :colour => "#7F7F7F",
        "grid-colour" => "#D2D2D2",
        :labels => {
          :text => "#val# 次",
          :colour => "#333333",
          :size => 10
        },
        :min => 0,
        :max => 20*100,
        :steps => 200
      },
      
      :elements => [
        {
          :type => "line",
          :colour => "#0077CC",
          :width => 2,
          :text => "企业查询数",
          "font-size" => 12,
          "dot-style" => {
            :type => "solid-dot",
            "dot-size" => 4,
            "halo-size" => 2,
            :colour => "#0077CC",
            "on-click" => "//line_click(x_index)"
          },
          "on-show" => {
            :type => "pop-up",
            :cascade => 1,
            :delay => 0.5
          },
          :values => [10,12,14,9,12,13,10,13,12].collect{ |n|
            {
              :value => n*100,
              :tip => "09年1月#{n}日 星期#{n} <br> 查询了 #{n} 次"
            }
          }
        }
      ]
    }.to_json
  end
  
end
