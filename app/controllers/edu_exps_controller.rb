class EduExpsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_exp, :only => [:edit, :update, :destroy]
  
  
  def index
    @exps = EduExp.find(:all, :conditions => ["student_id = ?", @student.id])
  end
  
  
  def new
    @exp = EduExp.new(:student_id => @student.id)
  end
  
  def create
    @exp = EduExp.new(:student_id => @student.id)
    
    @exp.period = params[:period] && params[:period].strip
    @exp.university = params[:university] && params[:university].strip
    @exp.college = params[:college] && params[:college].strip
    @exp.major = params[:major] && params[:major].strip
    @exp.edu_type = params[:edu_type] && params[:edu_type].strip
    
    if @exp.save
      flash[:success_msg] = "操作成功, 已添加 #{@exp.period} 的教育经历"
      return jump_to("/students/#{@student.id}/edu_exps")
    end
    
    render :action => "new"
  end
  
  
  def edit
    
  end
  
  def update
    @exp.period = params[:period] && params[:period].strip
    @exp.university = params[:university] && params[:university].strip
    @exp.college = params[:college] && params[:college].strip
    @exp.major = params[:major] && params[:major].strip
    @exp.edu_type = params[:edu_type] && params[:edu_type].strip
    
    if @exp.save
      flash[:success_msg] = "操作成功, #{@exp.period} 的教育经历已更新"
      return jump_to("/students/#{@student.id}/edu_exps")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @exp.destroy
    
    flash[:success_msg] = "操作成功, 已删除 #{@exp.period} 的教育经历"
  
    jump_to("/students/#{@student.id}/edu_exps")
  end
  
  
  private
  
  def check_student
    student_id = params[:student_id] && params[:student_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_exp
    @exp = EduExp.find(params[:id])
    jump_to("/errors/forbidden") unless @exp.student_id == @student.id
  end
  
end
