class ResumeSkillsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_skill, :except => [:index, :new, :create]
  
  
  def index
    @student_skills = StudentSkill.find(
      :all,
      :conditions => ["student_id = ?", @student.id]
    ).select do |student_skill|
      # show only when the value is large than 0
      student_skill.value > 0
    end
    
    @resume_skills = {}
    ResumeSkill.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id]
    ).each do |resume_skill|
      @resume_skills[resume_skill.student_skill_id] = resume_skill
    end
    
    
    @resume_list_skills = ResumeListSkill.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id]
    )
  end
  
  
  def new
    @list_skill = ResumeListSkill.new(:resume_id => @resume.id)
  end
  
  def create
    @list_skill = ResumeListSkill.new(:resume_id => @resume.id)
    
    @list_skill.name = params[:name] && params[:name].strip
    @list_skill.level = params[:level] && params[:level].strip
    
    if @list_skill.save
      @resume.renew_updated_at(@list_skill.updated_at)
      
      flash[:success_msg] = "操作成功, 已添加自定义的技能和证书 #{@list_skill.name}"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_skills")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @list_skill.name = params[:name] && params[:name].strip
    @list_skill.level = params[:level] && params[:level].strip
    
    if @list_skill.save
      @resume.renew_updated_at(@list_skill.updated_at)
      
      flash[:success_msg] = "操作成功, 自定义的技能和证书 #{@list_skill.name} 已更新"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_skills")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @list_skill.destroy
    
    @resume.renew_updated_at(Time.now)
    
    flash[:success_msg] = "操作成功, 已删除自定义的技能和证书 #{@list_skill.name}"
  
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_skills")
  end
  
  
  private
  
  def check_student
    student_id = params[:student_id] && params[:student_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_resume
    @resume = Resume.find(params[:resume_id])
    jump_to("/errors/forbidden") unless @resume.student_id == @student.id
  end
  
  
  def check_resume_skill
    @list_skill = ResumeListSkill.find(params[:id])
    jump_to("/errors/forbidden") unless @list_skill.resume_id == @resume.id
  end
  
end
