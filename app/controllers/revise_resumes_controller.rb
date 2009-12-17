class ReviseResumesController < ApplicationController
  
  before_filter :check_login_for_account
  
  # before_filter :check_active, :only => []
  
  before_filter :check_account
  
  before_filter :check_revision
  
  before_filter :check_resume
  
  
  def show
    
  end
  
  
  private
  
  def check_login_for_account
    case (@account_type = params[:account_type])
    when "students"
      check_login_for_student
    when "teachers"
      check_login_for_teacher
    else
      jump_to("/errors/forbidden")
    end
  end
  
  
  def check_account
    account_id = params[:account_id] && params[:account_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == account_id) && ((@account = @account_type.classify.constantize.find(account_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_revision
    jump_to("/errors/unauthorized") if (@account_type == "teachers") && (!@account.revision)
  end
  
  
  def check_resume
    @resume = Resume.find(params[:id])
    
    return jump_to("/errors/forbidden") if @resume.hidden
    
    if @account_type == "students"
      if @resume.student_id == @account.id
        @resume.student = @account
      else
        jump_to("/errors/forbidden")
      end
    elsif @account_type == "teachers"
      jump_to("/errors/forbidden") unless @resume.student.school_id == @account.school_id
    end
  end
  
end
