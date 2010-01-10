class NoticesController < NotificationsController
  
  Notice_Page_Size = 30
  
  
  def show
    jump_to("/errors/forbidden")
  end
  
  
  def index
    account_type = AccountType.find_by(:name, @account_type) || {}
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @notices = Notice.paginate(
      :page => page,
      :per_page => Notice_Page_Size,
      :conditions => [
        "account_type_id = ? and account_id = ?",
        account_type[:id],
        self.instance_variable_get("@#{@account_type.singularize}").id
      ],
      :order => "unread DESC, updated_at DESC"
    )
    
    render :layout => @account_type
  end
  
  
  private
  
  
  
end
