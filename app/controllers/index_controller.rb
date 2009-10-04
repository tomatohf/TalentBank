class IndexController < ApplicationController
  
  def index

    return jump_to("/#{session[:account_type]}/#{session[:account_id]}") if login?
  
    if cookies[:logintype] == "students"
      jump_to("/index/student")
    elsif cookies[:logintype] == "schools"
      jump_to("/index/school")
    elsif cookies[:logintype] == "teachers"
      jump_to("/index/school/t")
    end

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
  
  
  def school
    
    is_teacher = params[:id] && params[:id] != ""
    @user_type = is_teacher ? "teacher" : "school"
    @uid = cookies[:loginid] if cookies[:logintype] == (is_teacher ? "teachers" : "schools")

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
    
  end
  
  
  def logout
    
  end


  def noisy_image
    image = NoisyImage.new(4)
    session[:img_code] = image.code
    send_data(image.code_image, :type => "image/jpeg", :disposition => "inline")
  end
  
end
