class StudentsController < ApplicationController
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:update, :update_profile]
  
  before_filter :check_student
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = (@student.password == current_password)
    
    if changed
      @student.password = password
      @student.password_confirmation = password_confirmation
      if @student.save
        flash[:success_msg] = "修改成功, 密码已更新"
        return jump_to("/students/#{@student.id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit"
  end
  
  
  def edit_profile
    @profile = StudentProfile.get_profile(@student.id)
  end
  
  
  def update_profile
    @profile = StudentProfile.get_profile(@student.id)
    
    @profile.phone = params[:phone] && params[:phone].strip
    @profile.email = params[:email] && params[:email].strip
    
    @profile.address = params[:address] && params[:address].strip
    @profile.zip = params[:zip] && params[:zip].strip
    
    @profile.gender = case params[:gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    @profile.political_status_id = params[:political_status]
    
    if @profile.save
      flash[:success_msg] = "修改成功, 个人信息已更新"
      return jump_to("/students/#{@student.id}")
    end
    
    render :action => "edit_profile"
  end
  
  
  private
  
  def check_student
    student_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
end
