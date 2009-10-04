class IndexController < ApplicationController
  
  # put all non-login request/action in this controller
  skip_before_filter :check_login
  
  
  def index

    if login?

    end

  end
  
  
  def student
    
  end
  
  
  def school
    
    @user_type = "teacher"

    if request.post?
      @user_type = params[:user_type]
      @uid = params[:username] && params[:username].strip
      password = params[:password]
      @save_username = (params[:save_username] == "true")
      
      authenticated = if @user_type == "school"
        School.authenticate(@school.abbr, password)
      else
        Teacher.authenticate(@uid, password)
      end
      
      if authenticated
        do_login
        
        return jump_to("")
      else
        flash.now[:error_msg] = %Q?登录失败, #{"用户名 或 " if @user_type != "school"}密码 错误 !?
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
