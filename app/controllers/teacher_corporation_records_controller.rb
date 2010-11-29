class TeacherCorporationRecordsController < ApplicationController
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin
  
  before_filter :check_corporation
  
  before_filter :check_record, :except => [:new, :create]
  
  
  def new
    @record = CorporationRecord.new
  end
  
  def create
    @record = CorporationRecord.new(:corporation_id => @corporation.id)
    @record.notes = params[:notes] && params[:notes].strip

    if @record.save
      return jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @record.notes = params[:notes] && params[:notes].strip

    if @record.save
      return jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  
  def destroy
    @record.destroy
    
    jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}")
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def check_corporation
    @corporation = Corporation.find(params[:teacher_corporation_id])
    jump_to("/errors/forbidden") unless @corporation.school_id == @teacher.school_id
  end
  
  def check_record
    @record = CorporationRecord.find(params[:id])
    jump_to("/errors/forbidden") unless @record.corporation_id == @corporation.id
  end
  
end
