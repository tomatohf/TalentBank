class StudentsController < ApplicationController
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:update, :update_profile, :update_job_photo, :destroy_job_photo]
  
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
    @profile = StudentProfile.get_record(@student.id)
  end
  
  def update_profile
    @profile = StudentProfile.get_record(@student.id)
    
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
  
  
  def edit_job_photo
    @photo = JobPhoto.get_record(@student.id)
  end
  
  def update_job_photo
    @photo = JobPhoto.get_record(@student.id)
    
    @photo.image = params[:image_file] if params[:image_file]
    
    if params[:crop_x] && params[:crop_y] && params[:crop_w] && params[:crop_h]
      @photo.crop_x = params[:crop_x]
      @photo.crop_y = params[:crop_y]
      @photo.crop_w = params[:crop_w]
      @photo.crop_h = params[:crop_h]
    end
    
    @photo.save
    
    render :action => "edit_job_photo"
  end
  
  
  def destroy_job_photo
    @photo = JobPhoto.get_record(@student.id)
    
    @photo.destroy unless @photo.new_record?
    flash[:success_msg] = "操作成功, 已删除求职照"
    
    jump_to("/students/#{@student.id}/edit_job_photo")
  end
  
  
  private
  
  def check_student
    student_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
end
