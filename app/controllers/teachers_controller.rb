class TeachersController < ApplicationController
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password, :create_corporation,
                                          :allow_corporation_query, :inhibit_corporation_query]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :only => [:corporations,
                                                :new_corporation, :create_corporation,
                                                :allow_corporation_query, :inhibit_corporation_query,
                                                :show_corporation]
  
  before_filter :check_corporation, :only => [:allow_corporation_query, :inhibit_corporation_query,
                                              :show_corporation]
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    @teacher.name = params[:name] && params[:name].strip
    @teacher.email = params[:email] && params[:email].strip
    
    if @teacher.save
      flash.now[:success_msg] = "修改成功, 信息已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
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
        flash.now[:success_msg] = "修改成功, 密码已更新"
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit_password"
  end
  
  
  def corporations
    @uid = params[:u] && params[:u].strip
    
    @corporations = unless @uid.blank?
      Corporation.search(
        :conditions => {:uid => @uid},
        :with => {:school_id => @teacher.school_id}
      )
    else
      @nature_id = params[:n] && params[:n].strip
      @size_id = params[:s] && params[:s].strip
      @industry_id = params[:i] && params[:i].strip
      @province_id = params[:p] && params[:p].strip
      
      @keyword = params[:k] && params[:k].strip
      
      @allow_query = if (aq = params[:aq] && params[:aq].strip) == "t"
        true
      elsif aq == "f"
        false
      else
        nil
      end
      
      page = params[:page]
      page = 1 unless page =~ /\d+/
      Corporation.school_search(
        @keyword,
        @teacher.school_id,
        page, 10,
        :allow_query => @allow_query,
        :nature_id => @nature_id,
        :size_id => @size_id,
        :industry_id => @industry_id,
        :province_id => @province_id
      )
    end
    
    if request.xhr?
      return render(
        :layout => false,
        :inline => %Q!
          <% @corporations.each do |corp| %>
            <a href="#" id="filter_corp_<%= corp.id %>" class="filter_item_link">
              <%= h(corp.name) %> (<%= h(corp.uid) %>)</a>
          <% end %>
          
          <br />
          
          <div>
            <%= paging_buttons(@corporations) %>
          </div>
        !
      )
    end
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
    adjust_corporation_permission(:allow_query, true)
  end
  
  def inhibit_corporation_query
    adjust_corporation_permission(:allow_query, false)
  end
  
  
  def show_corporation
    @profile = @corporation.profile || CorporationProfile.new
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def check_corporation
    @corporation = Corporation.find(params[:corporation_id])
    jump_to("/errors/forbidden") unless @corporation.school_id == @teacher.school_id
  end
  
  
  def adjust_corporation_permission(name, value)
    @corporation.send("#{name}=", value)
    
    if @corporation.save
      return render(:partial => "#{name}_field", :locals => {:corporation => @corporation}) if request.xhr?
    end
    
    if request.xhr?
      render :nothing => true
    else
      jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}")
    end
  end
  
end
