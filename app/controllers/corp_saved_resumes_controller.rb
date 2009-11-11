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
    
    @corp_tags = CorpResumeTagger.corp_tags(@corporation.id, true)
    @total_count = CorpResumeTagger.corp_saved_count(@corporation.id)
    
    @tag_name = params[:tag] && params[:tag].strip
    @taggers = if @tag_name.blank?
      CorpResumeTagger.paginate(
        :page => page,
        :per_page => Resume::Resume_Page_Size,
        :total_entries => @total_count,
        :select => "corp_resume_taggers.resume_id, corp_resume_taggers.created_at",
        :joins => "LEFT JOIN corp_resume_taggers taggers_1 ON corp_resume_taggers.resume_id = taggers_1.resume_id AND corp_resume_taggers.corp_id = taggers_1.corp_id AND corp_resume_taggers.created_at < taggers_1.created_at " +
                  "LEFT JOIN corp_resume_taggers taggers_2 ON corp_resume_taggers.resume_id = taggers_2.resume_id AND corp_resume_taggers.corp_id = taggers_2.corp_id AND corp_resume_taggers.tag_id < taggers_2.tag_id",
        :conditions => ["taggers_1.resume_id IS NULL and taggers_2.tag_id IS NULL and corp_resume_taggers.corp_id = ?", @corporation.id],
        :order => "corp_resume_taggers.created_at DESC"
      )
    else
      tag = CorpResumeTag.get_record(@tag_name)

      CorpResumeTagger.paginate(
        :page => page,
        :per_page => Resume::Resume_Page_Size,
        :total_entries => (tag_info = @corp_tags.detect { |tag_info| tag_info[0] == @tag_name }) && tag_info[1],
        :conditions => ["corp_id = ? and tag_id = ?", @corporation.id, tag.id],
        :order => "created_at DESC"
      ) unless tag.new_record?
    end
    
    if @taggers && @taggers.size > 0
      resume_ids = @taggers.collect { |tagger| tagger.resume_id }
      found_resumes = Resume.find(
        :all,
        :conditions => ["id in (?)", resume_ids],
        :include => [
          {:student => :job_photo}
        ]
      )
      @resumes = resume_ids.collect { |resume_id| found_resumes.detect { |resume| resume.id == resume_id } }
      @resume_tags = CorpResumeTagger.corp_resume_tags(@corporation.id, resume_ids)
    end
  end
  
  
  def edit
    @current_tags = ((params[:current_tags] && params[:current_tags].strip) || "").split
    
    @resume_id = params[:id]
    @corp_tags = CorpResumeTagger.corp_tags(@corporation.id, false)
    
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
