class StudentsController < ApplicationController
  
  before_filter :check_login_for_student
  before_filter :check_active, :only => []
  before_filter :check_student, :only => [:show]
  
  
  def show
    
  end
  
  
  private
  
  def check_student
    
  end
  
end
