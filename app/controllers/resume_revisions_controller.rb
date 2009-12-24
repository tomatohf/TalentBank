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
    type_id = params[:type_id] && params[:type_id].strip
    part_id = params[:part_id] && params[:part_id].strip
    revision_action = params[:revision_action] && params[:revision_action].strip
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
