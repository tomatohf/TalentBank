class TeacherCorporationJobsController < ApplicationController
  
  layout "teachers"
  
  
  Job_Page_Size = 10
  
  
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
