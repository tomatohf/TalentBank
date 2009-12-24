class ResumeCommentsController < ReviseResumesController
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create]
  )
  
  before_filter :check_comment, :except => [:create]
  
  
  def create
    
  end
  
  
  def show
    raise "Not Implemented"
  end
  
  
  private
  
  def check_comment
    @comment = ResumeComment.find(params[:id])
    jump_to("/errors/forbidden") unless @comment.resume_id == @resume.id
  end
  
end
