class TeacherCorporationJobsController < ApplicationController
  
  layout "teachers"
  
  
  Job_Page_Size = 10
  Intern_Log_Page_Size = 30
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin
  
  before_filter :check_corporation
  
  before_filter :check_job, :except => [:index, :new, :create]
  
  
  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @jobs = Job.paginate(
      :page => page,
      :per_page => Job_Page_Size,
      :conditions => ["corporation_id = ?", @corporation.id],
      :order => "created_at DESC"
    )
    
    @counts = CorporationsController.helpers.prepare_intern_log_counts(
      Proc.new { |filters|
        CorporationsController.helpers.count_intern_log(
          @teacher.school_id,
          :job_id,
          @jobs.map { |job| job.id },
          filters
        )
      },
      params
    )
  end
  
  
  def new
    @job = Job.new(:corporation_id => @corporation.id)
  end
  
  def create
    @job = Job.new(:corporation_id => @corporation.id)
    
    CorporationsController.helpers.fill_corporation_job(@job, params)
    
    if @job.save
      flash[:success_msg] = "操作成功, 已添加企业岗位 #{@job.name}"
      return jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}/jobs")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    CorporationsController.helpers.fill_corporation_job(@job, params)
    
    if @job.save
      flash.now[:success_msg] = "修改成功, 企业岗位已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
  end
  
  
  def show
    
  end
  
  
  def match
    @naive = true
    search
    render :action => "search" unless request.xhr?
  end
  
  def search
    @profile = CorporationProfile.get_record(@corporation.id)
    
    
    @profile.industry_category_id = params[:ic].strip unless params[:ic].nil?
    @profile.industry_id = params[:i].strip unless params[:i].nil?
    @profile.nature_id = params[:n].strip unless params[:n].nil?
    
    @job.category_class_id = params[:jcc].strip unless params[:jcc].nil?
    @job.category_id = params[:jc].strip unless params[:jc].nil?
    @job.district_id = params[:d].strip unless params[:d].nil?
    @job.salary = params[:s].strip unless params[:s].nil?
    
    @job.begin_at = params[:ba].strip unless params[:ba].nil?
    @job.period_id = params[:jp].strip unless params[:jp].nil?
    @job.workday_id = params[:jw].strip unless params[:jw].nil?
    @job.edu_level_id = params[:el].strip unless params[:el].nil?
    @job.graduation_id = params[:jg].strip unless params[:jg].nil?
    @job.major_id = params[:jm].strip unless params[:jm].nil?
    
    
    @not_only_unemployed = (params[:not_only_unemployed] == "true")
    
    
    @page = params[:page]
    @page = @page =~ /\d+/ ? @page.to_i : 1
    @students = Student.job_search(
      @corporation.school_id, @job, @profile, @page,
      :include => [:profile],
      :only_unemployed => !@not_only_unemployed
    )
    @intern_logs = InternLog.latest_by_students(@students, :include => [:job => :corporation])
    
    
    render(
      :layout => false,
      :inline => %Q!
        <% @students.each_with_match do |student, match, counter| %>
  				<%=
  					render(
  						:partial => "student",
  						:locals => {
  						  :student => student,
  						  :match => match,
  						  :counter => counter,
  						  :intern_log => @intern_logs[student.id]
  						}
  					)
  				%>
  			<% end %>
      !
    ) if request.xhr?
  end
  
  
  def intern_logs
    filters = {
      :school_id => @teacher.school_id,
      :job_id => @job.id
    }
    filters[:event_id] = params[:event] unless params[:event].blank?
    filters[:result_id] = params[:result] unless params[:result].blank?
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @intern_logs = InternLog.search(
      :page => page,
      :per_page => Intern_Log_Page_Size,
      :match_mode => InternLog::Search_Match_Mode,
      :order => "@weight DESC, occur_at DESC",
      :with => filters,
      :include => [:student, :teacher]
    )
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def check_corporation
    @corporation = Corporation.find(params[:teacher_corporation_id])
    jump_to("/errors/forbidden") unless @corporation.school_id == @teacher.school_id
  end
  
  def check_job
    @job = Job.find(params[:id])
    jump_to("/errors/forbidden") unless @job.corporation_id == @corporation.id
  end
  
end
