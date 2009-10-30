class CorporationsController < ApplicationController
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:update, :update_password, :update_profile,
                                          :resumes, :add_skill, :create_query]
  
  before_filter :check_corporation
  
  before_filter :check_corporation_allow, :only => [:resumes, :add_skill, :create_query]
  
  before_filter :check_corporation_name, :except => [:edit, :update]
  before_filter :protect_corporation_name, :only => [:edit, :update]
  
  
  def show
    
  end
  
  
  def edit
    
  end
  
  def update
    @corporation.name = params[:name] && params[:name].strip
    
    if @corporation.name?
      if @corporation.save
        flash[:success_msg] = "修改成功, 企业名称已更新"
        return jump_to("/corporations/#{@corporation.id}")
      end
    else
      flash.now[:error_msg] = "修改失败, 请输入 企业名称"
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
    @profile = CorporationProfile.get_record(@corporation.id)
  end
  
  def update_profile
    @profile = CorporationProfile.get_record(@corporation.id)
    
    @profile.email = params[:email] && params[:email].strip
    @profile.phone = params[:phone] && params[:phone].strip
    @profile.contact = params[:contact] && params[:contact].strip
    @profile.contact_gender = case params[:contact_gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    @profile.contact_title = params[:contact_title] && params[:contact_title].strip
    
    @profile.address = params[:address] && params[:address].strip
    @profile.zip = params[:zip] && params[:zip].strip
    @profile.website = params[:website] && params[:website].strip
    
    @profile.nature_id = params[:nature]
    @profile.size_id = params[:size]
    @profile.industry_id = params[:industry]
    @profile.province_id = params[:province]
    @profile.city_id = params[:city]
    
    @profile.desc = params[:desc] && params[:desc].strip
    
    if @profile.save
      flash[:success_msg] = "修改成功, 企业信息已更新"
      return jump_to("/corporations/#{@corporation.id}")
    end
    
    render :action => "edit_profile"
  end
  
  
  def resumes
    conditions = params[:q] && params[:q].strip
    
    @query = CorpQuery.parse_from_conditions(conditions)
    @query_tags, @query_skills = @query.tags_and_skills
    
    
    unless conditions.blank?
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @resumes = Resume.do_search(@query, @corporation.school_id, page, @query_tags, @query_skills)
    end
  end
  
  def create_query
    q = params[:q] && params[:q].strip
    
    from_saved = !q.blank?
    
    conditions = if from_saved
      q
    else
      CorporationsController.helpers.collect_query_conditions(params, :keyword)
    end
    
    
    # ========== log the query to db ==========
    query = CorpQuery.parse_from_conditions(conditions)
    query.corporation_id = @corporation.id
    query.from_saved = from_saved
    # the params[:keyword] has been encodeURIComponent by javascript
    # and should be only used in URL
    query.keyword = params[:keyword_input] && params[:keyword_input].strip
    query.save
    # ========== end ==========
    
    
    return jump_to("/corporations/#{@corporation.id}/resumes?q=#{conditions}")
  end
  
  def add_skill
    skill_id = params[:skill_id] && params[:skill_id].strip
    
    if !skill_id.blank?
      return render(:partial => "query_skill", :object => [skill_id.to_i, nil])
    end
    
    render :nothing => true
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
  
  
  def protect_corporation_name
    jump_to("/corporations/#{@corporation.id}") if @corporation.name?
  end
  
end
