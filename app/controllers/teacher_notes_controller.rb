class TeacherNotesController < ApplicationController
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin
  
  before_filter :check_target
  
  before_filter :check_note, :except => [:new, :create]
  
  
  def new
    @note = TeacherNote.new
  end
  
  def create
    @note = TeacherNote.new(
      :target_type_id => @target_type[:id],
      :target_id => @target.id,
      :teacher_id => @teacher.id,
      :content => params[:notes] && params[:notes].strip
    )

    if @note.save
      return jump_to(back_url)
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @note.content = params[:notes] && params[:notes].strip
    @note.teacher_id = @teacher.id

    if @note.save
      return jump_to(back_url)
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  
  def destroy
    @note.destroy
    
    jump_to(back_url)
  end
  
  
  private
  
  def check_teacher
    @teacher = Teacher.find(session[:account_id])
    jump_to("/errors/forbidden") unless @teacher.school_id == School.get_school_info(@school.abbr)[0]
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def check_target
    @target_type = TeacherNoteTargetType.find(params[:target_type_id].to_i)
    return jump_to("/errors/forbidden") unless @target_type
    
    @target = @target_type[:name].classify.constantize.try_find(params[:target_id])
    return jump_to("/errors/forbidden") unless @target
    
    # potential security issue here ... since only target types that respond to school_id are checked
    jump_to("/errors/forbidden") if @target.respond_to?(:school_id) && @target.school_id != @teacher.school_id
  end
  
  
  def check_note
    @note = TeacherNote.find(params[:id])
    jump_to("/errors/forbidden") unless @note.target_type_id == @target_type[:id] && @note.target_id == @target.id
  end
  
  
  def back_url
    "/teachers/#{@teacher.id}" + @target_type[:url].call(@target)
  end
  
end
