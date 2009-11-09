class CorpSavedResumesController < ApplicationController
  
  layout "corporations"
  
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:update]
  
  before_filter :check_corporation
  
  before_filter :check_corporation_allow_query
  
  before_filter :check_resume, :only => [
    # no need to check_resume for :edit
    # since it's readonly action and no record would be found
    # :edit
    :update
  ]
  
  
  def index
    
  end
  
  
  def edit
    render :text => "AAAAAAA"
  end
  
  def update
    
  end
  
  
  private
  
  def check_corporation
    corporation_id = params[:corporation_id] && params[:corporation_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == corporation_id) && ((@corporation = Corporation.find(corporation_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_resume
    @resume = Resume.find(params[:id])
    jump_to("/errors/forbidden") unless @resume.student.school_id == @corporation.school_id
  end
  
end
