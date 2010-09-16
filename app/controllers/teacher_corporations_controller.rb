class TeacherCorporationsController < ApplicationController
  
  layout "teachers"
  
  
  Corporation_Page_Size = 10
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :adjust_permission]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin
  
  before_filter :check_corporation, :except => [:index, :new, :create]
  
  
  def index
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
      if @nature_id.blank? && @size_id.blank? && @industry_id.blank? && @province_id.blank? &&
          @keyword.blank? && @allow_query.blank?
        Corporation.paginate(
          :page => page,
          :per_page => Corporation_Page_Size,
          :conditions => ["school_id = ?", @teacher.school_id],
          :order => "updated_at DESC"
        )
      else
        Corporation.school_search(
          @keyword,
          @teacher.school_id,
          page, Corporation_Page_Size,
          :allow_query => @allow_query,
          :nature_id => @nature_id,
          :size_id => @size_id,
          :industry_id => @industry_id,
          :province_id => @province_id
        )
      end
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
  
  
  def new
    @corporation = Corporation.new(:school_id => @teacher.school_id)
  end
  
  def create
    @corporation = Corporation.new(:school_id => @teacher.school_id)
    
    @corporation.uid = params[:uid] && params[:uid].strip
    @corporation.password = params[:password] && params[:password].strip
    @corporation.allow_query = (params[:allow_query] == "true")
    
    if @corporation.save
      flash[:success_msg] = "操作成功, 已添加企业帐号 #{@corporation.uid}"
      return jump_to("/teachers/#{@teacher.id}/corporations")
    end
    
    render :action => "new"
  end
  
  
  def edit
    @profile = CorporationProfile.get_record(@corporation.id)
  end
  
  def update
    @profile = CorporationProfile.get_record(@corporation.id)
    
    @corporation.name = params[:name] && params[:name].strip
    
    # corporation profile
    CorporationsController.helpers.fill_corporation_profile(@profile, params)
    
    if @corporation.save && @profile.save
      flash.now[:success_msg] = "修改成功, 企业资料已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
  end
  
  
  def show
    @profile = @corporation.profile || CorporationProfile.new
  end
  
  
  def adjust_permission
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
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_admin
    jump_to("/errors/unauthorized") unless @teacher.admin
  end
  
  
  def check_corporation
    @corporation = Corporation.find(params[:id])
    jump_to("/errors/forbidden") unless @corporation.school_id == @teacher.school_id
  end
  
end
