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
    @logs = InternLog.find(
      :all,
      :conditions => ["student_id = ?", @student.id],
      :order => "occur_at DESC",
      :include => [:corporation]
    )
    
    marked_teacher_id = @student.get_calling_mark
    @marked_teacher = if @teacher.id == marked_teacher_id
      @teacher
    else
      marked_teacher_id && Teacher.try_find(marked_teacher_id)
    end
  end
  
  
  def new
    @log = InternLog.new(:student_id => @student.id, :teacher_id => @teacher.id)
    render(
      :layout => false,
      :inline => %Q!
        <% form_tag "/teachers/#{@teacher.id}/students/#{@student.id}/intern_logs", :method => :post, :id => "log_form" do %>
        	<%= render :partial => "log_form" %>
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
        	<%= render :partial => "log_form" %>
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
    
    render :partial => "calling_mark", :locals => {:teacher => @teacher}
  end
  def clear_calling_mark
    @student.clear_calling_mark if @teacher.id == @student.get_calling_mark
    
    render :partial => "calling_mark", :locals => {:teacher => nil}
  end
  
  
  def refresh_matched_student_status
    render(
      :layout => false,
			:partial => "/teacher_corporation_jobs/matched_student_status",
			:locals => {
				:intern_log => InternLog.latest_by_students(@student, :include => [:corporation])[@student.id],
				:student => @student
			}
		)
  end
  
  
  private
  
  def save_log(log)
    corp = Corporation.get_from_uid(@school.abbr, params[:corporation])
    StudentsController.helpers.fill_student_intern_log(log, params, corp)
    
    if log.save
      log.corporation = corp
      render :partial => "log", :collection => [log], :layout => false
    else
      render :nothing => true
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