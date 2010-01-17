class RequestsController < NotificationsController
  
  Request_Page_Size = 15
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy, :accept]
  )
  
  
  def show
    jump_to("/errors/forbidden")
  end
  
  
  def index
    account_type = AccountType.find_by(:name, @account_type) || {}
    
    account_key = @sent ? "requester" : "account"
    
    @page = params[:page]
    @page = 1 unless @page =~ /\d+/
    @requests = Request.paginate(
      :page => @page,
      :per_page => Request_Page_Size,
      :conditions => [
        "#{account_key}_type_id = ? and #{account_key}_id = ?",
        account_type[:id],
        self.instance_variable_get("@#{@account_type.singularize}").id
      ]
    )
    
    @accounts = prepare_accounts(@requests, @sent)
    
    render :layout => @account_type unless @sent
  end
  
  def sent
    @sent = true
    index
    render :layout => @account_type, :action => "index"
  end
  
  
  def create
    request_data = Request.generate(
      @account_type, self.instance_variable_get("@#{@account_type.singularize}"),
      params[:type] && params[:type].strip,
      params
    )
    
    return jump_to("/errors/forbidden") unless request_data
    
    render(
      :partial => "/requests/request",
      :object => request_data[0],
      :locals => {
        :accounts => request_data[1],
        :sent => true
      }
    )
  end
  
  
  def accept
    page = params[:page]
    request = Request.find(params[:id])
    
    account_type = AccountType.find_by(:name, @account_type)
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    #request.destroy if request.account_type_id == account_type[:id] && request.account_id == account_id

    if page.blank?
      
    else
      jump_to(%Q!/#{@account_type}/#{account_id}/notifications/requests!)
    end
  end
  
  
  def destroy
    page = params[:page]
    request = Request.find(params[:id])
    
    account_type = AccountType.find_by(:name, @account_type)
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    is_account = request.account_type_id == account_type[:id] && request.account_id == account_id
    is_requester = request.requester_type_id == account_type[:id] && request.requester_id == account_id
    
    #request.destroy if is_account || is_requester

    if page.blank?
      
    else
      jump_to(%Q!/#{@account_type}/#{account_id}/notifications/requests#{"/sent" if is_requester}!)
    end
  end
  
  
  private
  
  def prepare_accounts(requests, sent)
    account_ids = AccountType.data.inject({}) do |hash, account_type|
  		hash[account_type[:name]] = []
  		hash
  	end
    
    account_key = sent ? "account" : "requester"
    requests.each do |request|
      account_type = AccountType.find(request.send("#{account_key}_type_id"))
      account_ids[account_type[:name]] << request.send("#{account_key}_id")
    end
    
    
    accounts = {}
    account_ids.each do |key, value|
      accounts[key] = if value.size > 0
        key.classify.constantize.find(
          :all,
          :conditions => ["id in (?)", value.uniq.compact]
        ).inject({}) { |hash, account|
    			hash[account.id] = account
    			hash
    		}
  		else
  		  {}
		  end
    end
    
    accounts
  end
  
end
