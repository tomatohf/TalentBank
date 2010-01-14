class RequestsController < NotificationsController
  
  Request_Page_Size = 15
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy]
  )
  
  
  def show
    jump_to("/errors/forbidden")
  end
  
  
  def index
    account_type = AccountType.find_by(:name, @account_type) || {}
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @requests = Request.paginate(
      :page => page,
      :per_page => Request_Page_Size,
      :conditions => [
        "account_type_id = ? and account_id = ?",
        account_type[:id],
        self.instance_variable_get("@#{@account_type.singularize}").id
      ]
    )
    
    render :layout => @account_type
  end
  
  
  def destroy
    
  end
  
  
  private
  
  
  
end
