class ReviseResumesController < ApplicationController
  
  before_filter :check_login_for_account
  
  # before_filter :check_active, :only => []
  
  before_filter :check_account
  
  
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
    # check student belong to school
    # check resume belong to student
    
    # check teacher belong to school
    # check teacher can revision
    
    # check teacher and student of resume are in same school
  end
  
end
