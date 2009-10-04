class TeachersController < ApplicationController
  
  before_filter :check_login_for_teacher
  before_filter :check_active, :only => []
  before_filter :check_teacher, :only => [:show]
  
  
  def show
    
  end
  
  
  private
  
  def check_teacher
    
  end
  
end
