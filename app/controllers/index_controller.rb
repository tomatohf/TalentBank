class IndexController < ApplicationController
  
  def index

    return jump_to("/#{session[:account_type]}/#{session[:account_id]}") if login?
  
    if cookies[:logintype] == "students"
      jump_to("/index/student")
    elsif cookies[:logintype] == "corporations"
      jump_to("/index/corporation")
    elsif cookies[:logintype] == "schools"
      jump_to("/index/teacher/school")
    elsif cookies[:logintype] == "teachers"
      jump_to("/index/teacher")
    end

  end
  
  
  def login
    render :action => "index"
  end
  
  
  def student
    
    @uid = cookies[:loginid] if cookies[:logintype] == "students"
    
    if request.post?
      @uid = params[:username] && params[:username].strip
      password = params[:password]
      @save_username = (params[:save_username] == "true")
      
      authenticated = Student.authenticate(@school.abbr, @uid, password)
      
      if authenticated
        do_login(authenticated.id, :students, authenticated.active)

        set_login_cookie(@uid, :students, @save_username)
        
        redirect_to_original_address
      else
        flash.now[:error_msg] = %Q?登录失败, 学号 或 密码 错误 !?
      end
    end
    
  end
  
  
  def teacher
    
    is_school = (params[:id] == "school")
    @user_type = is_school ? "school" : "teacher"
    @uid = cookies[:loginid] if cookies[:logintype] == (is_school ? "schools" : "teachers")

    if request.post?
      @user_type = params[:user_type]
      @uid = params[:username] && params[:username].strip
      password = params[:password]
      @save_username = (params[:save_username] == "true")
      
      school_abbr = @school.abbr
      
      if @user_type == "school"
        account_type = :schools
        authenticated = School.authenticate(school_abbr, @uid, password)
      else
        account_type = :teachers
        authenticated = Teacher.authenticate(school_abbr, @uid, password)
      end
      
      if authenticated
        do_login(authenticated.id, account_type, authenticated.active)

        set_login_cookie(@uid, account_type, @save_username)
        
        redirect_to_original_address
      else
        flash.now[:error_msg] = %Q?登录失败, 用户名 或 密码 错误 !?
      end
    end

  end
  
  
  def corporation
    
    @uid = cookies[:loginid] if cookies[:logintype] == "corporations"
    
    if request.post?
      @uid = params[:username] && params[:username].strip
      password = params[:password]
      @save_username = (params[:save_username] == "true")
      
      authenticated = Corporation.authenticate(@school.abbr, @uid, password)
      
      if authenticated
        do_login(authenticated.id, :corporations, authenticated.active)

        set_login_cookie(@uid, :corporations, @save_username)
        
        redirect_to_original_address
      else
        flash.now[:error_msg] = %Q?登录失败, 用户名 或 密码 错误 !?
      end
    end
    
  end
  
  
  def corporation_register
    @corporation = Corporation.new(:registering => true)
    @profile = CorporationProfile.new(:registering => true)
    
    if request.post?
      # corporation
      @corporation.uid = params[:username] && params[:username].strip
      @corporation.password = params[:password]
      @corporation.password_confirmation = params[:password_confirmation]
      
      @corporation.name = params[:name] && params[:name].strip
      
      # corporation profile
      CorporationsController.helpers.fill_corporation_profile(@profile, params)
      
      # do validation
      valid = @corporation.valid?
      valid = @profile.valid? && valid
      # check corporation name
      unless @corporation.name?
        flash.now[:error_msg] = "请输入 企业名称"
        valid = false
      end
      
      if valid
        @corporation.school_id = School.get_school_info(@school.abbr)[0]
        if @corporation.save
          # login the corporation
          do_login(@corporation.id, :corporations, @corporation.active)
          set_login_cookie(@corporation.uid, :corporations, false)
          
          # TODO - NOTIFY ADMIN TEACHER !!!
          
          @profile.corporation_id = @corporation.id
          if @profile.save
            flash[:success_msg] = "注册成功, 已创建企业帐号"
            return jump_to("/corporations/#{@corporation.id}")
          else
            flash[:error_msg] = "企业信息保存失败, 再试一次吧"
            return jump_to("/corporations/#{@corporation.id}/edit_profile")
          end
          
        else
          flash.now[:error_msg] = "注册失败, 再试一次吧"
        end
      end
    end
  end
  
  
  def logout
    do_logout
    
    jump_to("/")
  end


  def noisy_image
    image = NoisyImage.new(4)
    session[:img_code] = image.code
    send_data(image.code_image, :type => "image/jpeg", :disposition => "inline")
  end
  
  
  def intern_register
    @student = Student.new(:school_id => School.get_school_info(@school.abbr)[0])
    @profile = StudentProfile.new
    @intern_profile = InternProfile.new
    @wishes = []
    
    @university = ""
    @college = ""
    @major = ""
    @allow_adjust = true
    
    @universities = @school.universities.map { |u_id| University.find(u_id) }
    @labels = @school.intern_register_labels
    
    if request.post?
      @student.number = params[:number] && params[:number].strip
      @student.number = "#{@labels[:number_prefix]}#{@student.number}" unless @student.number.blank?
      
      params[:birthmonth] = "#{params[:birthmonth_year]}-#{params[:birthmonth_month]}-#{params[:birthmonth_date]}"
      @university = params[:university] && params[:university].strip
      @college = params[:college] && params[:college].strip
      @major = params[:major] && params[:major].strip
      @allow_adjust = (params[:allow_adjust] == "true")
      params[:begin_at] = "#{params[:begin_at_year]}-#{params[:begin_at_month]}-#{params[:begin_at_date]}"
      params[:desc] = %Q!学校:#{@university}\n学院:#{@college}\n专业:#{@major}\n服从岗位调剂:#{@allow_adjust ? "是" : "否"}!
      
      university_model = @universities.detect { |u|
        u[:name] == @university
      }
      params[:university_id] = university_model[:id] if university_model

      StudentsController.helpers.fill_student_editable_fields(@student, params)
      StudentsController.helpers.fill_student_profile(@profile, params)
      StudentsController.helpers.fill_student_intern_profile(@intern_profile, params)
      @wishes = params.keys.select { |key|
        key =~ /aspect_\d+/
      }.map { |key|
        aspect = params[key]
        index = key["aspect_".size .. -1]
        
        wish = case aspect
          when "industry"
            industry_category_id = params["industry_category_#{index}"]
            industry_id = params["industry_#{index}"]
            {
              :field => industry_category_id.to_i,
              :field2 => industry_id.to_i,
              :wish => InternIndustryWish.new(
                :industry_category_id => industry_category_id,
                :industry_id => industry_id
              )
            }
          when "job_category"
            job_category_class_id = params["job_category_class_#{index}"]
            job_category_id = params["job_category_#{index}"]
            {
              :field => job_category_class_id.to_i,
              :field2 => job_category_id.to_i,
              :wish => InternJobCategoryWish.new(
                :job_category_class_id => job_category_class_id,
                :job_category_id => job_category_id
              )
            }
          when "corp_nature"
            nature_id = params["corp_nature_#{index}"]
            {
              :field => nature_id.to_i,
              :field2 => nil,
              :wish => InternCorpNatureWish.new(:nature_id => nature_id)
            }
          when "job_district"
            job_district_id = params["job_district_#{index}"]
            {
              :field => job_district_id.to_i,
              :field2 => nil,
              :wish => InternJobDistrictWish.new(
                :job_district_id => job_district_id
              )
            }
          when "corporation"
            corporation_id = params["corporation_#{index}"]
            job_id = params["job_#{index}"]
            corporation = Corporation.new(
              :name => params["corporation_name_#{index}"]
            )
            corporation.id = corporation_id
            {
              :field => corporation,
              :field2 => job_id.to_i,
              :corporation => InternCorporationWish.new(:corporation_id => corporation_id),
              :job => InternJobWish.new(:job_id => job_id)
            }
        end
        
        wish[:aspect] = aspect
        wish[:index] = index.to_i
        
        wish
      }.sort { |x, y|
        x[:index] <=> y[:index]
      }
      
      @student.password = "111111"
      @intern_profile.salary = 0
      if @student.save
        @profile.student_id = @student.id
        @intern_profile.student_id = @student.id
        
        @profile.save
        @intern_profile.save
        
        @wishes.each do |wish|
          if wish[:aspect] == "corporation"
            wish[:corporation].student_id = @student.id
            wish[:job].student_id = @student.id
            wish[:corporation].save
            wish[:job].save
          else
            wish[:wish].student_id = @student.id
            wish[:wish].save
          end
        end
      end
    end
    
    render :layout => "empty"
  end
  def corporation_autocomplete
    render :layout => false, :json => Corporation.school_search(
      params[:term], School.get_school_info(@school.abbr)[0], 1, 30
    ).map { |corp|
      {
        :value => corp.get_name
      }
    }.to_json
  end
  def add_wish
    return jump_to("/") unless request.post?
      
    @aspect = params[:aspect] && params[:aspect].strip
    @field = params[:field] && params[:field].strip
    
    return render(:nothing => true) if @field.blank?
    
    if @aspect == "corporation"
      @field = Corporation.school_search_first_by_name(@field, School.get_school_info(@school.abbr)[0])
      return render(
        :text => %Q!<script type="text/javascript">alert("不存在名称为 #{params[:field]} 的公司");</script>!
      ) unless @field
    else
      @field = @field.to_i
    end
    
    render :layout => false, :partial => "/index/intern_wish/wish", :locals => {
      :aspect => @aspect,
      :field => @field
    }
  end
  
end
