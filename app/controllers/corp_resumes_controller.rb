class CorpResumesController < ApplicationController
  
  layout "corporations"
  
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:add_skill, :create_query]
  
  before_filter :check_corporation
  
  before_filter :check_corporation_allow_query
  
  before_filter :check_resume, :only => [:show]
  
  
  def index
    conditions = params[:q] && params[:q].strip
    
    @query = CorpQuery.parse_from_conditions(conditions)
    @query_tags, @query_skills = @query.tags_and_skills
    
    
    unless conditions.blank?
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @resumes = Resume.corp_search(@query, @corporation, page, @query_tags, @query_skills)
      
      @resume_tags = CorpResumeTagger.corp_resume_tags(@corporation.id, @resumes)
    end
  end
  
  def add_skill
    skill_id = params[:skill_id] && params[:skill_id].strip
    
    if !skill_id.blank?
      return render(:partial => "query_skill", :object => [skill_id.to_i, nil])
    end
    
    render :nothing => true
  end
  
  def create_query
    q = params[:q] && params[:q].strip
    
    from_saved = !q.blank?
    
    conditions = if from_saved
      q
    else
      self.class.helpers.collect_query_conditions(params, :keyword)
    end
    
    
    # ========== record the query to db ==========
    query = CorpQuery.parse_from_conditions(conditions)
    query.corporation_id = @corporation.id
    query.from_saved = from_saved
    # the params[:keyword] has been encodeURIComponent by javascript
    # and should be only used in URL
    query.keyword = params[:keyword_input] && params[:keyword_input].strip
    query.save
    # ========== end ==========
    
    
    return jump_to("/corporations/#{@corporation.id}/corp_resumes?q=#{conditions}")
  end
  
  
  def show
    @available = @resume.available?(@corporation.id)
    if @available
      # ========== record the view to db ==========
      CorpViewedResume.record(@corporation.id, @resume.id)
      # ========== end ==========
      
      @tags = CorpResumeTagger.corp_resume_tags(@corporation.id, @resume.id)[@resume.id] || []
    end
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
