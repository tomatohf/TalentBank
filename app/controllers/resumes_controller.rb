class ResumesController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy,
                                          :update_job_intention, :include_skill, :exclude_skill,
                                          :update_hobbies, :update_awards,
                                          :add_exp_tag, :remove_exp_tag]
  
  before_filter :check_student
  
  before_filter :check_resume, :except => [:index, :create]
  
  
  def index
    school_domains = @school.resume_domains
    
    @resumes = Resume.find(
      :all,
      :conditions => ["student_id = ?  and domain_id in (?)", @student.id, school_domains]
    )
    
    @available_domains = (school_domains - @resumes.collect{|resume| resume.domain_id}).collect do |domain_id|
      ResumeDomain.find(domain_id)
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
          flash[:success_msg] = "操作成功, 已添加 #{ResumeDomain.find(resume.domain_id)[:name]} 的简历"
          # return jump_to("/students/#{@student.id}/resumes/#{resume.id}/edit_job_intention")
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
      @resume.renew_updated_at(@job_intention.updated_at)
      
      flash.now[:success_msg] = "修改成功, 求职意向已更新"
    else
      flash.now[:error_msg] = "修改失败, 再试一次吧"
    end
    
    render :action => "edit_job_intention"
  end
  
  
  def include_skill
    student_skill = StudentSkill.find(params[:student_skill_id])
    
    if (student_skill.student_id == @student.id) && student_skill.value > 0
      resume_skill = ResumeSkill.new(
        :resume_id => @resume.id,
        :student_skill_id => student_skill.id
      )
      
      if resume_skill.save
        @resume.renew_updated_at(resume_skill.updated_at)
      end
    end
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_skills")
  end
  
  def exclude_skill
    resume_skill = ResumeSkill.find(params[:resume_skill_id])
    
    if resume_skill.resume_id == @resume.id
      resume_skill.destroy
      
      @resume.renew_updated_at(Time.now)
    end
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_skills")
  end
  
  
  def edit_hobbies
    @hobby = ResumeHobby.get_record(@resume.id)
  end
  
  def update_hobbies
    @hobby = ResumeHobby.get_record(@resume.id)

    @hobby.content = params[:hobbies] && params[:hobbies].strip
    
    if @hobby.save
      @resume.renew_updated_at(@hobby.updated_at)
      
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
      @resume.renew_updated_at(@award.updated_at)
      
      flash.now[:success_msg] = "修改成功, 荣誉和奖励已更新"
    else
      flash.now[:error_msg] = "修改失败, 再试一次吧"
    end
    
    render :action => "edit_awards"
  end
  
  
  def show
    @resume.student = @student
    
    respond_to do |format|
      format.html {
        
      }
      
      format.pdf {
        domain = ResumeDomain.find(@resume.domain_id)[:name]
        filename = "#{@student.name}_#{domain}_中文简历.pdf"
        filename = URI.encode(filename) if (request.env["HTTP_USER_AGENT"] || "") =~ /MSIE/i
        
        send_data(
          PdfExport.generate(
            @resume,
            :styles => {
              :host => request.host_with_port,
              
              :Creator => @school.logo_title,
              :Title => "#{@student.name}_#{domain}_中文简历",
              :Author => @student.name
            }
          ),
          :filename => filename,
          :type => :pdf,
          #:disposition => "attachment"
          :disposition => "inline"
        )
      }
    end
  end
  
  
  def add_exp_tag
    tag_id = params[:tag_id] && params[:tag_id].strip
    
    if ResumeExpTagger.check_tag_domain((tag_id && tag_id.to_i), @resume.domain_id)
      tagger = ResumeExpTagger.get_record(@resume.id, tag_id)
      
      if tagger.new_record? && tagger.save
        @resume.renew_updated_at(tagger.updated_at)
        
        return render(:partial => "/resume_exps/tagger", :object => tagger)
      end
    
    end
    
    render :nothing => true
  end
  
  def remove_exp_tag
    tagger = ResumeExpTagger.find(params[:tagger_id])
    
    if tagger.resume_id == @resume.id
      tagger.destroy
      
      @resume.renew_updated_at(Time.now)
      
      return render(:layout => false, :text => "true")
    end
    
    render :nothing => true
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
