class TeacherStudentsController < ApplicationController
  
  layout "teachers"
  
  
  Student_Page_Size = 10
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :update_intern_profile,
                                          :add_intern_wish, :remove_intern_wish]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_access, :only => [:index]
  
  before_filter :check_resume, :only => [:resume]
  
  before_filter :check_teacher_student, :except => [:index, :resume]
  
  before_filter :check_student, :except => [:index, :new, :create, :resume]
  
  
  def index
    @number = params[:n] && params[:n].strip
    
    @students = unless @number.blank?
      Student.search(
        :conditions => {:number => @number},
        :with => {:school_id => @teacher.school_id},
        :include => request.xhr? ? [] : [:resumes]
      )
    else
      @university_id = params[:u] && params[:u].strip
      @college_id = params[:c] && params[:c].strip
      @major_id = params[:m] && params[:m].strip
      @edu_level_id = params[:e] && params[:e].strip
      @graduation_year = params[:g] && params[:g].strip
      
      @name = params[:name] && params[:name].strip
      
      includes = (request.xhr? || !@teacher.resume) ? [] : [:resumes]
      
      page = params[:page]
      page = 1 unless page =~ /\d+/
      if @university_id.blank? && @college_id.blank? && @major_id.blank? && @edu_level_id.blank? &&
          @graduation_year.blank? && @name.blank?
        Student.paginate(
          :page => page,
          :per_page => Student_Page_Size,
          :conditions => ["school_id = ?", @teacher.school_id],
          :order => "created_at DESC",
          :include => includes
        )
      else
        Student.school_search(
          @name,
          @teacher.school_id, includes,
          page, Student_Page_Size,
          :university_id => @university_id,
          :college_id => @college_id,
          :major_id => @major_id,
          :edu_level_id => @edu_level_id,
          :graduation_year => @graduation_year
        )
      end
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
    StudentsController.helpers.fill_student_editable_fields(@student, params)
    
    if @student.save
      flash.now[:success_msg] = "修改成功, 学生帐号已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
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
    else
      return jump_to(url)
    end
    
    record.save if record.new_record?
    
    jump_to(url)
  end
  
  def remove_intern_wish
    aspect = params[:aspect]
    if ["wish", "blacklist"].map { |t|
      ["industry", "job_category", "corp_nature", "job_district"].map { |a| "#{a}_#{t}" }
    }.flatten.include?(aspect)
      "intern_#{aspect}".camelize.constantize.find(params[:remove_id]).destroy
    end
    
    jump_to("/teachers/#{@teacher.id}/students/#{@student.id}/edit_intern_wishes")
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
