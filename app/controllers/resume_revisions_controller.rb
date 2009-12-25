class ResumeRevisionsController < ReviseResumesController
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create]
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_student,
    :only => []
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_teacher,
    :only => [:create]
  )
  
  before_filter :check_revision, :except => [:create]
  
  
  def create
    # put checks within action instead of before filter
    # since this actioin would NOT be cached
    # and the checks would NOT be used by other action
    part_type = ResumePartType.find(params[:type_id].to_i)
    return jump_to("/errors/forbidden") unless part_type
    revision_action = ResumeRevision::Actions.detect{|a| a[:name] == params[:revision_action]}
    return jump_to("/errors/forbidden") unless revision_action
    
    
    revision = ResumeRevision.new(
      :resume_id => @resume.id,
      :teacher_id => @teacher.id,
      :part_type_id => part_type[:id],
      :part_id => params[:part_id],
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
        param_key = part_type[:name].to_sym
        {:content => params[param_key] && params[param_key].strip}
      end
    )
    
    return render(:partial => "/revise_resumes/revision", :object => revision) if revision.save!
    
    render :nothing => true
  end
  
  
  def show
    raise "Not Implemented"
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
