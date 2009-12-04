class TeacherStatisticsController < ApplicationController
  
  Queries_Page_Size = 100
  Date_Range_Splitter = "-"
  
  Perspectives = [
    ["time", "时段统计"],
    ["college", "简历查看统计"],
    ["#", "企业搜索统计"]
  ]

  include OpenFlashChartHelpers
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  # before_filter :check_active, :only => []
  
  before_filter :check_teacher
  
  before_filter :check_teacher_statistic
  
  
  def index
    
  end
  
  
  def querying
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corp_queries = CorpQuery.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation]
    )
  end
  
  def viewing
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @viewed_resumes = CorpViewedResume.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation, {:resume => [:student]}]
    )
  end
  
  
  def details
    type = params[:type] && params[:type].strip
    prepare_period(Date.today)
    filters = prepare_filters
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    detail_class, detail_title, detail_template, includes = {
      "query" => [CorpQuery, "企业搜索操作", "queries_grid", [:corporation]],
      "view" => [CorpViewedResume, "企业查看简历", "resumes_grid", [:corporation, {:resume => [:student]}]]
    }[type]
    
    options = {
      :includes => includes,
      :page => page,
      :per_page => 10,
      :with => filters
    }
    
    @records = (detail_class && detail_class.period_records(@teacher.school_id, @from, @to, options)) || []
		
    render(
      :layout => false,
      :inline => %Q!
        <div style="margin: 0px 10px 10px;">
          <span style="font-size: 13px; font-weight: bold;">#{detail_title}</span>
          
          <span class="info" style="margin: 0px 10px;">|</span>
          
          时段:
          <%= @from.strftime("%Y年%m月%d日") %>
          <% unless @from == @to %>
            -
            <%= @to.strftime("%Y年%m月%d日") %>
          <% end %>
          
          <% if @corp %>
            <span class="info" style="margin: 0px 10px;">|</span>
            
            <% corp_name = h(@corp.name? ? @corp.name : @corp.uid) %>
            过滤企业:
  					<span title="<%= corp_name %>">
  						<%= truncate(corp_name, :length => 20) %>
  					</span>
          <% end %>
        </div>
        
        <% if @records.size > 0 %>
          <%= render :partial => "#{detail_template}", :locals => {:records => @records} %>
        <% end %>
      !
    )
  end
  
  
  def time
    @query_dataset_color = "#0077CC"
    @view_dataset_color = "#FF6600"
    @query_dataset_name = "企业搜索数"
    @view_dataset_name = "查看简历数"
    
    @q = !(params[:q] == "f")
    @v = !(params[:v] == "f")
    
    filters = prepare_filters
    
    period_unit, default_period, count_key_format, label_format = prepare_time_view
    prepare_period(default_period.ago(Date.today))
    compared_to = prepare_compare
    
    # if the count of days are the same of two periods
    # then the difference of the count of other unit(week, month ...)
    # would NOT be bigger than 2
    compared_to &&= 2.send(period_unit).since(compared_to)
    
    count_options = {
      :group_by => "updated_at",
      :group_function => period_unit,
      :with => filters
    }
    
    query_counts = {}
    compared_query_counts = {}
    if @q
      query_counts = CorpQuery.period_group_counts(@teacher.school_id, @from, @to, count_options)
      
      if @compared_from
        compared_query_counts = CorpQuery.period_group_counts(@teacher.school_id, @compared_from, compared_to, count_options)
      end
    end
    
    view_counts = {}
    compared_view_counts = {}
    if @v
      view_counts = CorpViewedResume.period_group_counts(@teacher.school_id, @from, @to, count_options)
      
      if @compared_from
        compared_view_counts = CorpViewedResume.period_group_counts(@teacher.school_id, @compared_from, compared_to, count_options)
      end
    end
    
    @dots = []
    if @compared_from
      @compared_dots = []
      compared_periods = Utils.step_period(@compared_from, compared_to, period_unit)
    end
    if @q
      @query_values = []
      if @compared_from
        @compared_query_values = []
        @query_diffs = []
      end
    end
    if @v
      @view_values = []
      if @compared_from
        @compared_view_values = []
        @view_diffs = []
      end
    end
    labels = []
    max_value = 0
    step_period_index = 0
    Utils.step_period(@from, @to, period_unit) do |first, last|
      @dots << [first, last]
      
      key = first.strftime(count_key_format)
      query_value = query_counts[key] || 0
      view_value = view_counts[key] || 0
      
      if @compared_from
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
                    %Q!<font size="12" face="Verdana" color="#{@query_dataset_color}">! +
                    %Q!进行了 <b>#{query_value}</b> 次搜索! +
                    %Q!</font>! +
                    %Q!<font size="11" face="Verdana" color="#{@query_dataset_color}">! +
                    (@compared_from ? %Q! (#{query_diff})! : "") +
                    %Q!</font>!
      end
      if @v
        tip = tip + %Q! <br>! +
                    %Q!<font size="12" face="Verdana" color="#{@view_dataset_color}">! +
                    %Q!查看了 <b>#{view_value}</b> 次简历! +
                    %Q!</font>! +
                    %Q!<font size="11" face="Verdana" color="#{@view_dataset_color}">! +
                    (@compared_from ? %Q! (#{view_diff})! : "") +
                    %Q!</font>!
      end
      
      if @compared_from
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
                          %Q!<font size="12" face="Verdana" color="#{@query_dataset_color}">! +
                          %Q!进行了 <b>#{compared_query_value}</b> 次搜索! +
                          %Q! (对比)! +
                          %Q!</font>!
        end
        if @v
          compared_tip = compared_tip +
                          %Q! <br>! +
                          %Q!<font size="12" face="Verdana" color="#{@view_dataset_color}">! +
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
  	    
  	    if @compared_from
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
  	    
  	    if @compared_from
    	    @compared_view_values << {
            :value => compared_view_value,
            :tip => compared_tip
    	    }
    	    
    	    @view_diffs << view_diff
  	    end
	    end
      labels << first.strftime(label_format)
      
      max_value = [max_value, query_value, view_value].max
      max_value = [max_value, compared_query_value, compared_view_value].max if @compared_from
    end
    
    step_x = (labels.size / 8) + 1
    
    max_y = Utils.top_axis(max_value)
    
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
    	    color = self.instance_variable_get("@#{line}_dataset_color")
    	    name = self.instance_variable_get("@#{line}_dataset_name")
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
      	  ) if @compared_from
      	  
      	  line_styles
        else
          nil
        end
    	}.flatten.compact
		)
  end
  
  
  def college
    @group_by = "college_id"
    @groups_name = "学院"
    @group_title_proc = Proc.new { |group|
      college = College.find(@school.abbr, group)
      college[:name]
    }
    
    prepare_rank_view
    prepare_period(1.year.ago(Date.today))
    compared_to = prepare_compare
    prepare_order
    prepare_limit
    
    count_options = {
      :group_by => @group_by,
      :group_function => :attr,
      :group_clause => "@count #{@order.upcase}",
      :limit => @limit,
      :with => prepare_filters
    }
    
    @counts = CorpViewedResume.period_group_counts(@teacher.school_id, @from, @to, count_options)
    
    # if @compared_from
    #   @compared_counts = CorpViewedResume.period_group_counts(@teacher.school_id, @compared_from, compared_to, count_options)
    # end
    
    @total_count = CorpViewedResume.period_total_count(@teacher.school_id, @from, @to, count_options)
    
    max_value = @counts.inject(0) { |max, record| [max, record[1]["@count"]].max }
    @max = Utils.top_axis(max_value)
    
    @chart_data = ofc_chart_data(
      
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
  
  
  def prepare_filters
    corp_id = params[:corp] && params[:corp].strip
    @corp = corp_id.blank? ? nil : Corporation.try_find(corp_id)
    
    level_id = params[:level] && params[:level].strip
    @level = EduLevel.find(level_id.to_i)
    
    @graduation = params[:graduation] && params[:graduation].strip
    
    college_id = params[:college] && params[:college].strip
    @college = College.find(@school.abbr, college_id.to_i)
    
    if @college
      major_id = params[:major] && params[:major].strip
  	  @major = Major.find(@college[:id], major_id.to_i)
	  end
	  
	  student_id = params[:student] && params[:student].strip
    @student = student_id.blank? ? nil : Student.try_find(student_id)
    
    filters = {}
    filters[:corporation_id] = @corp.id if @corp
    filters[:edu_level_id] = @level[:id] if @level
    filters[:graduation_year] = @graduation unless @graduation.blank?
    filters[:college_id] = @college[:id] if @college
    filters[:major_id] = @major[:id] if @major
    filters[:student_id] = @student.id if @student
    
    filters
  end
  
  
  def prepare_period(default_from)
    periods = (params[:period] || "").split(Date_Range_Splitter, 2)
    @from, @to = begin
      [periods[0], periods[1]].collect { |date|
        Date.parse(date)
      }
    rescue
      [default_from, Date.today]
    end
  end
  
  
  def prepare_time_view
    @view = params[:view] && params[:view].strip
    
    view_infos = {
      "day" => [:day, 1.month, "%Y%m%d", "%y.%m.%d"],
      "week" => [:week, 1.year, "%Y%j", "%y年%U周"],
      "month" => [:month, 1.year, "%Y%m", "%y年%m月"],
      "year" => [:year, 4.year, "%Y", "%y年"]
    }
    view_infos[@view] || view_infos[@view = "day"]
  end
  
  
  def prepare_rank_view
    @view = params[:view] && params[:view].strip
    
    @view = "bar" unless ["bar", "pie"].include?(@view)
  end
  
  
  def prepare_compare
    compare = params[:compare] && params[:compare].strip
    @compared_from = compare.blank? ? nil : (Date.parse(compare) rescue nil)
    
    @compared_from && (@compared_from + (@to - @from))
  end
  
  
  def prepare_order
    @order = params[:order] && params[:order].strip
    
    @order = "desc" unless ["asc", "desc"].include?(@order)
  end
  
  
  def prepare_limit
    limit_param = params[:limit] && params[:limit].strip
    
    @limit = limit_param.blank? ? 30 : limit_param.to_i
    
    @limit = [@limit, 100].min
    @limit = [@limit, 1].max
  end
  
end
