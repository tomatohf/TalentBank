class ResumeCommentsController < ReviseResumesController
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy]
  )
  
  before_filter :check_comment, :except => [:create]
  
  
  def show
    raise "Not Implemented"
  end
  
  
  def create
    account_type_info = ResumeComment::Account_Types.detect{|a| a[:name] == @account_type}
    return jump_to("/errors/forbidden") unless account_type_info
    
    part_type = ResumePartType.find(params[:comment_type_id].to_i)
    
    account = self.instance_variable_get("@#{@account_type.singularize}")
    
    
    comment = ResumeComment.new(
      :resume_id => @resume.id,
      :account_type => account_type_info[:id],
      :account_id => account.id,
      :part_type_id => part_type && part_type[:id],
      :part_id => params[:comment_part_id],
      :content => params[:content] && params[:content].strip
    )
    
    return render(
      :partial => "/revise_resumes/comment",
      :object => comment,
      :locals => {@account_type.to_sym => {account.id => account}}
    ) if comment.save!
    
    render :nothing => true
  end
  
  
  def destroy
    
  end
  
  
  private
  
  def check_comment
    @comment = ResumeComment.find(params[:id])
    jump_to("/errors/forbidden") unless @comment.resume_id == @resume.id
  end
  
end
