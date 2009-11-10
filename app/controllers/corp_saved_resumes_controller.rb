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
    page = params[:page]
    page = 1 unless page =~ /\d+/
    CorpResumeTagger.paginate(
      :page => page,
      :per_page => Resume::Resume_Page_Size,
      :select => "corp_resume_taggers.resume_id, corp_resume_taggers.created_at",
      :joins => "LEFT JOIN corp_resume_taggers taggers ON corp_resume_taggers.resume_id = taggers.resume_id AND corp_resume_taggers.corp_id = taggers.corp_id AND corp_resume_taggers.created_at < taggers.created_at",
      :conditions => ["taggers.resume_id IS NULL and corp_resume_taggers.corp_id = ?", @corporation.id],
      :order => "corp_resume_taggers.created_at DESC"
    )    
  end
  
  
  def edit
    @current_tags = ((params[:current_tags] && params[:current_tags].strip) || "").split
    
    @resume_id = params[:id]
    @corp_tags = CorpResumeTagger.corp_tags(@corporation.id, true)
    
    render :layout => false
  end
  
  def update
    tags = ((params[:tags] && params[:tags].strip) || "").split
    
    taggers = CorpResumeTagger.corp_resume_taggers(@corporation.id, @resume.id)
    
    # remove tags
    taggers.each { |tagger| tagger.destroy unless tags.include?(tagger.tag.name) }
    # add new tags
    CorpResumeTag.get_tags(tags - taggers.collect { |tagger| tagger.tag.name }).each do |tag|
      tag.save if tag.new_record?
      
      if tag.id
        tagger = CorpResumeTagger.new(
          :corp_id => @corporation.id,
          :resume_id => @resume.id,
          :tag_id => tag.id
        )
        tags.delete(tag.name) unless tagger.save
      end
    end
    
    render :layout => false, :partial => "/corp_saved_resumes/save_resume_field", :locals => {:resume_id => @resume.id, :tags => tags}
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
