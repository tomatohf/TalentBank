class ResumeExpSectionsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy,
                                          :create_resume_student_exp, :destroy_resume_student_exp,
                                          :update_exp_order]
  
  before_filter :check_student
  
  before_filter :check_resume
  
  before_filter :check_resume_exp_section, :except => [:index, :new, :create]
  
  
  def index
    @sections = ResumeExpSection.find(
      :all,
      :conditions => ["resume_id = ?", @resume.id],
      :include => [{:resume_student_exps => :student_exp}, :exps]
    )
    
    @tags = ResumeExpTag.data[@resume.domain_id] || []
    
    @taggers = @resume.exp_taggers
  end
  
  
  def new
    @section = ResumeExpSection.new(:resume_id => @resume.id)
  end
  
  def create
    @section = ResumeExpSection.new(:resume_id => @resume.id)
    
    @section.title = params[:title] && params[:title].strip
    
    if @section.save
      @resume.renew_updated_at(@section.updated_at)
      
      flash[:success_msg] = "操作成功, 已添加经历块 #{@section.title}"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/exp_sections")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @section.title = params[:title] && params[:title].strip
    
    if @section.save
      @resume.renew_updated_at(@section.updated_at)
      
      flash[:success_msg] = "操作成功, 经历块 #{@section.title} 已更新"
      return jump_to("/students/#{@student.id}/resumes/#{@resume.id}/exp_sections")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @section.destroy
    
    @resume.renew_updated_at(Time.now)
    
    flash[:success_msg] = "操作成功, 已删除经历块 #{@section.title}"
  
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/exp_sections")
  end
  
  
  def new_resume_student_exp
    @student_exps = StudentExp.find(:all, :conditions => ["student_id = ?", @student.id])
    
    @added_student_exps = ResumeStudentExp.find(
      :all,
      :conditions => ["section_id = ?", @section.id]
    ).collect { |resume_student_exp| resume_student_exp.exp_id }
  end
  
  def create_resume_student_exp
    student_exp = StudentExp.find(params[:student_exp_id])
    
    if student_exp.student_id == @student.id
      resume_student_exp = ResumeStudentExp.new(
        :section_id => @section.id,
        :exp_id => student_exp.id
      )
      
      begin
        ActiveRecord::Base.transaction do
          resume_student_exp.save!
          
          @resume.renew_updated_at(resume_student_exp.updated_at)
          
          @section.add_exp_order(ResumeExpSection::Student_Exp, resume_student_exp.id)
          @section.save!
        end
        
        flash[:success_msg] = "操作成功, 已从经历库向 #{@section.title} 中添加了 #{student_exp.period} 的经历"
      rescue
        flash[:error_msg] = "操作失败, 再试一次吧"
      end
    end
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/exp_sections")
  end
  
  
  def destroy_resume_student_exp
    resume_student_exp = ResumeStudentExp.find(params[:resume_student_exp_id])
    
    if resume_student_exp.section_id == @section.id
      begin
        ActiveRecord::Base.transaction do
          resume_student_exp.destroy
          
          @resume.renew_updated_at(Time.now)
          
          @section.remove_exp_order(ResumeExpSection::Student_Exp, resume_student_exp.id)
          @section.save!
        end
      
        flash[:success_msg] = "操作成功, 已删除 #{@section.title} 中的指定经历"
      rescue
        flash[:error_msg] = "操作失败, 再试一次吧"
      end
    end
    
    jump_to("/students/#{@student.id}/resumes/#{@resume.id}/exp_sections")
  end
  
  
  def update_exp_order
    @section.set_exp_order(ResumeExpSection.parse_exp_order([:order] && params[:order].strip))
    
    if @section.save
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
    @section = ResumeExpSection.find(params[:id])
    jump_to("/errors/forbidden") unless @section.resume_id == @resume.id
  end
  
end
