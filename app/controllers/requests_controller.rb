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
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    @counts = Request.send(@sent ? "count_sent_by_type" : "count_by_type", @account_type, account_id)
    
    account_key = @sent ? "requester" : "account"
    
    @page = params[:page].to_i
    total_count = @counts.values.sum
    @page = [@page, (total_count.to_f / Request_Page_Size).ceil].min
    @page = [@page, 1].max
    
    @requests = if total_count > 0
      Request.paginate(
        :page => @page,
        :per_page => Request_Page_Size,
        :total_entries => total_count,
        :conditions => ["#{account_key}_type_id = ? and #{account_key}_id = ?", account_type[:id], account_id]
      )
    else
      []
    end
    
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
    
    if request.account_type_id == account_type[:id] && request.account_id == account_id
      url = request.accept
      
      request.destroy
    end
    
    url ||= "/#{@account_type}/#{account_id}/notifications/requests" +
            (page.blank? ? "" : "?page=#{page}")
    jump_to(url)
  end
  
  
  def destroy
    page = params[:page]
    request = Request.find(params[:id])
    
    account_type = AccountType.find_by(:name, @account_type)
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    is_account = request.account_type_id == account_type[:id] && request.account_id == account_id
    is_requester = request.requester_type_id == account_type[:id] && request.requester_id == account_id
    
    request.destroy if is_account || is_requester

    jump_to(
      "/#{@account_type}/#{account_id}/notifications/requests" +
      (is_requester ? "/sent" : "") +
      (page.blank? ? "" : "?page=#{page}")
    )
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
