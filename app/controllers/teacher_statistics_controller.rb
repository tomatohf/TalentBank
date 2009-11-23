class TeacherStatisticsController < ApplicationController
  
  Queries_Page_Size = 100

  include OpenFlashChartHelpers
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  # before_filter :check_active, :only => []
  
  before_filter :check_teacher
  
  before_filter :check_teacher_statistic
  
  
  def index
    
  end
  
  
  def queries
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corp_queries = CorpQuery.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation]
    )
  end
  
  def resumes
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @viewed_resumes = CorpViewedResume.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation, {:resume => [:student]}]
    )
  end
  
  
  def counts
    @view = params[:view] && params[:view].strip
    @period = params[:period] && params[:period].strip
    
    view_info = {
      "day" => [:day, 1.month, "%Y%m%d"],
      "week" => [:week, 1.year, "%Y%j"],
      "month" => [:month, 1.year, "%Y%m"],
      "year" => [:year, 4.year, "%Y"]
    }
    period_unit, default_period, count_key_format = view_info[@view] || view_info["day"]
    
    from, to = begin
      [(periods = @period.split("-", 2))[0], periods[1]].collect { |date|
        Date.parse(date)
      }
    rescue
      today = Date.today
      [default_period.ago(today), today]
    end
    
    query_counts = CorpQuery.period_counts(period_unit, from, to).inject({}) do |hash, record|
      hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
      hash
    end
    view_counts = CorpViewedResume.period_counts(period_unit, from, to).inject({}) do |hash, record|
      hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
      hash
    end
    
    query_line_color = "#0077CC"
    view_line_color = "#FF6600"
    @query_values = []
    @view_values = []
    @labels = []
    Utils.step_period(from, to, period_unit) do |first, last|
      key = first.strftime(count_key_format)
      tip_title = (first == last) ? "#{first.year}年#{first.month}月#{first.mday}日 星期#{first.wday}" : ""
      query_value = query_counts[key] || 0
      view_value = view_counts[key] || 0
      @query_values << {
        :value => query_value,
        :colour => query_line_color,
	      :tip => "#{tip_title} <br> 进行了 #{query_value} 次搜索"
	    }
      @view_values << {
        :value => view_value,
        :colour => view_line_color,
	      :tip => "#{tip_title} <br> 查看了 #{view_value} 次简历"
	    }
      @labels << ((first == last) ? first.strftime("%Y-%m-%d") : %Q!#{first.strftime("%Y-%m-%d")} - last.strftime("%Y-%m-%d")!)
    end
    
    @chart_data = ofc_chart_data(
			:x_axis => {
    		:labels => {
    			:labels => @labels,
    			"visible-steps" => 5
    		}
    	},

    	:y_axis => {
    		:labels => {
    			:text => "#val# 次",
    		},
    		:max => 20,
    		:steps => 2
    	},

    	:elements => [
        {
          :type => "line",
          :colour => query_line_color,
          :text => "企业搜索数",
          "dot-style" => {
            :type => "solid-dot",
            :colour => query_line_color,
            "on-click" => "//line_click(x_index)"
          },
          :values => @query_values
        },
    		
    		{
    		  :type => "line",
    		  :colour => view_line_color,
    		  :text => "查看简历数",
    		  "dot-style" => {
    		    :type => "solid-dot",
    		    :colour => view_line_color,
    		    "on-click" => "//line_click(x_index)"
    		  },
    		  :values => @view_values
    		}
    	]
		)
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_statistic
    jump_to("/errors/unauthorized") unless @teacher.statistic
  end
  
end
