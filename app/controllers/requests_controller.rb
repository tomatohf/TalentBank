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
    @account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    @counts = Request.send(@sent ? "count_sent_by_type" : "count_by_type", @account_type, @account_id)
    
    @type = Request::Type.find_by(:name, params[:type])
    account_key = @sent ? "requester" : "account"
    conditions = if @type
      [
        "#{account_key}_type_id = ? and #{account_key}_id = ? and type_id = ?",
        account_type[:id], @account_id, @type[:id]
      ]
    else
      [
        "#{account_key}_type_id = ? and #{account_key}_id = ?",
        account_type[:id], @account_id
      ]
    end
    
    @page = params[:page].to_i
    total_count = @counts.values.sum
    @page = [@page, (total_count.to_f / Request_Page_Size).ceil].min
    @page = [@page, 1].max
    
    @requests = if total_count > 0
      Request.paginate(
        :page => @page,
        :per_page => Request_Page_Size,
        :total_entries => total_count,
        :conditions => conditions,
        :order => "updated_at ASC" # "order by updated_at" causes MySql to "using filesort"
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
    current_page = params[:current_page]
    current_type = params[:current_type]
    request = Request.find(params[:id])
    
    account_type = AccountType.find_by(:name, @account_type)
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    if request.account_type_id == account_type[:id] && request.account_id == account_id
      url = request.accept
      
      request.destroy
    end
    
    url ||= build_url(
      "/#{@account_type}/#{account_id}/notifications/requests",
      current_page, current_type
    )
    jump_to(url)
  end
  
  
  def destroy
    current_page = params[:current_page]
    current_type = params[:current_type]
    request = Request.find(params[:id])
    
    account_type = AccountType.find_by(:name, @account_type)
    account_id = self.instance_variable_get("@#{@account_type.singularize}").id
    
    is_account = request.account_type_id == account_type[:id] && request.account_id == account_id
    is_requester = request.requester_type_id == account_type[:id] && request.requester_id == account_id
    
    request.destroy if is_account || is_requester
    
    url = if current_page.blank?
      Request::TypeAdapter.new(Request::Type.find(request.type_id)[:name]).reference_url(request, is_requester)
    else
      build_url(
        "/#{@account_type}/#{account_id}/notifications/requests" + (is_requester ? "/sent" : ""),
        current_page, current_type
      )
    end

    jump_to(url)
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
  
  
  def build_url(base, current_page, current_type)
    url_params = []
    url_params << "page=#{current_page}" unless current_page.blank?
    url_params << "type=#{current_type}" unless current_type.blank?
    base + (url_params.size > 0 ? ("?" + url_params.join("&")) : "")
  end
  
end
