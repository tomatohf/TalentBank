class StudentExpsController < ApplicationController
  
  layout "students"
  
  
  before_filter :check_login_for_student
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_student
  
  before_filter :check_exp, :except => [:index, :new, :create]
  
  
  def index
    @exps = StudentExp.find(:all, :conditions => ["student_id = ?", @student.id])
  end
  
  
  def new
    @exp = StudentExp.new(:student_id => @student.id)
  end
  
  def create
    @exp = StudentExp.new(:student_id => @student.id)
    
    @exp.period = params[:period] && params[:period].strip
    @exp.title = params[:title] && params[:title].strip
    @exp.sub_title = params[:sub_title] && params[:sub_title].strip
    @exp.content = params[:content] && params[:content].strip
    
    if @exp.save
      flash[:success_msg] = "操作成功, 已添加 #{@exp.period} 的经历"
      return jump_to("/students/#{@student.id}/student_exps")
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
      flash[:success_msg] = "操作成功, #{@exp.period} 的经历已更新"
      return jump_to("/students/#{@student.id}/student_exps")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @exp.destroy
    
    flash[:success_msg] = "操作成功, 已删除 #{@exp.period} 的经历"
  
    jump_to("/students/#{@student.id}/student_exps")
  end
  
  
  private
  
  def check_student
    student_id = params[:student_id] && params[:student_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == student_id) && ((@student = Student.find(student_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_exp
    @exp = StudentExp.find(params[:id])
    jump_to("/errors/forbidden") unless @exp.student_id == @student.id
  end
  
end
