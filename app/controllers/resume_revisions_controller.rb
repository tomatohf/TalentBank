class ResumeRevisionsController < ReviseResumesController
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy, :update_applied, :set_applied]
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_student,
    :only => [:update_applied, :diff, :set_applied]
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_teacher,
    :only => [:create, :destroy]
  )
  
  before_filter :check_revision, :except => [:create, :set_applied]
  
  
  def show
    raise "Not Implemented"
  end
  
  
  def create
    # put checks within action instead of before filter
    # since this actioin would NOT be cached
    # and the checks would NOT be used by other action
    part_type = ResumePartType.find(params[:revision_type_id].to_i)
    return jump_to("/errors/forbidden") unless part_type
    revision_action = ResumeRevision::Actions.detect{|a| a[:name] == params[:revision_action]}
    return jump_to("/errors/forbidden") unless revision_action
    
    
    revision = ResumeRevision.new(
      :resume_id => @resume.id,
      :teacher_id => @teacher.id,
      :part_type_id => part_type[:id],
      :part_id => params[:revision_part_id],
      :action => revision_action[:id],
      :applied => false
    )
    revision.fill_data(
      case part_type[:name]
      when "edu"
        {
          :period => params[:edu_period] && params[:edu_period].strip,
          :university => params[:edu_university] && params[:edu_university].strip,
          :college => params[:edu_college] && params[:edu_college].strip,
          :major => params[:edu_major] && params[:edu_major].strip,
          :edu_type => params[:edu_type] && params[:edu_type].strip
        }
      when /_exp$/
        {
          :period => params[:exp_period] && params[:exp_period].strip,
          :title => params[:exp_title] && params[:exp_title].strip,
          :sub_title => params[:exp_sub_title] && params[:exp_sub_title].strip,
          :content => params[:exp_content] && params[:exp_content].strip
        }
      when /_skill$/
        return jump_to("/errors/forbidden") if part_type[:name] == "student_skill" && revision_action[:name] == "update"
        
        {
          :name => params[:skill_name] && params[:skill_name].strip,
          :level => params[:skill_level] && params[:skill_level].strip
        }
      when "list_section"
        {
          :title => params[:section_title] && params[:section_title].strip,
          :content => params[:section_content] && params[:section_content].strip
        }
      else
        return jump_to("/errors/forbidden") if revision_action[:name] == "add"
        
        param_key = part_type[:name].to_sym
        {:content => params[param_key] && params[param_key].strip}
      end
    ) unless revision_action[:name] == "delete"
    
    return render(
      :partial => "/revise_resumes/revision",
      :object => revision,
      :locals => {:teachers => {@teacher.id => @teacher}}
    ) if revision.save!
    
    render :nothing => true
  end
  
  
  def destroy
    return jump_to("/errors/forbidden") unless @revision.teacher_id == @teacher.id
    
    @revision.destroy
    
    render :nothing => true
  end
  
  
  def update_applied
    @revision.applied = (params[:applied].to_i > 0)
    
    @revision.save!
    
    render :nothing => true
  end
  
  
  def set_applied
    ids = params[:revisions] || []
    ids.uniq!
    ids.compact!
    
    ResumeRevision.find(
      :all,
      :conditions => ["id in (?)", ids]
    ).each { |revision|
      if revision.resume_id == @resume.id
        revision.applied = true

        revision.save!
      end
    } if ids.size > 0
    
    render :nothing => true
  end
  
  
  def diff
    render :partial => "/revise_resumes/revision_data", :locals => {:revision => @revision, :diff => true}
  end
  
  
  private
  
  def check_account_type_student
    jump_to("/errors/forbidden") unless params[:account_type] == "students"
  end
  
  
  def check_account_type_teacher
    jump_to("/errors/forbidden") unless params[:account_type] == "teachers"
  end
  
  
  def check_revision
    @revision = ResumeRevision.find(params[:id])
    jump_to("/errors/forbidden") unless @revision.resume_id == @resume.id
  end
  
end
