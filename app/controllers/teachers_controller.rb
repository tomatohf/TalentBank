class TeachersController < ApplicationController
  
  Student_Page_Size = 50
  Corporation_Page_Size = 50
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password, :create_corporation,
                                          :allow_corporation_query, :inhibit_corporation_query]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :only => [:corporations,
                                                :new_corporation, :create_corporation,
                                                :allow_corporation_query, :inhibit_corporation_query]
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    @teacher.name = params[:name] && params[:name].strip
    @teacher.email = params[:email] && params[:email].strip
    
    if @teacher.save
      flash[:success_msg] = "修改成功, 信息已更新"
      return jump_to("/teachers/#{@teacher.id}")
    end
    
    render :action => "edit"
  end
  
  
  def edit_password

  end
  
  def update_password
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = (@teacher.password == current_password)
    
    if changed
      @teacher.password = password
      @teacher.password_confirmation = password_confirmation
      if @teacher.save
        flash[:success_msg] = "修改成功, 密码已更新"
        return jump_to("/teachers/#{@teacher.id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit_password"
  end
  
  
  def students
    @students = Student.find(
      :all,
      :conditions => ["school_id = ?", @teacher.school_id]
    )
  end
  
  
  def corporations
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corporations = Corporation.paginate(
      :page => page,
      :per_page => Corporation_Page_Size,
      :conditions => ["school_id = ?", @teacher.school_id]
    )
  end
  
  
  def new_corporation
    @corporation = Corporation.new(:school_id => @teacher.school_id)
  end
  
  def create_corporation
    @corporation = Corporation.new(:school_id => @teacher.school_id)
    
    @corporation.uid = params[:uid] && params[:uid].strip
    @corporation.password = ::Utils.generate_password(@corporation.uid)
    @corporation.allow_query = (params[:allow_query] == "true")
    
    if @corporation.save
      flash[:success_msg] = "操作成功, 已添加企业帐号 #{@corporation.uid}"
      return jump_to("/teachers/#{@teacher.id}/corporations")
    end
    
    render :action => "new_corporation"
  end
  
  
  def allow_corporation_query
    adjust_corporation_allow_query(true)
  end
  
  def inhibit_corporation_query
    adjust_corporation_allow_query(false)
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def adjust_corporation_allow_query(allow_query)
    corporation = Corporation.find(params[:corporation_id])
    corporation.allow_query = allow_query
    
    if (corporation.school_id == @teacher.school_id) && corporation.save
      verb = allow_query ? "允许" : "禁止"
      flash[:success_msg] = "操作成功, 已#{verb}企业帐号 #{corporation.uid} 查询学生简历"
    end
    
    jump_to("/teachers/#{@teacher.id}/corporations")
  end
  
end
