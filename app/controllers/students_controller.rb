class StudentsController < ApplicationController
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:update, :update_profile,
                                          :update_job_photo, :destroy_job_photo,
                                          :add_skill, :remove_skill, :update_skills]
  
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
    
    @photo.crop_x = params[:crop_x]
    @photo.crop_y = params[:crop_y]
    @photo.crop_w = params[:crop_w]
    @photo.crop_h = params[:crop_h]
    
    if @photo.save
      flash.now[:success_msg] = "操作成功, 求职照已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit_job_photo"
  end
  
  
  def destroy_job_photo
    @photo = JobPhoto.get_record(@student.id)
    
    @photo.destroy unless @photo.new_record?
    flash[:success_msg] = "操作成功, 已删除求职照"
    
    jump_to("/students/#{@student.id}/edit_job_photo")
  end
  
  
  def edit_skills
    @student_skills = StudentSkill.find(:all, :conditions => ["student_id = ?", @student.id])
    @selected_skill_ids = @student_skills.collect { |skill| skill.skill_id }
  end
  
  def add_skill
    skill_id = params[:skill_id] && params[:skill_id].strip
    
    if !skill_id.blank? && (skill = Skill.find(skill_id.to_i))
      student_skill = StudentSkill.get_record(@student.id, skill[:id])
    
      if student_skill.new_record?
        student_skill.value = SkillValueTypes.get_type(skill[:value_type]).default_value
        # no need to save it ...
        # student_skill.save
      end
      
      return render(:partial => "student_skill", :object => student_skill)
    end
    
    render :nothing => true
  end
  
  def remove_skill
    skill_id = params[:skill_id] && params[:skill_id].strip
    
    if !skill_id.blank? && (skill = Skill.find(skill_id.to_i))
      student_skill = StudentSkill.get_record(@student.id, skill[:id])
    
      student_skill.destroy unless student_skill.new_record?
    end
    
    render :nothing => true
  end
  
  def update_skills
    modified_skills = params[:modified_skills] && params[:modified_skills].strip
    
    modified_skill_ids = modified_skills.blank? ? [] : modified_skills.split(",").uniq
    
    saved = true
    modified_skill_ids.each do |skill_id|
      param_key = "skill_#{skill_id}".to_sym
      skill_value = params[param_key] && params[param_key].strip
      if !skill_value.blank? && (skill = Skill.find(skill_id.to_i))
        student_skill = StudentSkill.get_record(@student.id, skill[:id])
        if student_skill.new_record? || (student_skill.value != skill_value.to_i)
          student_skill.value = skill_value
          saved &&= student_skill.save
        end
      end
    end
    
    if saved
      flash[:success_msg] = "保存成功, 技能和证书已更新"
      jump_to("/students/#{@student.id}")
    else
      flash[:error_msg] = "操作失败, 再试一次吧"
      jump_to("/students/#{@student.id}/edit_skills");
    end
  end
  
  
  private
  
  def check_student
    student_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
end
