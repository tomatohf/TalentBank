class ResumesController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_resume, :only => [:edit, :update, :destroy, :preview]
  
  
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
    resume = Resume.new(:student_id => @student.id)
    
    resume.domain_id = params[:domain_id] && params[:domain_id].strip
    
    flash[:success_msg] = "操作成功, 已添加 #{ResumeDomain.find(resume.domain_id)[:name]} 的简历" if resume.save
    
    jump_to("/students/#{@student.id}/resumes")
  end
  
  
  def edit
    
  end
  
  def update
    # it's used to update the published status
  end
  
  
  def destroy
    @resume.destroy
    
    flash[:success_msg] = "操作成功, 已删除 #{ResumeDomain.find(@resume.domain_id)[:name]} 的简历"
  
    jump_to("/students/#{@student.id}/resumes")
  end
  
  
  def preview
    
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
