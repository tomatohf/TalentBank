class SchoolsController < ApplicationController
  
  before_filter :check_login_for_school
  before_filter :check_active, :only => []
  before_filter :check_school, :only => [:show]
  
  
  def show
    
  end
  
  
  private
  
  def check_school
    
  end
  
end
