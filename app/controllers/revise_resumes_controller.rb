class ReviseResumesController < ApplicationController
  
  before_filter :check_login_for_account
  
  before_filter :check_account
  
  before_filter :check_teacher_revision
  
  before_filter :check_resume
  
  
  def show
    @taggers = @resume.exp_taggers
    @taggers.to_s # for eager loading ...
    
    @revisions = @resume.revisions
    @comments = @resume.comments
    
    teachers_id = @revisions.map(&:teacher_id)
    students_id = []
    @comments.each { |comment| eval("#{comment.account_type}_id") << comment.account_id }
    
    @teachers = (teachers_id.size > 0) && Teacher.find(
      :all,
      :conditions => ["id in (?)", teachers_id]
    ).inject({}) do |hash, teacher|
			hash[teacher.id] = teacher
			hash
		end
		@students = (students_id.size > 0) && Student.find(
		  :all,
		  :conditions => ["id in (?)", students_id]).inject({}
		) do |hash, student|
			hash[student.id] = student
			hash
		end
    
    render :layout => @account_type
  end
  
  
  private
  
  def check_login_for_account
    case (@account_type = params[:account_type])
    when "students"
      check_login_for_student
    when "teachers"
      check_login_for_teacher
    else
      jump_to("/errors/forbidden")
    end
  end
  
  
  def check_account
    account_id = params[:account_id] && params[:account_id].strip
    jump_to("/errors/forbidden") unless (
      session[:account_id].to_s == account_id
    ) && (
      (
        self.instance_variable_set(
          "@#{@account_type.singularize}",
          @account_type.classify.constantize.find(account_id)
        )
      ).school_id == School.get_school_info(@school.abbr)[0]
    )
  end
  
  
  def check_teacher_revision
    jump_to("/errors/unauthorized") if @teacher && (!@teacher.revision)
  end
  
  
  def check_resume
    @resume = Resume.find(params[:revise_resume_id] || params[:id])
    
    return jump_to("/errors/forbidden") if @resume.hidden
    
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
