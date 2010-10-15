class TeacherStudentInternLogsController < ApplicationController
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_student
  
  before_filter :check_student
  
  before_filter :check_log, :except => [:index, :new, :create,
                                        :set_calling_mark, :clear_calling_mark,
                                        :refresh_matched_student_status]
  
  
  def index
    @logs = InternLog.list_from_student(
      @student.id,
      :order => "occur_at DESC",
      :include => [:job => :corporation]
    )
    
    marked_teacher_id = @student.get_calling_mark
    @marked_teacher = if @teacher.id == marked_teacher_id
      @teacher
    else
      marked_teacher_id && Teacher.try_find(marked_teacher_id)
    end
    
    @job_id = params[:job_id]
  end
  
  
  def new
    @log = InternLog.new(:student_id => @student.id, :teacher_id => @teacher.id)
    
    render(
      :layout => false,
      :inline => %Q!
        <% form_tag "/teachers/#{@teacher.id}/students/#{@student.id}/intern_logs", :method => :post, :id => "log_form" do %>
        	<%=
        	  render(
        	    :partial => "log_form",
        	    :locals => {
        	      :job_id => params[:job_id],
        	      :event_id => params[:event_id]
        	    }
        	  )
        	%>
        <% end %>
      !
    )
  end
  
  def create
    @log = InternLog.new(:student_id => @student.id, :teacher_id => @teacher.id)
    
    save_log(@log)
  end
  
  
  def edit
    render(
      :layout => false,
      :inline => %Q!
        <% form_tag "/teachers/#{@teacher.id}/students/#{@student.id}/intern_logs/#{@log.id}", :method => :put, :id => "log_form" do %>
        	<%=
        	  render(
        	    :partial => "log_form",
        	    :locals => {
        	      :job_id => params[:job_id],
        	      :event_id => params[:event_id]
        	    }
        	  )
        	%>
        <% end %>
      !
    )
  end
  
  def update
    save_log(@log)
  end
  
  
  def destroy
    @log.destroy
    
    render :nothing => true
  end
  
  
  def set_calling_mark
    @student.mark_calling(@teacher.id) unless @student.get_calling_mark
    
    if params[:refresh_status]
      refresh_matched_student_status
    else
      render :partial => "calling_mark", :locals => {:teacher => @teacher}
    end
  end
  def clear_calling_mark
    @student.clear_calling_mark if @teacher.id == @student.get_calling_mark
    
    if params[:refresh_status]
      refresh_matched_student_status
    else
      render :partial => "calling_mark", :locals => {:teacher => nil}
    end
  end
  
  
  def refresh_matched_student_status
    render(
      :layout => false,
			:partial => "/teacher_corporation_jobs/matched_student_status",
			:locals => {
				:intern_log => InternLog.latest_by_students(@student, :include => [:job => :corporation])[@student.id],
				:student => @student
			}
		)
  end
  
  
  private
  
  def save_log(log)
    job = Job.try_find(params[:job])
    job = nil unless @teacher.school_id == (job.corporation && job.corporation.school_id)
    StudentsController.helpers.fill_student_intern_log(log, params, job)
    
    log_saved = log.save
    
    if params[:refresh_status]
      refresh_matched_student_status
    else
      if log_saved
        log.job = job
        render :partial => "log", :collection => [log], :layout => false
      else
        render :nothing => true
      end
    end
  end
  
  
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_student
    jump_to("/errors/unauthorized") unless @teacher.student
  end
  
  
  def check_student
    @student = Student.find(params[:teacher_student_id])
    jump_to("/errors/forbidden") unless @student.school_id == @teacher.school_id
  end
  
  def check_log
    @log = InternLog.find(params[:id])
    jump_to("/errors/forbidden") unless @log.student_id == @student.id
  end
  
end
