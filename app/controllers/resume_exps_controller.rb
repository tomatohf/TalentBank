class ResumeExpsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy, :add_tag, :remove_tag]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_exp_section
  
  before_filter :check_resume_exp, :except => [:index, :new, :create]
  
  
  def new
    @exp = ResumeExp.new(:section_id => @section.id)
  end
  
  def create
    @exp = ResumeExp.new(:section_id => @section.id)
    
    @exp.period = params[:period] && params[:period].strip
    @exp.title = params[:title] && params[:title].strip
    @exp.sub_title = params[:sub_title] && params[:sub_title].strip
    @exp.content = params[:content] && params[:content].strip
    
    if @exp.save
      flash[:success_msg] = "操作成功, 已添加 #{@section.title} 中 #{@exp.period} 的经历"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @exp.period = params[:period] && params[:period].strip
    @exp.title = params[:title] && params[:title].strip
    @exp.sub_title = params[:sub_title] && params[:sub_title].strip
    @exp.content = params[:content] && params[:content].strip
    
    if @exp.save
      flash[:success_msg] = "操作成功, #{@section.title} 中 #{@exp.period} 的经历已更新"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @exp.destroy
    
    flash[:success_msg] = "操作成功, 已删除 #{@section.title} 中 #{@exp.period} 的经历"
  
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/resume_exp_sections")
  end
  
  
  def add_tag
    tag_id = params[:tag_id] && params[:tag_id].strip
    
    if ResumeExpTagger.check_tag_domain((tag_id && tag_id.to_i), @resume.domain_id)
      tagger = ResumeExpTagger.get_record(@exp.id, tag_id)
      
      if tagger.new_record? && tagger.save
        return render(:partial => "tagger", :object => tagger, :locals => {:section => @section, :exp => @exp})
      end
    
    end
    
    render :nothing => true
  end
  
  def remove_tag
    tagger = ResumeExpTagger.find(params[:tagger_id])
    
    if tagger.exp_id == @exp.id
      tagger.destroy
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
    @resume = Resume.find(params[:resume_id])
    jump_to("/errors/forbidden") unless @resume.student_id == @student.id
  end
  
  
  def check_resume_exp_section
    @section = ResumeExpSection.find(params[:resume_exp_section_id])
    jump_to("/errors/forbidden") unless @section.resume_id == @resume.id
  end
  
  def check_resume_exp
    @exp = ResumeExp.find(params[:id])
    jump_to("/errors/forbidden") unless @exp.section_id == @section.id
  end
  
end
