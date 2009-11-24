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
    @view = (params[:view] && params[:view].strip)
    @period = params[:period] && params[:period].strip
    
    view_info = {
      "day" => [:day, 1.month, "%Y%m%d", "%y.%m.%d"],
      "week" => [:week, 1.year, "%Y%j", "%y年%U周"],
      "month" => [:month, 1.year, "%Y%m", "%y年%m月"],
      "year" => [:year, 4.year, "%Y", "%y年"]
    }
    period_unit, default_period, count_key_format, label_format = view_info[@view] || view_info[@view = "day"]
    
    from, to = begin
      [(periods = @period.split("-", 2))[0], periods[1]].collect { |date|
        Date.parse(date)
      }
    rescue
      today = Date.today
      [default_period.ago(today), today]
    end
    
    query_counts = CorpQuery.period_counts(@teacher.school_id, period_unit, from, to).inject({}) do |hash, record|
      hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
      hash
    end
    view_counts = CorpViewedResume.period_counts(@teacher.school_id, period_unit, from, to).inject({}) do |hash, record|
      hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
      hash
    end
    
    query_line_color = "#0077CC"
    view_line_color = "#FF6600"
    @dots = []
    @query_values = []
    @view_values = []
    labels = []
    max_value = 0
    Utils.step_period(from, to, period_unit) do |first, last|
      @dots << [first, last]
      
      key = first.strftime(count_key_format)
      tip_title = %Q!<font size="12" face="Verdana" color="#333333">! +
                  if first == last
                    %Q!#{first.year}年#{first.month}月#{first.mday}日 星期#{["天", "一", "二", "三", "四", "五", "六"][first.wday]}!
                  else
                    %Q!#{first.year}年#{first.month}月#{first.mday}日 - #{last.year}年#{last.month}月#{last.mday}日!
                  end +
                  %Q!</font>!
      query_value = query_counts[key] || 0
      view_value = view_counts[key] || 0
      tip = %Q!#{tip_title}! +
            %Q!  <br>! +
            %Q!<font size="12" face="Verdana" color="#{query_line_color}">进行了 <b>#{query_value}</b> 次搜索</font>! +
            %Q!<br>! +
            %Q!<font size="12" face="Verdana" color="#{view_line_color}">查看了 <b>#{view_value}</b> 次简历</font>!
      
      @query_values << {
        :value => query_value,
	      :tip => (query_value == view_value) ? "" : tip
	    }
      @view_values << {
        :value => view_value,
	      :tip => tip
	    }
      labels << first.strftime(label_format)
      
      max_value = [max_value, query_value, view_value].max
    end
    
    step_x = (labels.size / 8) + 1
    
    max_y = %Q!#{max_value.to_s.first.to_i+1}#{"0"*(max_value.to_s.size-1)}!.to_i
    max_y = 10 if max_y < 10
    
    dot_type = labels.size > 60 ? "dot" : "solid-dot"
    
    @chart_data = ofc_chart_data(
			:x_axis => {
			  :steps => step_x,
    		:labels => {
    			:labels => labels,
    			"visible-steps" => step_x
    		}
    	},

    	:y_axis => {
    		:labels => {
    			:text => "#val# 次",
    		},
    		:min => 0,
    		:max => max_y,
    		:steps => max_y/5
    	},

    	:elements => [
        {
          :type => "area",
          :colour => query_line_color,
          :text => "企业搜索数",
          :fill => query_line_color,
          "fill-alpha" => 0.1,
          "dot-style" => {
            :type => dot_type,
            :colour => query_line_color,
            "on-click" => "query_detail"
          },
          :values => @query_values
        },
    		
    		{
    		  :type => "area",
    		  :colour => view_line_color,
    		  :text => "查看简历数",
    		  :fill => view_line_color,
          "fill-alpha" => 0.1,
    		  "dot-style" => {
    		    :type => dot_type,
    		    :colour => view_line_color,
    		    "on-click" => "view_detail"
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
