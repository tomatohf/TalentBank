class ResumeListSectionsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_list_section, :except => [:index, :new, :create]
  
  
  def index
    @sections = ResumeListSection.find(:all, :conditions => ["resume_id = ?", @resume.id])
  end
  
  
  def new
    @section = ResumeListSection.new(:resume_id => @resume.id)
  end
  
  def create
    @section = ResumeListSection.new(:resume_id => @resume.id)
    
    @section.title = params[:title] && params[:title].strip
    @section.content = params[:content] && params[:content].strip
    
    if @section.save
      @resume.after_change(@section.updated_at)
      
      flash[:success_msg] = "操作成功, 已添加附加信息 #{@section.title}"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/list_sections")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @section.title = params[:title] && params[:title].strip
    @section.content = params[:content] && params[:content].strip
    
    if @section.save
      @resume.after_change(@section.updated_at)
      
      flash[:success_msg] = "操作成功, 附加信息 #{@section.title} 已更新"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/list_sections")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @section.destroy
    
    @resume.after_change(Time.now)
    
    flash[:success_msg] = "操作成功, 已删除附加信息 #{@section.title}"
  
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/list_sections")
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
  
  
  def check_resume_list_section
    @section = ResumeListSection.find(params[:id])
    jump_to("/errors/forbidden") unless @section.resume_id == @resume.id
  end
  
end
