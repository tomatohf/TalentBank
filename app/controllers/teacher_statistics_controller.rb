class TeacherStatisticsController < ApplicationController
  
  Queries_Page_Size = 100
  Date_Range_Splitter = "-"

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
    @query_line_color = "#0077CC"
    @view_line_color = "#FF6600"
    @query_line_name = "企业搜索数"
    @view_line_name = "查看简历数"
    
    @view = params[:view] && params[:view].strip
    @period = params[:period] && params[:period].strip
    @q = !(params[:q] == "f")
    @v = !(params[:v] == "f")
    @compare = params[:compare] && params[:compare].strip
    
    view_info = {
      "day" => [:day, 1.month, "%Y%m%d", "%y.%m.%d"],
      "week" => [:week, 1.year, "%Y%j", "%y年%U周"],
      "month" => [:month, 1.year, "%Y%m", "%y年%m月"],
      "year" => [:year, 4.year, "%Y", "%y年"]
    }
    period_unit, default_period, count_key_format, label_format = view_info[@view] || view_info[@view = "day"]
    
    from, to = begin
      [(periods = @period.split(Date_Range_Splitter, 2))[0], periods[1]].collect { |date|
        Date.parse(date)
      }
    rescue
      today = Date.today
      [default_period.ago(today), today]
    end
    @period = %Q!#{from.strftime("%Y%m%d")}#{Date_Range_Splitter}#{to.strftime("%Y%m%d")}!
    
    compared_from = begin
      Date.parse(@compare)
    rescue
      @compare = ""
      nil
    end
    # if the count of days are the same of two periods
    # then the difference of the count of other unit(week, month ...)
    # would NOT be bigger than 2
    compared_to = 2.send(period_unit).since(compared_from + (to - from)) if compared_from
    comparing = compared_from && compared_to
    
    query_counts = {}
    compared_query_counts = {}
    if @q
      query_counts = CorpQuery.period_counts(@teacher.school_id, period_unit, from, to).inject({}) do |hash, record|
        hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
        hash
      end
      
      if comparing
        compared_query_counts = CorpQuery.period_counts(@teacher.school_id, period_unit, compared_from, compared_to).inject({}) do |hash, record|
          hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
          hash
        end
      end
    end
    
    view_counts = {}
    compared_view_counts = {}
    if @v
      view_counts = CorpViewedResume.period_counts(@teacher.school_id, period_unit, from, to).inject({}) do |hash, record|
        hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
        hash
      end
      
      if comparing
        compared_view_counts = CorpViewedResume.period_counts(@teacher.school_id, period_unit, compared_from, compared_to).inject({}) do |hash, record|
          hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
          hash
        end
      end
    end
    
    @dots = []
    if comparing
      @compared_dots = []
      compared_periods = Utils.step_period(compared_from, compared_to, period_unit)
    end
    if @q
      @query_values = []
      if comparing
        @compared_query_values = []
        @query_diffs = []
      end
    end
    if @v
      @view_values = []
      if comparing
        @compared_view_values = []
        @view_diffs = []
      end
    end
    labels = []
    max_value = 0
    step_period_index = 0
    Utils.step_period(from, to, period_unit) do |first, last|
      @dots << [first, last]
      
      key = first.strftime(count_key_format)
      query_value = query_counts[key] || 0
      view_value = view_counts[key] || 0
      
      if comparing
        compared_first, compared_last = compared_periods[step_period_index]
        @compared_dots << compared_periods[step_period_index]
        
        compared_key = compared_first.strftime(count_key_format)
        compared_query_value = compared_query_counts[compared_key] || 0
        compared_view_value = compared_view_counts[compared_key] || 0
        
        query_diff = Utils.growth(query_value, compared_query_value, 1)
        view_diff = Utils.growth(view_value, compared_view_value, 1)
      end
      step_period_index += 1
      
      tip = %Q!<font size="12" face="Verdana" color="#333333">! +
            if first == last
              %Q!#{first.year}年#{first.month}月#{first.mday}日 星期#{["天", "一", "二", "三", "四", "五", "六"][first.wday]}!
            else
              %Q!#{first.year}年#{first.month}月#{first.mday}日 - #{last.year}年#{last.month}月#{last.mday}日!
            end +
            %Q!</font>!
      if @q
        tip = tip + %Q! <br>! +
                    %Q!<font size="12" face="Verdana" color="#{@query_line_color}">! +
                    %Q!进行了 <b>#{query_value}</b> 次搜索! +
                    %Q!</font>! +
                    %Q!<font size="11" face="Verdana" color="#{@query_line_color}">! +
                    (comparing ? %Q! (#{query_diff})! : "") +
                    %Q!</font>!
      end
      if @v
        tip = tip + %Q! <br>! +
                    %Q!<font size="12" face="Verdana" color="#{@view_line_color}">! +
                    %Q!查看了 <b>#{view_value}</b> 次简历! +
                    %Q!</font>! +
                    %Q!<font size="11" face="Verdana" color="#{@view_line_color}">! +
                    (comparing ? %Q! (#{view_diff})! : "") +
                    %Q!</font>!
      end
      
      if comparing
        compared_tip = %Q!<font size="12" face="Verdana" color="#333333">! +
              if compared_first == compared_last
                %Q!#{compared_first.year}年#{compared_first.month}月#{compared_first.mday}日 星期#{["天", "一", "二", "三", "四", "五", "六"][compared_first.wday]}!
              else
                %Q!#{compared_first.year}年#{compared_first.month}月#{compared_first.mday}日 - #{compared_last.year}年#{compared_last.month}月#{compared_last.mday}日!
              end +
              %Q! <b>(对比)</b>! +
              %Q!</font>!
        if @q
          compared_tip = compared_tip +
                          %Q! <br>! +
                          %Q!<font size="12" face="Verdana" color="#{@query_line_color}">! +
                          %Q!进行了 <b>#{compared_query_value}</b> 次搜索! +
                          %Q! (对比)! +
                          %Q!</font>!
        end
        if @v
          compared_tip = compared_tip +
                          %Q! <br>! +
                          %Q!<font size="12" face="Verdana" color="#{@view_line_color}">! +
                          %Q!查看了 <b>#{compared_view_value}</b> 次简历! +
                          %Q! (对比)! +
                          %Q!</font>!
        end
      end
      
      if @q
        @query_values << {
          :value => query_value,
  	      :tip => ((query_value == view_value) && @v) ? "" : tip
  	    }
  	    
  	    if comparing
    	    @compared_query_values << {
            :value => compared_query_value,
            :tip => ((compared_query_value == compared_view_value) && @v) ? "" : compared_tip
    	    }
    	    
    	    @query_diffs << query_diff
  	    end
	    end
	    if @v
        @view_values << {
          :value => view_value,
  	      :tip => tip
  	    }
  	    
  	    if comparing
    	    @compared_view_values << {
            :value => compared_view_value,
            :tip => compared_tip
    	    }
    	    
    	    @view_diffs << view_diff
  	    end
	    end
      labels << first.strftime(label_format)
      
      max_value = [max_value, query_value, view_value, compared_query_value, compared_view_value].max
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

    	:elements => ["query", "view"].collect { |line|
    	  if self.instance_variable_get("@#{line[0, 1]}")
    	    color = self.instance_variable_get("@#{line}_line_color")
    	    name = self.instance_variable_get("@#{line}_line_name")
      	  line_styles = [
      	    {
              :type => "area",
              :colour => color,
              :text => name,
              :fill => color,
              "fill-alpha" => 0.1,
              "dot-style" => {
                :type => dot_type,
                :colour => color,
                "on-click" => "#{line}_detail"
              },
              :values => self.instance_variable_get("@#{line}_values")
            }
      	  ]
      	  
      	  line_styles << line_styles[0].merge(
      	    {
      	      "line-style" => {
                :style => "dash",
                :on => 6,
                :off => 5
              },
              :width => 2,
              
              :type => "line",
              :text => "",
      	      "dot-style" => {
                :type => dot_type,
                :colour => color,
                "dot-size" => 3,
                "on-click" => "compared_#{line}_detail"
              },
              :values => self.instance_variable_get("@compared_#{line}_values")
      	    }
      	  ) if comparing
      	  
      	  line_styles
        else
          nil
        end
    	}.flatten.compact
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
