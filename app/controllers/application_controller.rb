# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  # enable output GZip compression
  after_filter OutputCompressionFilter if Rails.env.production?
  
  before_filter :prepare_school
  
  rescue_from(ActionController::InvalidAuthenticityToken) { |e|
    save_original_address
    jump_to("/")
  }
  
  
  
  private
  
  # ========== filters ==========
  
  def prepare_school
    abbr = Rails.env.production? ? request.host.split(".").first : "talent"
    abbr = "qiaobutang" if abbr == "talent"
    
    @school = Schools.get_school(abbr)
  end
  
  
  def check_login
    if login?
      @account_active = session[:account_active]
      
      yield if block_given?
    else
      save_original_address
      jump_to("/")
    end
  end
  
  
  def check_active(active = nil)
    jump_to("/errors/inactive") unless (active || @account_active)
  end
  
  
  def check_login_for_school
    check_login { jump_to("/index/teacher/school") unless session[:account_type] == :schools }
  end
  
  
  def check_login_for_teacher
    check_login { jump_to("/index/teacher") unless session[:account_type] == :teachers }
  end
  
  
  def check_login_for_student
    check_login { jump_to("/index/student") unless session[:account_type] == :students }
  end
  
  
  def check_login_for_corporation
    check_login { jump_to("/index/corporation") unless session[:account_type] == :corporations }
  end
  
  
  def check_login_for_account
    case (@account_type = params[:account_type])
    when "students"
      check_login_for_student
    when "teachers"
      check_login_for_teacher
    when "corporations"
      check_login_for_corporation
    else
      jump_to("/errors/forbidden")
    end
  end
  
  
  def check_account
    account_id = params[:account_id] && params[:account_id].strip
    jump_to("/errors/forbidden") unless (
      session[:account_id].to_s == account_id
    ) && (
      (
        self.instance_variable_set(
          "@#{@account_type.singularize}",
          @account_type.classify.constantize.find(account_id)
        )
      ).school_id == School.get_school_info(@school.abbr)[0]
    )
  end
  
  
  def check_corporation_allow_query
    jump_to("/errors/unauthorized") unless @corporation.allow_query
  end
  
  # ====================
  
  
  def login?
    session[:account_type] && session[:account_id] && session[:account_id] > 0
  end
  
  
  def do_login(account_id, account_type, account_active)
    return do_logout unless account_id && account_type
      
    session[:account_id] = account_id
    session[:account_type] = account_type
    session[:account_active] = account_active
  end
  
  
  def do_logout
    reset_session
  end
  
  
  def set_login_cookie(loginid, logintype, save_loginid = true)
    cookies[:logintype] = { :value => logintype, :expires => 1.year.from_now }
    if save_loginid
      cookies[:loginid] = { :value => loginid, :expires => 30.days.from_now }
    else
      cookies.delete(:loginid)
    end
  end
  
  
  def save_original_address
    session[:original_url] = request.request_uri
    session[:original_method] = request.method
    session[:original_params] = request.parameters.reject {|key, value| !value.kind_of?(String) }
  end
  
  
  def redirect_to_original_address
    original_url = session[:original_url]
    original_method = session[:original_method]
    original_params = session[:original_params]
    session[:original_params] = nil
    session[:original_method] = nil
    session[:original_url] = nil
    
    if original_method != :get && original_params
      original_params[:authenticity_token] = form_authenticity_token
      redirect_non_get(original_params)
    else
      jump_to(original_url || "/")
    end
  end
  
  
  def redirect_non_get(redirect_post_params)
    controller_name = redirect_post_params[:controller]
    controller = "#{controller_name.camelize}Controller".constantize
    
    # Throw out existing params and merge the stored ones
    # to simulate the original request
    request.parameters.reject! { true }
    request.parameters.merge!(redirect_post_params)
    
    # controller.process(request, response)
    # Now could invoke the public API - Controller.call(request.env)
    controller.call(request.env)
    
    if response.redirected_to
      @performed_redirect = true
    else
      @performed_render = true
    end
  end
  
  
  def performed_render_or_redirect
    @performed_render || @performed_redirect
  end
  
  
  def jump_to(url)
    if request.xhr?
      # render :update do |page|
      #   page.redirect_to url
      # end
      
      render :layout => false, :inline => %Q!
        <script type="text/javascript">window.location.href = "#{url}";</script>
      !
    else
      redirect_to(url)
    end
  end
  
  
  def self.insert_before_filter(position, *filters)
    index = filter_chain.map(&:method).index(position)
    
    filter_chain.insert(
      index,
      filter_chain.create_filters(filters, :before)
    ).flatten!
  end


  def img_code_correct?
    correct = (session[:img_code] == params[:img_code])
    flash.now[:error_msg] = "请输入正确的验证码" unless correct
    correct
  end
  
  
  def add_utf8_bom(str)
    "EFBBBF".to_a.pack("H*") + str
  end
  
end
