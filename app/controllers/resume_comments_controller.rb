class ResumeCommentsController < ReviseResumesController
  
  skip_before_filter :check_active
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy]
  )
  
  before_filter :check_comment, :except => [:create]
  
  
  def show
    jump_to("/errors/forbidden")
  end
  
  
  def create
    account_type = AccountType.find_by(:name, @account_type)
    return jump_to("/errors/forbidden") unless account_type
    
    part_type = ResumePartType.find(params[:comment_type_id].to_i)
    
    account = self.instance_variable_get("@#{@account_type.singularize}")
    
    
    comment = ResumeComment.new(
      :resume_id => @resume.id,
      :account_type_id => account_type[:id],
      :account_id => account.id,
      :part_type_id => part_type && part_type[:id],
      :part_id => params[:comment_part_id],
      :content => params[:content] && params[:content].strip
    )
    
    if comment.save!
      generate_notice(account_type, account, params[:involved_teachers])
      
      return render(
        :partial => "/revise_resumes/comment",
        :object => comment,
        :locals => {@account_type.to_sym => {account.id => account}}
      )
    end
    
    render :nothing => true
  end
  
  
  def destroy
    unless @account_type == (AccountType.find(@comment.account_type_id) || {})[:name] &&
            self.instance_variable_get("@#{@account_type.singularize}").id == @comment.account_id
      return jump_to("/errors/forbidden")
    end
    
    @comment.destroy
    
    render :nothing => true
  end
  
  
  private
  
  def check_comment
    @comment = ResumeComment.find(params[:id])
    jump_to("/errors/forbidden") unless @comment.resume_id == @resume.id
  end
  
  
  def generate_notice(account_type, account, involved_teachers)
    noticed_account_type, noticed_account_ids = if @student
      # check the school_id of involved_teachers
      teacher_ids = involved_teachers.split(",")
      teacher_ids = Teacher.find(:all, :conditions => ["id in (?)", teacher_ids]).select{ |teacher|
        teacher.school_id = @student.school_id
      }.map(&:id) if teacher_ids.size > 0
      
      ["teachers", teacher_ids]
    else
      ["students", [@resume.student_id]]
    end
    domain = ResumeDomain.find(@resume.domain_id)
    
    noticed_account_ids.each do |noticed_account_id|
      Notice.generate(
        noticed_account_type, noticed_account_id, "add_resume_comment",
        :account => "#{account.get_name}(#{account_type[:label]})",
        :resume => "#{domain[:name]}的简历",
        :url => "/#{noticed_account_type}/#{noticed_account_id}/revise_resumes/#{@resume.id}"
      )
    end
  end
  
end
