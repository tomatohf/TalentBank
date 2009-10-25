class ResumeExpSectionsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_exp_section, :except => [:index, :new, :create]
  
  
  def index
    @sections = ResumeExpSection.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id],
      :include => [:exps]
    )
    
    @tags = ResumeExpTag.data[@resume.domain_id] || []
    
    @taggers = ResumeExpTagger.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id]
    )
  end
  
  
  def new
    @section = ResumeExpSection.new(:resume_id => @resume.id)
  end
  
  def create
    @section = ResumeExpSection.new(:resume_id => @resume.id)
    
    @section.title = params[:title] && params[:title].strip
    
    if @section.save
      flash[:success_msg] = "操作成功, 已添加经历块 #{@section.title}"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @section.title = params[:title] && params[:title].strip
    
    if @section.save
      flash[:success_msg] = "操作成功, 经历块 #{@section.title} 已更新"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @section.destroy
    
    flash[:success_msg] = "操作成功, 已删除经历块 #{@section.title}"
  
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
  end
  
  
  private
  
  def check_student
    student_id = params[:student_id] && params[:student_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_resume
    @resume = Resume.find(params[:resume_id])
    jump_to("/errors/forbidden") unless @resume.student_id == @student.id
  end
  
  
  def check_resume_exp_section
    @section = ResumeExpSection.find(params[:id])
    jump_to("/errors/forbidden") unless @section.resume_id == @resume.id
  end
  
end
