class StudentsController < ApplicationController
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:update, :update_profile,
                                          :update_job_photo, :destroy_job_photo,
                                          :add_skill, :remove_skill, :update_skills,
                                          :create_blocked_corp, :destroy_blocked_corp]
  
  before_filter :check_student
  
  before_filter :check_corporation, :only => [:create_blocked_corp, :destroy_blocked_corp,
                                              :show_corporation]
  
  
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
        flash.now[:success_msg] = "修改成功, 密码已更新"
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
    
    self.class.helpers.fill_student_profile(@profile, params)
    
    if @profile.save
      flash.now[:success_msg] = "修改成功, 个人信息已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
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
    else
      flash[:error_msg] = "操作失败, 再试一次吧"
    end
    
    jump_to("/students/#{@student.id}/edit_skills")
  end
  
  
  def blocked_corps
    @blocked_corps = BlockedCorp.find(
      :all,
      :conditions => ["student_id = ?", @student.id],
      :include => [:corporation]
    )
  end
  
  def new_blocked_corp
    @district_id = params[:d] && params[:d].strip
    @nature_id = params[:n] && params[:n].strip
    @size_id = params[:s] && params[:s].strip
    @industry_category_id = params[:ic] && params[:ic].strip
    @industry_id = params[:i] && params[:i].strip
    @province_id = params[:p] && params[:p].strip
    
    @keyword = params[:k] && params[:k].strip
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corporations = Corporation.school_search(
      @keyword,
      @student.school_id,
      page, 20,
      :job_district_id => @district_id,
      :nature_id => @nature_id,
      :size_id => @size_id,
      :industry_category_id => @industry_category_id,
      :industry_id => @industry_id,
      :province_id => @province_id
    )
  end
  
  
  def create_blocked_corp
    blocked_corp = BlockedCorp.get_record(@student.id, @corporation.id)
    
    if blocked_corp.save
      flash[:success_msg] = "操作成功, 已将企业 #{@corporation.get_name} 添加到黑名单"
    else
      flash[:error_msg] = "操作失败, 再试一次吧"
    end
    
    back = params[:back] && params[:back].strip
    back = "blocked_corps" if back.blank?
    jump_to("/students/#{@student.id}/#{back}")
  end
  
  def destroy_blocked_corp
    blocked_corp = BlockedCorp.get_record(@student.id, @corporation.id)
    blocked_corp.destroy
    
    flash[:success_msg] = "操作成功, 已将企业 #{@corporation.get_name} 从黑名单中移除"
    
    back = params[:back] && params[:back].strip
    back = "blocked_corps" if back.blank?
    jump_to("/students/#{@student.id}/#{back}")
  end
  
  
  def show_corporation
    @profile = CorporationProfile.get_record(@corporation.id)
    @blocked_corp = BlockedCorp.get_record(@student.id, @corporation.id)
  end
  
  
  private
  
  def check_student
    student_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_corporation
    @corporation = Corporation.find(params[:corporation_id])
    jump_to("/errors/forbidden") unless @corporation.school_id == @student.school_id
  end
  
end
