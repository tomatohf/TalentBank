class SchoolsController < ApplicationController
  
  Teacher_Page_Size = 100
  
  
  before_filter :check_login_for_school
  
  before_filter :check_active, :only => [:update, :create_teacher, :destroy_teacher, :adjust_teacher_admin]
  
  before_filter :check_school
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    @s = School.find(@school_id)
    
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = (@s.password == current_password)
    
    if changed
      @s.password = password
      @s.password_confirmation = password_confirmation
      if @s.save
        flash[:success_msg] = "修改成功, 密码已更新"
        return jump_to("/schools/#{@school_id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit"
  end
  
  
  def teachers
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @teachers = Teacher.paginate(
      :page => page,
      :per_page => Teacher_Page_Size,
      :conditions => ["school_id = ?", @school_id],
      :order => "created_at DESC"
    )
  end
  
  
  def new_teacher
    @teacher = Teacher.new(:school_id => @school_id)
  end
  
  def create_teacher
    @teacher = Teacher.new(:school_id => @school_id)
    
    @teacher.uid = params[:uid] && params[:uid].strip
    @teacher.password = ::Utils.generate_password(@teacher.uid)
    @teacher.admin = (params[:admin] == "true")
    
    if @teacher.save
      flash[:success_msg] = "操作成功, 已添加老师 #{@teacher.uid}"
      return jump_to("/schools/#{@school_id}/teachers")
    end
    
    render :action => "new_teacher"
  end
  
  
  def destroy_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    
    teacher = Teacher.find(teacher_id)
    if teacher.school_id.to_s == @school_id
      teacher.destroy
      flash[:success_msg] = "操作成功, 已删除老师 #{teacher.uid}"
    end
    
    jump_to("/schools/#{@school_id}/teachers")
  end
  
  
  def adjust_teacher_admin
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    teacher_admin = (params[:teacher_admin] == "true")
    
    teacher = Teacher.find(teacher_id)
    teacher.admin = teacher_admin
    
    if (teacher.school_id.to_s == @school_id) && teacher.save
      flash[:success_msg] = "操作成功, 已调整老师 #{teacher.uid} 的管理权限"
    end
    
    jump_to("/schools/#{@school_id}/teachers")
  end
  
  
  private
  
  def check_school
    @school_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id] == School.get_school_info(@school.abbr)[0]) && (session[:account_id].to_s == @school_id)
  end
  
end
