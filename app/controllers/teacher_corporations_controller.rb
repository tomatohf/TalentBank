class TeacherCorporationsController < ApplicationController
  
  layout "teachers"
  
  
  Corporation_Page_Size = 10
  Job_Page_Size = 15
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:create, :update, :adjust_permission]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_admin, :except => [:autocomplete]
  
  before_filter :check_corporation, :except => [:index, :new, :create, :autocomplete, :jobs]
  
  
  def index
    @uid = params[:u] && params[:u].strip
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @corporations = unless @uid.blank?
      if @uid.to_i > 0 && (corps = Corporation.paginate(
        :page => page,
        :per_page => Corporation_Page_Size,
        :conditions => ["id = ?", @uid]
      )).size > 0
        corps
      else
        Corporation.paginate(
          :page => page,
          :per_page => Corporation_Page_Size,
          :conditions => ["school_id = ? and uid = ?", @teacher.school_id, @uid]
        )
      end
    else
      @district_id = params[:d] && params[:d].strip
      @nature_id = params[:n] && params[:n].strip
      @size_id = params[:s] && params[:s].strip
      @province_id = params[:p] && params[:p].strip
      @industry_category_id = params[:ic] && params[:ic].strip
      @industry_id = params[:i] && params[:i].strip
      @intern_status_id = params[:is] && params[:is].strip
      
      @keyword = params[:k] && params[:k].strip
      
      @allow_query = if (aq = params[:aq] && params[:aq].strip) == "t"
        true
      elsif aq == "f"
        false
      else
        nil
      end
      
      if @district_id.blank? && @nature_id.blank? && @size_id.blank? &&
        @industry_category_id.blank? && @industry_id.blank? &&
        @province_id.blank? && @keyword.blank? && @allow_query.nil? &&
        @intern_status_id.blank?
        Corporation.paginate(
          :page => page,
          :per_page => Corporation_Page_Size,
          :conditions => ["school_id = ?", @teacher.school_id],
          :order => "created_at DESC"
        )
      else
        Corporation.school_search(
          @keyword,
          @teacher.school_id,
          page, Corporation_Page_Size,
          :allow_query => @allow_query,
          :job_district_id => @district_id,
          :nature_id => @nature_id,
          :size_id => @size_id,
          :industry_category_id => @industry_category_id,
          :industry_id => @industry_id,
          :intern_status_id => @intern_status_id,
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
    
    @corporation.teacher_id = params[:teacher] && params[:teacher].strip
    @corporation.intern_status_id = params[:intern_status] && params[:intern_status].strip
    
    @corporation.uid = params[:uid] && params[:uid].strip
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
    @profile = CorporationProfile.get_record(@corporation.id)
    
    @target_type = TeacherNoteTargetType.find_by(:name, "corporations")
    @notes = TeacherNote.get_from_target(@target_type[:id], @corporation.id)
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
  
  
  def autocomplete
    render :layout => false, :json => Corporation.school_search(
      params[:term], @teacher.school_id, 1, Corporation_Page_Size
    ).map { |corp|
      {
        :label => "#{corp.get_name} (#{corp.uid})",
        :value => "#{corp.uid}"
      }
    }.to_json
  end
  
  
  def jobs
    respond_to do |format|
      options = {
        :joins => "INNER JOIN corporations ON corporations.id = jobs.corporation_id",
        :conditions => ["school_id = ?", @teacher.school_id],
        :include => [:corporation => [:profile, :teacher]],
        :order => "corporations.created_at DESC"
      }
      compute_counts = Proc.new { |jobs, selected|
        CorporationsController.helpers.prepare_intern_log_counts(
          Proc.new { |filters|
            CorporationsController.helpers.count_intern_log(
              @teacher.school_id,
              :job_id,
              jobs.map { |job| job.id },
              filters
            )
          },
          selected
        )
      }
      
      format.html {
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @jobs = Job.paginate(
          options.merge(
            :page => page,
            :per_page => Job_Page_Size
          )
        )

        @counts = compute_counts.call(@jobs, params)
      }
      
      format.csv {
        jobs = Job.find(:all, options)
        
        counts = compute_counts.call(jobs, :all)
        
        csv_data = FasterCSV.generate do |csv|
          header = ["企业编号", "企业名称", "企业性质", "岗位编号", "岗位名称", "相关专业", "负责人", "招聘人数"]
    			counts.each_title do |key, value|
            header << value
          end
    			
          csv << header
          
          jobs.each do |job|
            corporation = job.corporation
  					profile = corporation.profile
  					nature = profile && profile.nature_id && CorporationNature.find(profile.nature_id)
  					major = job.major_id && JobMajor.find(job.major_id)
  					teacher = corporation.teacher

  					row = [
  					  corporation.id,
  					  corporation.get_name,
  					  nature && nature[:name],
  					  job.id,
  					  job.get_name,
  					  major && major[:name],
  					  teacher && teacher.get_name,
  					  job.number
  					]
  					counts.each_filter do |key, value|
    				  row << (counts.get_counts(key)[job.id] || 0).to_s
            end
  					
            csv << row
          end
        end
        
        send_data(
          csv_data,
          :filename => "jobs.csv",
          :type => :csv,
          :disposition => "attachment"
        )
      }
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
