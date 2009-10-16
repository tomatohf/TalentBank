class TeachersController < ApplicationController
  
  Student_Page_Size = 50
  Corporation_Page_Size = 50
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password, :create_corporation,
                                          :allow_corporation, :inhibit_corporation]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :only => [:corporations,
                                                :new_corporation, :create_corporation,
                                                :allow_corporation, :inhibit_corporation]
  
  
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
    @title = "全部企业帐号"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corporations = Corporation.paginate(
      :page => page,
      :per_page => Corporation_Page_Size,
      :conditions => ["school_id = ?", @teacher.school_id],
      :order => "created_at DESC"
    )
  end
  
  
  def new_corporation
    @corporation = Corporation.new(:school_id => @teacher.school_id)
  end
  
  def create_corporation
    @corporation = Corporation.new(:school_id => @teacher.school_id)
    
    @corporation.uid = params[:uid] && params[:uid].strip
    @corporation.password = ::Utils.generate_password(@corporation.uid)
    @corporation.allow = (params[:allow] == "true")
    
    if @corporation.save
      flash[:success_msg] = "操作成功, 已添加企业帐号 #{@corporation.uid}"
      return jump_to("/teachers/#{@teacher.id}/corporations")
    end
    
    render :action => "new_corporation"
  end
  
  
  def allow_corporation
    adjust_corporation_allow(true)
  end
  
  def inhibit_corporation
    adjust_corporation_allow(false)
  end
  
  
  def allowed_corporations
    @title = "允许查询简历的企业帐号"
    corporations_by_allow(true)
  end
  
  def inhibitive_corporations
    @title = "禁止查询简历的企业帐号"
    corporations_by_allow(false)
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def adjust_corporation_allow(allow)
    corporation = Corporation.find(params[:corporation_id])
    corporation.allow = allow
    
    if (corporation.school_id == @teacher.school_id) && corporation.save
      verb = allow ? "允许" : "禁止"
      flash[:success_msg] = "操作成功, 已#{verb}企业帐号 #{corporation.uid} 查询学生简历"
    end
    
    jump_to("/teachers/#{@teacher.id}/corporations")
  end
  
  
  def corporations_by_allow(allow)
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corporations = Corporation.paginate(
      :page => page,
      :per_page => Corporation_Page_Size,
      :conditions => ["school_id = ? and allow = ?", @teacher.school_id, allow],
      :order => "created_at DESC"
    )
    
    render :action => "corporations"
  end
  
end
