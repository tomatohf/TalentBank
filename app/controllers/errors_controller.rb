class ErrorsController < ApplicationController
  
  skip_before_filter :check_login
  
  
  def inactive
    render :layout => true, :status => 403
  end
  
  
  def forbidden
    render :layout => true, :status => 403
  end
  
  
  def unauthorized
    render :layout => true, :status => 401
  end
  
  
  # --- to override the default rails error pages: 500.html, 422.html, 404.html
  def status
    @code = params[:id] || "500"
    
    # default to render status 500 page
    render :layout => true, :status => @code
  end
  
end
