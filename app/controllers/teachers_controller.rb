class TeachersController < ApplicationController
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password, :create_corporation,
                                          :adjust_corporation_permission]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :only => [:corporations,
                                                :new_corporation, :create_corporation,
                                                :adjust_corporation_permission,
                                                :show_corporation]
  
  before_filter :check_corporation, :only => [:adjust_corporation_permission, :show_corporation]
  
  before_filter :check_teacher_revision, :only => [:revisions]
  
  
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
          
          <%= paging_buttons(@corporations) %>
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
  
  
  def adjust_corporation_permission
    field = params[:permission] && params[:permission].strip
    
    @corporation.send("allow_#{field}=", params[:allow] == "true")
    
    if request.xhr?
      @corporation.save!
      render :partial => "permission_field", :locals => {:corporation => @corporation, :field => field}
    else
      @corporation.save
      jump_to("/teachers/#{@teacher.id}/corporations/#{@corporation.id}")
    end
  end
  
  
  def show_corporation
    @profile = @corporation.profile || CorporationProfile.new
  end
  
  
  def revisions
    teacher_account_type_id = AccountType.find_by(:name, "teachers")[:id]
    revision_select_fields = "id, resume_id, teacher_id, created_at"
    comment_select_fields = "id, resume_id, account_type_id, account_id, created_at"
    
    @date = begin
      Date.parse(params[:date])
    rescue
      last_revision_date = ResumeRevision.find(
        :first,
        :select => revision_select_fields,
        :conditions => ["teacher_id = ?", @teacher.id],
        :order => "created_at DESC"
      )
      last_comment_date = ResumeComment.find(
        :first,
        :select => comment_select_fields,
        :conditions => [
          "account_type_id = ? and account_id = ?",
          teacher_account_type_id,
          @teacher.id
        ],
        :order => "created_at DESC"
      )
      @date = [
        (last_revision_date && last_revision_date.created_at.to_date) || Date.today,
        (last_comment_date && last_comment_date.created_at.to_date) || Date.today
      ].max
    end
    
    revisions = ResumeRevision.find(
      :all,
      :select => revision_select_fields,
      :conditions => ["teacher_id = ? and created_at BETWEEN ? and ?",
        @teacher.id,
        @date,
        1.second.ago(1.day.since(@date))
      ],
      :order => "created_at DESC"
    )
    comments = ResumeComment.find(
      :all,
      :select => comment_select_fields,
      :conditions => [
        "account_type_id = ? and account_id = ? and created_at BETWEEN ? and ?",
        teacher_account_type_id,
        @teacher.id,
        @date,
        1.second.ago(1.day.since(@date))
      ],
      :order => "created_at DESC"
    )
    
    @operations = (revisions + comments).group_by { |r_or_c| r_or_c.resume_id }
    @resumes = (@operations.keys.size > 0) && Resume.find(
      :all,
      :conditions => ["id in (?)", @operations.keys],
      :include => [:student]
    ).inject({}) do |hash, resume|
			hash[resume.id] = resume
			hash
		end
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
  
  
  def check_teacher_revision
    jump_to("/errors/unauthorized") unless @teacher.revision
  end
  
end
