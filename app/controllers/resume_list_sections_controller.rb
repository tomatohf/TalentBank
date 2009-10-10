class ResumeListSectionsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_list_section, :except => [:index, :create]
  
  
  def index
    @sections = ResumeListSection.find(:all, :conditions => ["resume_id = ?", @resume.id])
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
  
  
  def check_resume_list_section
    @list_section = ResumeListSection.find(params[:id])
    jump_to("/errors/forbidden") unless @list_section.resume_id == @resume.id
  end
  
end
