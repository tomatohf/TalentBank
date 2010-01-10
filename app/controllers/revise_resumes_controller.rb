class ReviseResumesController < ApplicationController
  
  before_filter :check_login_for_account
  
  before_filter :check_account
  
  before_filter :check_teacher_revision
  
  before_filter :check_resume
  
  
  def show
    if @resume.hidden
      return render(
        :layout => @account_type,
        :inline => %Q!
          <div style="font-size: 14px; padding-top: 30px;">
            <div class="warn_msg">简历已被删除 ...</div>
          </div>
        !
      )
    end
    
    
    @taggers = @resume.exp_taggers
    @taggers.to_s # for eager loading ...
    
    @revisions = @resume.revisions
    @comments = @resume.comments
    
    teachers_id = @revisions.map(&:teacher_id)
    students_id = []
    @comments.each do |comment|
      account_type = AccountType.find(comment.account_type_id) || {}
      eval("#{account_type[:name]}_id") << comment.account_id
    end
    
    @teachers = (teachers_id.size > 0) && Teacher.find(
      :all,
      :conditions => ["id in (?)", teachers_id.uniq.compact]
    ).inject({}) do |hash, teacher|
			hash[teacher.id] = teacher
			hash
		end
    # @students = (students_id.size > 0) && Student.find(
    #   :all,
    #   :conditions => ["id in (?)", students_id.uniq.compact]).inject({}
    # ) do |hash, student|
    #   hash[student.id] = student
    #   hash
    # end
    @students = if @student
      # no need to query DB for students,
      # since only the owner student of resume can be here
      {@student.id => @student}
    else
      {@resume.student_id => @resume.student}
    end
    
    render :layout => @account_type
  end
  
  
  private
  
  def check_teacher_revision
    jump_to("/errors/unauthorized") if @teacher && (!@teacher.revision)
  end
  
  
  def check_resume
    @resume = Resume.find(params[:revise_resume_id] || params[:id])
    
    if @student
      if @resume.student_id == @student.id
        @resume.student = @student
      else
        return jump_to("/errors/forbidden")
      end
    end
    
    if @teacher
      return jump_to("/errors/forbidden") unless @resume.student.school_id == @teacher.school_id
    end
  end
  
end
