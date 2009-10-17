class CorporationsController < ApplicationController
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:update, :update_password, :update_profile]
  
  before_filter :check_corporation
  
  before_filter :check_corporation_allow, :only => []
  
  # before_filter :check_corporation_name
  
  
  def show
    
  end
  
  
  def edit
    # should check and prevent modifying ...
  end
  
  def update
    @corporation.name = params[:name] && params[:name].strip
    
    if @corporation.save
      flash[:success_msg] = "修改成功, 企业名称已更新"
      return jump_to("/corporations/#{@corporation.id}")
    end
    
    render :action => "edit"
  end
  
  
  def edit_password

  end
  
  def update_password
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = (@corporation.password == current_password)
    
    if changed
      @corporation.password = password
      @corporation.password_confirmation = password_confirmation
      if @corporation.save
        flash[:success_msg] = "修改成功, 密码已更新"
        return jump_to("/corporations/#{@corporation.id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit_password"
  end
  
  
  def edit_profile
    
  end
  
  def update_profile
    
  end
  
  
  private
  
  def check_corporation
    corporation_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == corporation_id) && ((@corporation = Corporation.find(corporation_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_corporation_allow
    jump_to("/errors/unauthorized") unless @corporation.allow
  end
  
  
  def check_corporation_name
    jump_to("/corporations/#{@corporation.id}/edit") unless @corporation.name?
  end
  
end
