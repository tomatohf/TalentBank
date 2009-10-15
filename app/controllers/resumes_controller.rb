class ResumesController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy,
                                          :update_job_intention, :include_skill, :exclude_skill,
                                          :update_hobbies, :update_awards]
  
  before_filter :check_student
  
  before_filter :check_resume, :except => [:index, :create]
  
  
  def index
    @domains = @school.resume_domains
    
    @resumes = {}
    Resume.find(
      :all,
      :conditions => ["student_id = ?  and domain_id in (?)", @student.id, @domains]
    ).each do |resume|
      @resumes[resume.domain_id] = resume
    end
  end
  
  
  def create
    domain_id = params[:domain_id] && params[:domain_id].strip
    
    unless domain_id.blank?
      if @school.resume_domains.include?(domain_id.to_i)
        resume = Resume.new(
          :student_id => @student.id,
          :domain_id => domain_id
        )

        if resume.save
          return jump_to("/students/#{@student.id}/resumes/#{resume.id}/edit_job_intention")
        end
      end
    end
    
    jump_to("/students/#{@student.id}/resumes")
  end
  
  
  def update
    @resume.online = (params[:online] == "true")
    
    flash[:success_msg] = %Q!操作成功, 已将 #{ResumeDomain.find(@resume.domain_id)[:name]} 的简历#{@resume.online ? "上线" : "下线"}! if @resume.save
  
    jump_to("/students/#{@student.id}/resumes")
  end
  
  
  def destroy
    @resume.destroy
    
    flash[:success_msg] = "操作成功, 已删除 #{ResumeDomain.find(@resume.domain_id)[:name]} 的简历"
  
    jump_to("/students/#{@student.id}/resumes")
  end
  
  
  def edit_job_intention
    @job_intention = ResumeJobIntention.get_record(@resume.id)
  end
  
  def update_job_intention
    @job_intention = ResumeJobIntention.get_record(@resume.id)

    @job_intention.content = params[:job_intention] && params[:job_intention].strip
    
    if @job_intention.save
      flash.now[:success_msg] = "修改成功, 求职意向已更新"
    else
      flash.now[:error_msg] = "修改失败, 再试一次吧"
    end
    
    render :action => "edit_job_intention"
  end
  
  
  def edit_skills
    @student_skills = StudentSkill.find(
      :all,
      :conditions => ["student_id = ?", @student.id]
    )
    
    @resume_skills = {}
    ResumeSkill.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id]
    ).each do |resume_skill|
      @resume_skills[resume_skill.student_skill_id] = resume_skill
    end
  end
  
  def include_skill
    student_skill = StudentSkill.find(params[:student_skill_id])
    
    if (student_skill.student_id == @student.id) && student_skill.value > 0
      resume_skill = ResumeSkill.new(
        :resume_id => @resume.id,
        :student_skill_id => student_skill.id
      )
      
      resume_skill.save
    end
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/edit_skills")
  end
  
  def exclude_skill
    resume_skill = ResumeSkill.find(params[:resume_skill_id])
    
    resume_skill.destroy if resume_skill.resume_id == @resume.id
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/edit_skills")
  end
  
  
  def edit_hobbies
    @hobby = ResumeHobby.get_record(@resume.id)
  end
  
  def update_hobbies
    @hobby = ResumeHobby.get_record(@resume.id)

    @hobby.content = params[:hobbies] && params[:hobbies].strip
    
    if @hobby.save
      flash.now[:success_msg] = "修改成功, 特长和爱好已更新"
    else
      flash.now[:error_msg] = "修改失败, 再试一次吧"
    end
    
    render :action => "edit_hobbies"
  end
  
  
  def edit_awards
    @award = ResumeAward.get_record(@resume.id)
  end
  
  def update_awards
    @award = ResumeAward.get_record(@resume.id)

    @award.content = params[:awards] && params[:awards].strip
    
    if @award.save
      flash.now[:success_msg] = "修改成功, 荣誉和奖励已更新"
    else
      flash.now[:error_msg] = "修改失败, 再试一次吧"
    end
    
    render :action => "edit_awards"
  end
  
  
  def show
    Resume.load_contents(
      @resume,
      [
        :job_intention,
        :hobby,
        :award,
        :list_sections,
        {:exp_sections => [:exps]}
      ]
    )
    
    @profile = StudentProfile.get_record(@student.id)
    @photo = JobPhoto.get_record(@student.id)
    @edus = EduExp.find(:all, :conditions => ["student_id = ?", @student.id])
  end
  
  
  private
  
  def check_student
    student_id = params[:student_id] && params[:student_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_resume
    @resume = Resume.find(params[:id])
    jump_to("/errors/forbidden") unless @resume.student_id == @student.id
  end
  
end
