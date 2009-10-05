class TeachersController < ApplicationController
  
  Student_Page_Size = 50
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password, :create_student, :destroy_student]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :only => [:students, :new_student, :create_student, :destroy_student]
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    @teacher.name = params[:name] && params[:name].strip
    @teacher.email = params[:email] && params[:email].strip
    
    if @teacher.save
      flash[:success_msg] = "修改成功, 信息已更新 !"
      return jump_to("/teachers/#{@teacher.id}")
    end
    
    render :action => "edit"
  end
  
  
  def edit_password

  end
  
  def update_password
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = @teacher.password == current_password
    
    if changed
      @teacher.password = password
      @teacher.password_confirmation = password_confirmation
      if @teacher.save
        flash[:success_msg] = "修改成功, 密码已更新 !"
        return jump_to("/teachers/#{@teacher.id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误 !"
    end
    
    render :action => "edit_password"
  end
  
  
  def students
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @students = Student.paginate(
      :page => page,
      :per_page => Student_Page_Size,
      :conditions => ["school_id = ?", @teacher.school_id],
      :order => "created_at DESC"
    )
  end
  
  
  def new_student
    @student = Student.new(:school_id => @teacher.school_id)
  end
  
  def create_student
    @student = Student.new(:school_id => @teacher.school_id)
    
    @student.number = params[:uid] && params[:uid].strip
    @student.password = ::Utils.generate_password(@student.number)
    
    if @student.save
      flash[:success_msg] = "操作成功, 已添加学生 #{@student.number}"
      return jump_to("/teachers/#{@teacher.id}/students")
    end
    
    render :action => "new_student"
  end
  
  
  def destroy_student
    student_id = params[:student_id] && params[:student_id].strip
    
    student = Student.find(student_id)
    if student.school_id == @teacher.school_id
      student.destroy
      flash[:success_msg] = "操作成功, 已删除学生 #{student.number}"
    end
    
    jump_to("/teachers/#{@teacher.id}/students")
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
end
