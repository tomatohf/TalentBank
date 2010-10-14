class TeacherStatisticsController < ApplicationController
  
  Queries_Page_Size = 30
  Date_Range_Splitter = "-"

  include OpenFlashChartHelpers
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  # before_filter :check_active, :only => []
  
  before_filter :check_teacher
  
  before_filter :check_teacher_statistic
  
  
  def querying
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corp_queries = CorpQuery.search(
      :page => page,
      :per_page => Queries_Page_Size,
      :match_mode => CorpQuery::Search_Match_Mode,
      :order => "@weight DESC, updated_at DESC",
      :with => {:school_id => @teacher.school_id},
      :include => [:corporation]
    )
  end
  
  def viewing
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @viewed_resumes = CorpViewedResume.search(
      :page => page,
      :per_page => Queries_Page_Size,
      :match_mode => CorpViewedResume::Search_Match_Mode,
      :order => "@weight DESC, updated_at DESC",
      :with => {:school_id => @teacher.school_id},
      :include => [:corporation, {:resume => [:student]}]
    )
  end
  
  
  def details
    type = params[:type] && params[:type].strip
    prepare_period(Date.today)
    filters = prepare_filters
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    detail_class, @detail_title, @detail_template, includes, param_keys = {
      "query" => [CorpQuery, "企业搜索操作", "queries_grid", [:corporation], []],
      "view" => [CorpViewedResume, "企业查看简历", "resumes_grid", [:corporation, {:resume => [:student]}], []],
      "intern_log" => [InternLog, "学生实习记录", "intern_logs_grid", [:student, {:job => :corporation}, :teacher], [:event_id, :result_id]],
    }[type]
    
    param_filters = param_keys.inject({}) do |hash, key|
      hash[key] = params[key] unless params[key].blank?
      hash
    end
    
    options = {
      :includes => includes,
      :page => page,
      :per_page => 10,
      :with => filters.merge(param_filters)
    }
    
    @records = (detail_class && detail_class.period_records(@teacher.school_id, @from, @to, options)) || []
		
    render :layout => false
  end
  
  
  def index
    @query_dataset_color = "#0077CC"
    @view_dataset_color = "#FF6600"
    @query_dataset_name = "企业搜索数"
    @view_dataset_name = "查看简历数"
    
    filters = prepare_filters
    
    @q = !(params[:q] == "f")
    @v = !(params[:v] == "f")
    
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
              ApplicationController.helpers.format_zh_date(first)
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
                ApplicationController.helpers.format_zh_date(compared_first)
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
                "on-click" => "#{line}_dot_detail"
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
                "on-click" => "compared_#{line}_dot_detail"
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
  
  
  def university
    @group_by = :university_id
    @groups_name = "大学"
    
    viewing_rank do |group_values|
      group_values.inject({}) { |hash, group_value|
        record = University.find(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def college
    @group_by = :college_id
    @groups_name = "学院"
    
    viewing_rank do |group_values|
      group_values.inject({}) { |hash, group_value|
        record = College.find_by_id(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def major
    @group_by = :major_id
    @groups_name = "专业"
    
    viewing_rank do |group_values|
      group_values.inject({}) { |hash, group_value|
        record = Major.find_by_id(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def student
    @group_by = :student_id
    @groups_name = "学生"
    
    viewing_rank do |group_values|
      (@student && { @student.id => @student.name }) || Student.find(
        :all,
        :conditions => ["id in (?)", group_values]
      ).inject({}) { |hash, record|
        hash[record.id] = record.name
        hash
      }
    end
  end
  
  
  def viewing_domain
    @group_by = :domain_id
    @groups_name = "求职方向"
    
    viewing_rank do |group_values|
      group_values.inject({}) { |hash, group_value|
        record = ResumeDomain.find(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def viewing_corp
    @group_by = :corporation_id
    @groups_name = "企业"
    
    viewing_rank do |group_values|
      (@corp && { @corp.id => @corp.get_name }) || Corporation.find(
        :all,
        :conditions => ["id in (?)", group_values]
      ).inject({}) { |hash, record|
        hash[record.id] = record.name
        hash
      }
    end
  end
  
  
  def querying_corp
    @group_by = :corporation_id
    @groups_name = "企业"
    
    querying_rank do |group_values|
      (@corp && { @corp.id => @corp.name? ? @corp.name : @corp.uid }) || Corporation.find(
        :all,
        :conditions => ["id in (?)", group_values]
      ).inject({}) { |hash, record|
        hash[record.id] = record.name
        hash
      }
    end
  end
  
  
  def querying_domain
    @drill = ["querying_domain", "tag", nil]
    
    @group_by = :domain_id
    @groups_name = "求职方向"
    
    querying_rank do |group_values|
      group_values.inject({}) { |hash, group_value|
        record = ResumeDomain.find(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def tag
    @group_by = :exp_tag_id
    @groups_name = "经历标签"
    @hide_filters = [:views]
    
    querying_rank do |group_values|
      @view = "bar"
      
      group_values.inject({}) { |hash, group_value|
        record = ResumeExpTag.find_by_id(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def skill
    @drill = ["skill", "skill_value", nil]
    
    @group_by = :skill_id
    @groups_name = "技能和证书"
    @hide_filters = [:views]
    
    querying_rank do |group_values|
      @view = "bar"
      
      group_values.inject({}) { |hash, group_value|
        record = Skill.find(group_value)
        hash[record[:id]] = record[:name]
        hash
      }
    end
  end
  
  
  def skill_value
    skill_id = params[:skill] && params[:skill].strip
    jump_to("/teachers/#{@teacher.id}/statistics/skill") if skill_id.blank?
    
    @group_by = :skill_values
    @hide_filters = [:limit]
    
    @counts_post_proc = Proc.new { |counts|
      counts.delete_if { |record| record[1]["@groupby"].to_s[0, 6] != @skill[:id].to_s }
    }
    
    querying_rank do |group_values|
      @groups_name = @skill[:name]
      
      group_values.inject({}) { |hash, group_value|
        skill = Skill.find(group_value.to_s[0, 6].to_i)
        skill_value = group_value.to_s[6..-1].to_i
        skill_value_label = SkillValueTypes.get_type(skill[:value_type]).render_label(skill[:data], skill_value)
        
        hash[group_value] = skill_value_label.blank? ? "不限" : skill_value_label
        hash
      }
    end
  end
  
  
  def keyword
    @group_by = :keyword
    @groups_name = "关键词"
    
    @using_title_as_group_value = true
    @extra_count_options = {
      :without => {
        :keyword => 0
      }
    }
    
    querying_rank do |group_values|
      keyword_map = CorpQuery.find(
        :all,
        :conditions => ["id in (?)", @counts.collect{|c| c[0]}]
      ).inject({}) { |hash, query|
        hash[query.keyword.to_crc32] = query.keyword
        hash
      }
      
      group_values.inject({}) { |hash, group_value|
        hash[group_value] = keyword_map[group_value]
        hash
      }
    end
  end
  
  
  
  def intern_logs
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @intern_logs = InternLog.search(
      :page => page,
      :per_page => Queries_Page_Size,
      :match_mode => InternLog::Search_Match_Mode,
      :order => "@weight DESC, occur_at DESC",
      :with => {:school_id => @teacher.school_id},
      :include => [:student, {:job => :corporation}, :teacher]
    )
  end
  
  
  def intern
    prepare_period(Date.parse(InternLog.intern_begin_at))
    compared_to = prepare_compare
    filters = prepare_filters
    
    generate_dataset = Proc.new { |event|
      InternLogEventResult.find_group(event[:id]).map { |result|
		    {
		      :title => "#{event[:name]} - #{result[:name]}",
		      :event_id => event[:id],
		      :result_id => result[:id]
		    }
		  }
    }
    @datasets = [
			{
			  :title => "#{(event = InternLogEvent.inform_interview)[:name]} 数据",
			  :rows => generate_dataset.call(event),
			  :total => {
			    :title => event[:name]
			  }
			},
			
			{
			  :title => "#{(event = InternLogEvent.interview_result)[:name]} 数据",
			  :rows => generate_dataset.call(event),
			  :total => {
			    :title => event[:name]
			  }
			},
			
			{
			  :title => "实习结果 数据",
			  :rows => [
			    {
			      :title => "实习后 #{InternLogEventResult.intern_end_employed[:name]}",
			      :event_id => InternLogEvent.intern_end[:id],
			      :result_id => InternLogEventResult.intern_end_employed[:id]
			    },
			    {
			      :title => "实习中 #{InternLogEventResult.intern_end_leave[:name]}",
			      :event_id => InternLogEvent.intern_end[:id],
			      :result_id => InternLogEventResult.intern_end_leave[:id]
			    },
			    {
			      :title => "实习中 #{InternLogEventResult.intern_end_fire[:name]}",
			      :event_id => InternLogEvent.intern_end[:id],
			      :result_id => InternLogEventResult.intern_end_fire[:id]
			    }
			  ],
			  :total => {
		      :title => "实习人次",
		      :event_id => InternLogEvent.interview_result[:id],
		      :result_id => InternLogEventResult.interview_result_passed[:id]
		    }
			}
		]
		
		max_value = 0
		
		@datasets.each do |dataset|
		  search_total_count = dataset[:total][:event_id] && dataset[:total][:result_id]
		  total_count_options = {
        :event_id => dataset[:total][:event_id],
        :result_id => dataset[:total][:result_id]
      } if search_total_count
      
		  total_count = if search_total_count
		    InternLog.period_total_count(
		      @teacher.school_id, @from, @to, :with => filters.merge(total_count_options)
		    )
	    else
	      0
      end
      
      if @compared_from
        compared_total_count = if search_total_count
  		    InternLog.period_total_count(
    	      @teacher.school_id, @compared_from, compared_to, :with => filters.merge(total_count_options)
    	    )
  	    else
  	      0
        end
      end
      
		  dataset[:rows].each do |row|
		    count_options = {
          :event_id => row[:event_id],
          :result_id => row[:result_id]
        }
        
		    count = InternLog.period_total_count(
		      @teacher.school_id, @from, @to, :with => filters.merge(count_options)
		    )
		    row.merge!(:count => count)
		    total_count += count unless search_total_count
		    max_value = count if count > max_value
		    
		    if @compared_from
          compared_count = InternLog.period_total_count(
  		      @teacher.school_id, @compared_from, compared_to, :with => filters.merge(count_options)
  		    )
  		    row.merge!(:compared_count => compared_count)
  		    compared_total_count += compared_count unless search_total_count
  		    max_value = compared_count if compared_count > max_value
        end
	    end
	    
	    dataset[:total].merge!(:count => total_count)
	    if @compared_from
	      dataset[:total].merge!(:compared_count => compared_total_count)
      end
		  

      values = []
      total_shown_count = 0
      if @compared_from
        compared_values = []
        compared_total_shown_count = 0
      end
      dataset[:rows].each_with_index { |row, i|
        values << get_pie_chart_value(row[:count], dataset[:total][:count], row[:title], i)
        total_shown_count += row[:count]
        if @compared_from
				  compared_values << get_pie_chart_value(row[:compared_count], dataset[:total][:compared_count], "#{row[:title]} (对比)", i)
				  compared_total_shown_count += row[:compared_count]
			  end
      }
      
      else_count = dataset[:total][:count] - total_shown_count
      values << get_pie_chart_value(else_count, dataset[:total][:count], "其他", TeacherStatisticsHelper::Pie_Chart_Colors.size) if else_count > 0
      
      chart_data = ofc_chart_data(
        :elements => [
          {
            :type => "pie",
            :radius => 100,
            :values => values
          }
        ]
      )
      chart_data.delete(:x_axis)
      chart_data.delete(:y_axis)
      dataset.merge!(:chart_data => chart_data)
      
      if @compared_from
        compared_else_count = dataset[:total][:compared_count] - compared_total_shown_count
        compared_values << get_pie_chart_value(compared_else_count, dataset[:total][:compared_count], "其他 (对比)", TeacherStatisticsHelper::Pie_Chart_Colors.size) if compared_else_count > 0
        
        compared_chart_data = ofc_chart_data(
          :elements => [
            {
              :type => "pie",
              :alpha => 0.6,
              :radius => 100,
              :values => compared_values
            }
          ]
        )
        compared_chart_data.delete(:x_axis)
        compared_chart_data.delete(:y_axis)
        dataset.merge!(:compared_chart_data => compared_chart_data)
      end
	  end
	  
	  @max = Utils.top_axis(max_value)
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
    level_id = params[:level] && params[:level].strip
    @level = EduLevel.find(level_id.to_i)
    
    @graduation = params[:graduation] && params[:graduation].strip
    
    university_id = params[:university] && params[:university].strip
    @university = University.find(university_id.to_i)
    
    college_id = params[:college] && params[:college].strip
    @college = College.find_by_id(college_id.to_i)
    
    major_id = params[:major] && params[:major].strip
	  @major = Major.find_by_id(major_id.to_i)
	  
	  student_id = params[:student] && params[:student].strip
    @student = student_id.blank? ? nil : Student.try_find(student_id)
    
    
    corp_id = params[:corp] && params[:corp].strip
    @corp = corp_id.blank? ? nil : Corporation.try_find(corp_id)
    
    corp_industry_category_id = params[:corp_industry_category] && params[:corp_industry_category].strip
    @corp_industry_category = IndustryCategory.find(corp_industry_category_id.to_i)
    
    corp_industry_id = params[:corp_industry] && params[:corp_industry].strip
	  @corp_industry = Industry.find_by_id(corp_industry_id.to_i)
	  
	  corp_nature_id = params[:corp_nature] && params[:corp_nature].strip
    @corp_nature = CorporationNature.find(corp_nature_id.to_i)
    
    domain_id = params[:domain] && params[:domain].strip
    @domain = ResumeDomain.find(domain_id.to_i)
    
    tag_id = params[:tag] && params[:tag].strip
	  @tag = ResumeExpTag.find_by_id(tag_id.to_i)
	  
	  skill_id = params[:skill] && params[:skill].strip
	  unless skill_id.blank?
	    @skill = if skill_id.size > 6
	      @skill_value = skill_id[6..-1].to_i
	      
	      Skill.find(skill_id[0, 6].to_i)
      else
        Skill.find(skill_id.to_i)
      end
    end
    
    @keyword = params[:keyword] && params[:keyword].strip
    
    job_category_class_id = params[:job_category_class] && params[:job_category_class].strip
    @job_category_class = JobCategoryClass.find(job_category_class_id.to_i)
    
    job_category_id = params[:job_category] && params[:job_category].strip
	  @job_category = JobCategory.find_by_id(job_category_id.to_i)
	  
	  job_district_id = params[:job_district] && params[:job_district].strip
    @job_district = JobDistrict.find(job_district_id.to_i)
    
    
    filters = {}
    
    filters[:edu_level_id] = @level[:id] if @level
    filters[:graduation_year] = @graduation unless @graduation.blank?
    filters[:university_id] = @university[:id] if @university
    filters[:college_id] = @college[:id] if @college
    filters[:major_id] = @major[:id] if @major
    filters[:student_id] = @student.id if @student
    
    filters[:corporation_id] = @corp.id if @corp
    filters[:corporation_industry_category_id] = @corp_industry_category[:id] if @corp_industry_category
    filters[:corporation_industry_id] = @corp_industry[:id] if @corp_industry
    filters[:corporation_nature_id] = @corp_nature[:id] if @corp_nature
    
    filters[:domain_id] = @domain[:id] if @domain
    filters[:exp_tag_id] = @tag[:id] if @tag
    if @skill
      if @skill_value
        filters[:skill_values] = skill_id.to_i
      else
        filters[:skill_id] = @skill[:id]
      end
    end
    filters[:keyword] = @keyword.to_crc32 unless @keyword.blank?
    
    filters[:job_category_class_id] = @job_category_class[:id] if @job_category_class
    filters[:job_category_id] = @job_category[:id] if @job_category
    filters[:job_district_id] = @job_district[:id] if @job_district
    
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
    
    @compared_from && self.class.helpers.get_compared_to(@from, @to, @compared_from)
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
    
    @limit = nil if @hide_filters && @hide_filters.include?(:limit)
  end
  
  
  def get_pie_chart_value(count, total, group_title, color_index)
    percent = (count.to_f/total)*100
		percent_label = Utils.percent(count, total, 1)
		color = self.class.helpers.get_pie_chart_color(color_index)
		
		tip = %Q!<font size="13" face="Verdana" color="#{color}"><b>#{group_title}</b></font>! +
		      %Q! <br> ! +
		      %Q!<font size="12" face="Verdana" color="#{color}">! +
		      %Q!<b>#{count}</b>   -   #{percent_label}! +
		      %Q!</font>! +
		      %Q! <br> ! +
		      %Q!<font size="12" face="Verdana" color="#888888">总计: #{total}</font>!
    
    element = {
      :value => count,
      :colour => color,
      # only show label for those larger than 10%
      :label => (count*10 > total) ? percent_label : "",
      :tip => tip
    }
    
    element
  end
  
  
  def rank(dataset_class)
    prepare_rank_view
    prepare_period(1.month.ago(Date.today))
    compared_to = prepare_compare
    prepare_order
    prepare_limit
    filters = prepare_filters
    
    count_options = {
      :group_by => @group_by.to_s,
      :group_function => :attr,
      :group_clause => "@count #{@order.upcase}",
      :limit => @limit,
      :with => filters
    }.merge(@extra_count_options || {})
    
    @counts = dataset_class.period_group_counts(@teacher.school_id, @from, @to, count_options)
    @counts = @counts_post_proc.call(@counts) if @counts_post_proc
    @total_count = dataset_class.period_total_count(@teacher.school_id, @from, @to, count_options)
    
    group_values = @counts.collect { |record| record[1]["@groupby"] }
    @group_titles = yield(group_values) if block_given?
    
    if @compared_from
      compared_count_options = count_options.merge(
        {
          :group_clause => nil,
          :limit => nil,
          :with => filters.merge(
            {
              @group_by => group_values
            }
          )
        }
      ).merge(@extra_count_options || {})
      
      @compared_counts = dataset_class.period_group_counts(
        @teacher.school_id,
        @compared_from,
        compared_to,
        compared_count_options
      ).inject({}) { |hash, record|
        hash[record[1]["@groupby"]] = record[1]["@count"]
        hash
      }
      
      @compared_total_count = dataset_class.period_total_count(@teacher.school_id, @compared_from, compared_to, count_options)
    end
    
    unless @view == "pie"
      max_value = @counts.inject(0) { |max, record|
        group = record[1]["@groupby"]
        values = [max, record[1]["@count"]]
        values << (@compared_counts[group] || 0) if @compared_from
        values.max
      }
      @max = Utils.top_axis(max_value)
    else
      total_shown_count = 0
      if @compared_from
        compared_total_shown_count = 0
        compared_values = []
      end
      values = @counts.enum_with_index.collect { |count_record, i|
        group = count_record[1]["@groupby"]
				count = count_record[1]["@count"]
				
        total_shown_count += count
        
        if @compared_from
				  compared_count = @compared_counts[group] || 0
				  compared_total_shown_count += compared_count
				  compared_values << get_pie_chart_value(compared_count, @compared_total_count, "#{@group_titles[group]} (对比)", i)
			  end
				
				get_pie_chart_value(count, @total_count, @group_titles[group], i)
      }
      
      else_count = @total_count - total_shown_count
      values << get_pie_chart_value(else_count, @total_count, "其他#{@groups_name}", TeacherStatisticsHelper::Pie_Chart_Colors.size) if else_count > 0
      
      @chart_data = ofc_chart_data(
        :elements => [
          {
            :type => "pie",
            :radius => 100,
            "on-click" => @detail_function,
            :values => values
          }
        ]
      )
      @chart_data.delete(:x_axis)
      @chart_data.delete(:y_axis)
      
      if @compared_from
        compared_else_count = @compared_total_count - compared_total_shown_count
        compared_values << get_pie_chart_value(compared_else_count, @compared_total_count, "其他#{@groups_name} (对比)", TeacherStatisticsHelper::Pie_Chart_Colors.size) if compared_else_count > 0
        
        @compared_chart_data = ofc_chart_data(
          :elements => [
            {
              :type => "pie",
              :alpha => 0.6,
              :radius => 100,
              "on-click" => "compared_#{@detail_function}",
              :values => compared_values
            }
          ]
        )
        @compared_chart_data.delete(:x_axis)
        @compared_chart_data.delete(:y_axis)
      end
    end
  end
  
  
  def viewing_rank(&block)
    @page_title_prefix = "简历查看"
    @dataset_name = "查看简历数"
    @nav = "viewing_nav"
    @dataset_color = "#FF6600"
    @detail_function = "group_view_detail"
    @drill = ["university", "college", "major", "student", "viewing_domain", nil]
    @hide_filters = [:tag, :skill] + (@hide_filters || [])
    
    rank(CorpViewedResume) { |group_values| block.call(group_values) }
    render :action => "rank"
  end
  
  
  def querying_rank(&block)
    @page_title_prefix = "搜索操作"
    @dataset_name = "企业搜索数"
    @nav = "querying_nav"
    @dataset_color = "#0077CC"
    @detail_function = "group_query_detail"
    @hide_filters = [:student] + (@hide_filters || [])
    
    rank(CorpQuery) { |group_values| block.call(group_values) }
    render :action => "rank"
  end
  
end
