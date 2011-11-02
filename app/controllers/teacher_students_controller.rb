class TeacherStudentsController < ApplicationController
  
  layout "teachers"
  
  
  Student_Page_Size = 10
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :update_profile, :update_intern_profile,
                                          :add_intern_wish, :remove_intern_wish, :adjust_status]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_access, :only => [:index]
  
  before_filter :check_resume, :only => [:resume]
  
  before_filter :check_teacher_student, :except => [:index, :resume]
  
  before_filter :check_student, :except => [:index, :new, :create, :resume,
                                            :no_intern_log, :interview_passed, :no_interview_result,
                                            :import]
  
  
  def index
    @number = params[:n] && params[:n].strip
    @intern_log_statistic = false
    csv = (params[:csv] == "true")
    
    includes = (request.xhr? || csv || !@teacher.resume) ? [] : [:resumes]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @students = unless @number.blank?
      Student.paginate(
        :page => page,
        :per_page => Student_Page_Size,
        :conditions => ["school_id = ? and number = ?", @teacher.school_id, @number],
        :include => includes
      )
    else
      @intern_log_statistic = (params[:intern_log_statistic] == "true")
      includes = [:intern_profile, :intern_logs] if @intern_log_statistic
      
      @university_id = params[:u] && params[:u].strip
      @college_id = params[:c] && params[:c].strip
      @major_id = params[:m] && params[:m].strip
      @edu_level_id = params[:e] && params[:e].strip
      @graduation_year = params[:g] && params[:g].strip
      
      @name = params[:name] && params[:name].strip
      
      @complete = if (co = params[:co] && params[:co].strip) == "t"
        true
      elsif co == "f"
        false
      else
        nil
      end
      @gender = if (ge = params[:ge] && params[:ge].strip) == "t"
        true
      elsif ge == "f"
        false
      else
        nil
      end
      
      @created_at_from = params[:created_at_from].blank? ? nil : (Time.parse(params[:created_at_from]) rescue nil)
      @created_at_to = params[:created_at_to].blank? ? nil : (Time.parse(params[:created_at_to]) rescue nil)
      
      @begin_at_from = params[:begin_at_from].blank? ? nil : (Time.parse(params[:begin_at_from]) rescue nil)
      @begin_at_to = params[:begin_at_to].blank? ? nil : (Time.parse(params[:begin_at_to]) rescue nil)
      begin_at_range = if @begin_at_from.blank? && @begin_at_to.blank?
        nil
      else
        infinit_period = 10.years
        @begin_at_from ||= infinit_period.ago(Time.parse(InternLog.intern_begin_at))
        @begin_at_to ||= infinit_period.since(Time.now)
        @begin_at_from .. @begin_at_to
      end
      
      @job_major_id = params[:im] && params[:im].strip
      
      per_page = Student_Page_Size
      if csv
        page = 1
        
        limit = params[:limit]
        per_page = (limit =~ /\d+/) ? limit.to_i : 10000
      end
      
      if @university_id.blank? && @college_id.blank? && @major_id.blank? && @edu_level_id.blank? &&
          @graduation_year.blank? && @name.blank? && @complete.nil? && @gender.nil? &&
          @created_at_from.blank? && @created_at_to.blank? && begin_at_range.blank? &&
          @job_major_id.blank?
        Student.paginate(
          :page => page,
          :per_page => per_page,
          :conditions => ["school_id = ?", @teacher.school_id],
          :order => "created_at DESC",
          :include => includes
        )
      else
        Student.school_search(
          @name,
          @teacher.school_id, includes,
          page, per_page,
          :university_id => @university_id,
          :college_id => @college_id,
          :major_id => @major_id,
          :edu_level_id => @edu_level_id,
          :graduation_year => @graduation_year,
          :complete => @complete,
          :gender => @gender,
          :created_at => [@created_at_from, @created_at_to],
          :begin_at_range => begin_at_range,
          :job_major_id => @job_major_id
        )
      end
    end
    
    if csv
      csv_data = FasterCSV.generate do |csv|
        header = ["学生编号", "学号", "姓名", "大学", "学院", "专业", "学历", "毕业时间"]
        header.concat(
          [
            "入库时间", "上岗时间", "最后通知面试时间", "相关专业",
            "总数", "接受面试", "拒绝面试", "面试通过", "面试失败", "面试没去", "实习到期", "实习后留用", "实习中流动", "实习中劝退"
          ]
        ) if @intern_log_statistic
  			
        csv << header
        
        @students.each do |student|
          university = student.university_id && University.find(student.university_id)
          college = university && College.find(university[:id], student.college_id)
          major = college && Major.find(college[:id], student.major_id)
          edu_level = student.edu_level_id && EduLevel.find(student.edu_level_id)
          
					row = [
					  student.id,
					  student.number,
					  student.name,
					  university && university[:name],
					  college && college[:name],
					  major && major[:name],
					  edu_level && edu_level[:name],
					  student.graduation_year
					]
					
					if @intern_log_statistic
            intern_profile = student.intern_profile
            job_major = intern_profile && intern_profile.major_id && JobMajor.find(intern_profile.major_id)
            
					  intern_logs = student.intern_logs
          	intern_log_groups = intern_logs.group_by { |log| log.result_id }

          	sort_block = Proc.new { |x, y|
          		x[:id] <=> y[:id]
          	}
          	
          	latest_inform_interview_log = intern_logs.select { |log|
          		InternLogEvent.inform_interview[:id] == log.event_id
          	}.sort { |x, y|
          		y.occur_at <=> x.occur_at
          	}.first
          	
          	row.concat(
          	  [
          	    ApplicationController.helpers.format_date(student.created_at),
    					  ApplicationController.helpers.format_date(intern_profile && intern_profile.begin_at),
    					  latest_inform_interview_log && ApplicationController.helpers.format_datetime(
    					    latest_inform_interview_log.occur_at
    					  ),
    					  job_major && job_major[:name],
                intern_logs.size
          	  ]
          	)
          	InternLogEvent.data.sort(&sort_block).each do |event|
              InternLogEventResult.find_group(event[:id]).sort(&sort_block).each do |result|
                row << (intern_log_groups[result[:id]] || []).size
        			end
            end
				  end
					
          csv << row
        end
      end
      
      return send_data(
        add_utf8_bom(csv_data),
        :filename => "students.csv",
        :type => :csv,
        :disposition => "attachment"
      )
    end
    
    if request.xhr?
      return render(
        :layout => false,
        :inline => %Q!
          <% @students.each do |student| %>
            <a href="#" id="filter_student_<%= student.id %>" class="filter_item_link">
              <%= h(student.name) %></a>
          <% end %>
          
          <%= paging_buttons(@students) %>
        !
      )
    end
  end
  
  
  def resume
    if @resume.hidden
      return render(
        :layout => true,
        :inline => %Q!
          <div style="font-size: 14px; padding-top: 30px;">
            <div class="warn_msg">简历已被删除 ...</div>
          </div>
        !
      )
    end
    
    
    @taggers = @resume.exp_taggers
    @taggers.to_s # for eager loading ...
  end
  
  
  def new
    @student = Student.new(:school_id => @teacher.school_id)
  end
  
  def create
    @student = Student.new(:school_id => @teacher.school_id)
    
    @student.number = params[:number] && params[:number].strip
    @student.password = params[:password] && params[:password].strip
    
    StudentsController.helpers.fill_student_editable_fields(@student, params)
    
    if @student.save
      flash[:success_msg] = "操作成功, 已添加学生帐号 #{@student.name} (#{@student.number})"
      return jump_to("/teachers/#{@teacher.id}/students")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @student.number = params[:number] && params[:number].strip
    StudentsController.helpers.fill_student_editable_fields(@student, params)
    
    if @student.save
      flash.now[:success_msg] = "修改成功, 学生帐号已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
  end
  
  
  def edit_profile
    @profile = StudentProfile.get_record(@student.id)
  end
  
  def update_profile
    @profile = StudentProfile.get_record(@student.id)
    
    StudentsController.helpers.fill_student_profile(@profile, params)
    
    if @profile.save
      flash.now[:success_msg] = "修改成功, 学生信息已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit_profile"
  end
  
  
  def edit_intern_profile
    @profile = InternProfile.get_record(@student.id)
  end
  
  def update_intern_profile
    @profile = InternProfile.get_record(@student.id)
    
    StudentsController.helpers.fill_student_intern_profile(@profile, params)
    
    if @profile.save
      flash.now[:success_msg] = "保存成功, 实习信息已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit_intern_profile"
  end
  
  
  def edit_intern_wishes
    @industry_wishes = InternIndustryWish.list_from_student(@student.id)
    @industry_blacklists = InternIndustryBlacklist.list_from_student(@student.id)
    @job_category_wishes = InternJobCategoryWish.list_from_student(@student.id)
    @job_category_blacklists = InternJobCategoryBlacklist.list_from_student(@student.id)
    @corp_nature_wishes = InternCorpNatureWish.list_from_student(@student.id)
    @corp_nature_blacklists = InternCorpNatureBlacklist.list_from_student(@student.id)
    @job_district_wishes = InternJobDistrictWish.list_from_student(@student.id)
    @job_district_blacklists = InternJobDistrictBlacklist.list_from_student(@student.id)
    @corporation_wishes = InternCorporationWish.list_from_student(@student.id, :include => [:corporation])
    @corporation_blacklists = InternCorporationBlacklist.list_from_student(@student.id, :include => [:corporation])
    @job_wishes = InternJobWish.list_from_student(@student.id, :include => [:job])
    @job_blacklists = InternJobBlacklist.list_from_student(@student.id, :include => [:job])
  end
  
  def add_intern_wish
    url = "/teachers/#{@teacher.id}/students/#{@student.id}/edit_intern_wishes"
    
    type = if ["wish", "blacklist"].include?(type = params[:type])
      type.capitalize 
    else
      jump_to(url)
    end
    
    record = case params[:aspect]
    when "industry"
      "InternIndustry#{type}".constantize.get_record(
        @student.id,
        params[:industry_category], params[:industry]
      )
    when "job_category"
      "InternJobCategory#{type}".constantize.get_record(
        @student.id,
        params[:job_category_class], params[:job_category]
      )
    when "corp_nature"
      "InternCorpNature#{type}".constantize.get_record(@student.id, params[:corp_nature])
    when "job_district"
      "InternJobDistrict#{type}".constantize.get_record(@student.id, params[:job_district])
    when "corporation"
      "InternCorporation#{type}".constantize.get_record(@student.id, params[:corporation])
    when "job"
      "InternJob#{type}".constantize.get_record(@student.id, params[:job])
    else
      return jump_to(url)
    end
    
    record.save if record.new_record?
    
    jump_to(url)
  end
  
  def remove_intern_wish
    aspect = params[:aspect]
    if ["wish", "blacklist"].map { |t|
      ["industry", "job_category", "corp_nature", "job_district", "corporation", "job"].map do |a|
        "#{a}_#{t}"
      end
    }.flatten.include?(aspect)
      "intern_#{aspect}".camelize.constantize.find(params[:remove_id]).destroy
    end
    
    jump_to("/teachers/#{@teacher.id}/students/#{@student.id}/edit_intern_wishes")
  end
  
  
  def show
    @profile = StudentProfile.get_record(@student.id)
    @intern_profile = InternProfile.get_record(@student.id)
    
    @target_type = TeacherNoteTargetType.find_by(:name, "students")
    @notes = TeacherNote.get_from_target(@target_type[:id], @student.id)
    
    @industry_wishes = InternIndustryWish.list_from_student(@student.id)
    @job_category_wishes = InternJobCategoryWish.list_from_student(@student.id)
    @corp_nature_wishes = InternCorpNatureWish.list_from_student(@student.id)
    @job_district_wishes = InternJobDistrictWish.list_from_student(@student.id)
    @corporation_wishes = InternCorporationWish.list_from_student(@student.id, :include => [:corporation])
    @job_wishes = InternJobWish.list_from_student(@student.id, :include => [:job])
  end
  
  
  def adjust_status
    field = params[:status] && params[:status].strip
    
    @student.send("#{field}=", params[:yes] == "true")
    
    @student.save!
    
    render :partial => "status_field", :locals => {:student => @student, :field => field}
  end
  
  
  def no_intern_log
    respond_to do |format|
      options = {
        # :joins => "INNER JOIN corporations ON corporations.id = jobs.corporation_id",
        # :conditions => ["school_id = ?", @teacher.school_id],
        :conditions => ["school_id = ? and id NOT in (select DISTINCT student_id from intern_logs)", @teacher.school_id],
        :include => [:intern_profile]
      }
      
      format.html {
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @students = Student.paginate(
          options.merge(
            :page => page,
            :per_page => 15
          )
        )
      }
      
      format.csv {
        students = Student.find(:all, options)
        
        csv_data = FasterCSV.generate do |csv|
          header = ["编号", "姓名", "学校", "学历", "毕业时间", "上岗时间", "工作期限", "每周工作时间", "相关专业", "入库时间", "实习意向"]
    			
          csv << header
          
          students.each do |student|
            university = student.university_id && University.find(student.university_id)
            edu_level = student.edu_level_id && EduLevel.find(student.edu_level_id)
            intern_profile = student.intern_profile || InternProfile.new
            period = intern_profile.period_id && JobPeriod.find(intern_profile.period_id)
            workday = intern_profile.workday_id && JobWorkday.find(intern_profile.workday_id)
            major = intern_profile.major_id && JobMajor.find(intern_profile.major_id)

  					row = [
  					  student.id,
  					  student.get_name,
  					  university && university[:name],
  					  edu_level && edu_level[:name],
  					  student.graduation_year,
  					  ApplicationController.helpers.format_date(intern_profile.begin_at),
  					  period && period[:name],
  					  workday && workday[:name],
  					  major && major[:name],
  					  ApplicationController.helpers.format_date(student.created_at),
  					  intern_profile.intention
  					]
  					
            csv << row
          end
        end
        
        send_data(
          add_utf8_bom(csv_data),
          :filename => "students_without_intern_log.csv",
          :type => :csv,
          :disposition => "attachment"
        )
      }
    end
  end
  
  
  def interview_passed
    respond_to do |format|
      options = {
        :select => "students.*, jobs.id as job_id, jobs.name as job_name, corporations.id as corporation_id, corporations.name as corporation_name, corporation_profiles.job_district_id as corporation_job_district_id, intern_logs.occur_at as occur_at",
        :joins => "INNER JOIN (intern_logs INNER JOIN (jobs INNER JOIN (corporations INNER JOIN corporation_profiles ON corporations.id = corporation_profiles.corporation_id) ON corporations.id = jobs.corporation_id) ON jobs.id = intern_logs.job_id) ON students.id = intern_logs.student_id",
        :conditions => [
          "corporations.school_id = ? and intern_logs.event_id = ? and intern_logs.result_id = ?",
          @teacher.school_id,
          InternLogEvent.interview_result[:id], InternLogEventResult.interview_result_passed[:id]
        ],
        :include => [:profile, :intern_profile, :intern_logs]
      }
      
      format.html {
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @students = Student.paginate(
          options.merge(
            :page => page,
            :per_page => 15
          )
        )
      }
      
      format.csv {
        students = Student.find(:all, options)
        
        csv_data = FasterCSV.generate do |csv|
          header = ["学号", "姓名", "学校", "学历", "毕业时间",
                    "性别", "政治面貌", "上岗时间", "工作期限", "每周工作时间", "户口", "其他信息", "相关专业",
                    "公司编号", "公司名称", "区域", "岗位编号", "岗位名称", "发生时间", "实习记录条数"]
    			
          csv << header
          
          students.each do |student|
            university = student.university_id && University.find(student.university_id)
            edu_level = student.edu_level_id && EduLevel.find(student.edu_level_id)
            profile = student.profile || StudentProfile.new
            political_status = profile.political_status_id && PoliticalStatus.find(profile.political_status_id)
            intern_profile = student.intern_profile || InternProfile.new
            period = intern_profile.period_id && JobPeriod.find(intern_profile.period_id)
            workday = intern_profile.workday_id && JobWorkday.find(intern_profile.workday_id)
            major = intern_profile.major_id && JobMajor.find(intern_profile.major_id)
            job_district = student.corporation_job_district_id && JobDistrict.find(student.corporation_job_district_id.to_i)

  					row = [
  					  student.number,
  					  student.get_name,
  					  university && university[:name],
  					  edu_level && edu_level[:name],
  					  student.graduation_year,
  					  
              profile.gender.nil? ? "" : (profile.gender ? "男" : "女"),
  					  political_status && political_status[:name],
  					  ApplicationController.helpers.format_date(intern_profile.begin_at),
  					  period && period[:name],
  					  workday && workday[:name],
  					  intern_profile.birthplace,
  					  intern_profile.desc,
  					  major && major[:name],
  					  
  					  student.corporation_id,
  					  student.corporation_name,
    					job_district && job_district[:name],
  					  student.job_id,
  					  student.job_name,
  					  
              student.occur_at,
  					  student.intern_logs.size
  					]
  					
            csv << row
          end
        end
        
        send_data(
          add_utf8_bom(csv_data),
          :filename => "interview_passed_students.csv",
          :type => :csv,
          :disposition => "attachment"
        )
      }
    end
  end
  
  
  def no_interview_result
    respond_to do |format|
      # TODO - if we group the results also by job, we'd better also include job field in the index.
      # while, currently the job field is *NOT* included in the index definition,
      # but the MySQL explain output and performance is NOT so bad.
      by_job = true
      options = {
        :select => "students.id as student_id, students.number as student_number, students.name as student_name, jobs.id as job_id, jobs.name as job_name, corporations.id as corporation_id, corporations.name as corporation_name, teachers.name as teacher_name, intern_logs.occur_at, intern_logs.teacher_id",
        :joins => "LEFT OUTER JOIN intern_logs logs ON intern_logs.student_id = logs.student_id#{by_job ? ' and intern_logs.job_id = logs.job_id' : ''} and intern_logs.occur_at < logs.occur_at LEFT OUTER JOIN students ON intern_logs.student_id = students.id LEFT OUTER JOIN jobs ON intern_logs.job_id = jobs.id LEFT OUTER JOIN corporations ON jobs.corporation_id = corporations.id LEFT OUTER JOIN teachers ON corporations.teacher_id = teachers.id",
        :conditions => [
          "logs.student_id IS NULL and corporations.school_id = ? and intern_logs.event_id = ? and intern_logs.result_id = ? and intern_logs.occur_at < ?",
          @teacher.school_id,
          InternLogEvent.inform_interview[:id], InternLogEventResult.inform_interview_accepted[:id], Time.now
        ],
        :include => [:teacher]
      }
      
      format.html {
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @intern_logs = InternLog.paginate(
          options.merge(
            :page => page,
            :per_page => 15
          )
        )
      }
      
      format.csv {
        intern_logs = InternLog.find(:all, options)
        
        csv_data = FasterCSV.generate do |csv|
          header = ["学生编号", "学号", "姓名",
                    "公司编号", "公司名称", "岗位编号", "岗位名称", "记录老师", "企业负责人", "记录时间"]
    			
          csv << header
          
          intern_logs.each do |log|
  					row = [
  					  log.student_id,
  					  log.student_number,
  					  log.student_name,
  					  
  					  log.corporation_id,
  					  log.corporation_name,
  					  log.job_id,
  					  log.job_name,
  					  
  					  log.teacher && log.teacher.get_name,
  					  log.teacher_name,
  					  ApplicationController.helpers.format_datetime(log.occur_at)
  					]
  					
            csv << row
          end
        end
        
        send_data(
          add_utf8_bom(csv_data),
          :filename => "students_without_interview_result.csv",
          :type => :csv,
          :disposition => "attachment"
        )
      }
    end
  end
  
  
  def import
    if request.post?
      students = JSON.parse(params[:students] && params[:students].strip) rescue []
      
      return render(
        :layout => false,
        :json => {
          :finished => false,
          :message => "无法解析出可用的数据"
        }.to_json
      ) unless students.kind_of?(Array) && students.size > 0
      
      saved, failed, exceptions = StudentsController.helpers.import(students, @school, @teacher.school_id)
      
      import_log = StudentImport.new(
        :school_id => @teacher.school_id,
        :teacher_id => @teacher.id,
        :data => students.to_json,
        :saved => saved.to_json,
        :failed => failed.to_json,
        :exceptions => exceptions.to_json
      )
      import_log.save
      
      render(
        :layout => false,
        :json => {
          :finished => true,
          :saved_count => saved.size,
          :failed => failed.map { |s| s.to_json },
          :exceptions => exceptions
        }.to_json
      )
    end
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_access
    jump_to("/errors/unauthorized") unless @teacher.student || @teacher.resume
  end
  
  
  def check_teacher_student
    jump_to("/errors/unauthorized") unless @teacher.student
  end
  
  
  def check_student
    @student = Student.find(params[:id])
    jump_to("/errors/forbidden") unless @student.school_id == @teacher.school_id
  end
  
  
  def check_resume
    return jump_to("/errors/unauthorized") unless @teacher.resume
    
    @resume = Resume.find(params[:id])
    jump_to("/errors/forbidden") unless @resume.student.school_id == @teacher.school_id
  end
  
end
