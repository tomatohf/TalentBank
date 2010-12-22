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
    
    @allow_adjust = (params[:allow_adjust] == "true")
    params[:birthmonth] = "#{params[:birthmonth_year]}-#{params[:birthmonth_month]}-#{params[:birthmonth_date]}"
    params[:begin_at] = "#{params[:begin_at_year]}-#{params[:begin_at_month]}-#{params[:begin_at_date]}"
    
    @student.number = params[:number] && params[:number].strip
    StudentsController.helpers.fill_student_editable_fields(@student, params)
    StudentsController.helpers.fill_student_profile(@profile, params)
    StudentsController.helpers.fill_student_intern_profile(@intern_profile, params)
    
    render :layout => "empty"
  end
  
end
