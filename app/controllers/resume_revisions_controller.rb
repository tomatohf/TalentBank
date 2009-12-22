class ResumeRevisionsController < ApplicationController
  
  before_filter :check_login_for_account
  
  before_filter :check_active, :only => [:create]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_revision
  
  before_filter :check_resume
  
  before_filter :check_revision, :except => [:new, :create]
  
  # to improve performance, since the new action does NOT change any data
  skip_before_filter :check_teacher, :check_teacher_revision, :check_resume, :only => [:new]
  
  
  def new
    render :text => "AAAA"
  end
  
  def create
    
  end
  
  
  private
  
  def check_login_for_account
    if params[:account_type] == "teachers"
      check_login_for_teacher
    else
      jump_to("/errors/forbidden")
    end
  end
  
  
  def check_teacher
    teacher_id = params[:account_id] && params[:account_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_revision
    jump_to("/errors/unauthorized") unless @teacher.revision
  end
  
  
  def check_resume
    @resume = Resume.find(params[:revise_resume_id])
    jump_to("/errors/forbidden") if @resume.hidden || @resume.student.school_id != @teacher.school_id
  end
  
  
  def check_revision
    @revision = ResumeRevision.find(params[:id])
    jump_to("/errors/forbidden") unless @revision.resume_id == @resume.id
  end
  
end
