class CorpSavedQueriesController < ApplicationController
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_corporation
  
  before_filter :check_saved_query, :except => [:index, :create]
  
  before_filter :check_corporation_allow
  
  
  def create
    @query = CorpSavedQuery.new(
      :corporation_id => @corporation.id,
      :conditions => CorporationsController.helpers.collect_query_conditions(params, :keyword_input),
      :name => params[:name] && params[:name].strip
    )

    if @query.save
      render :layout => false, :text => %Q!
        <p class="success_msg">
          操作成功, 查询条件已保存
        </p>
      !
    else
      render :layout => false, :inline => %Q!
    	  <p class="error_msg">
          保存失败, 再试一次吧
          <% if @query.errors.size > 0 %>
            <br />
          	<%= list_model_validate_errors(@query) %>
          <% end %>
        </p>
      !
    end
  end
  
  
  def index
    
  end
  
  
  def edit
    
  end
  
  def update
    
  end
  
  
  def destroy
    
  end
  
  
  private
  
  def check_corporation
    corporation_id = params[:corporation_id] && params[:corporation_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == corporation_id) && ((@corporation = Corporation.find(corporation_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_saved_query
    @saved_query = CorpSavedQuery.find(params[:id])
    jump_to("/errors/forbidden") unless @saved_query.corporation_id == @corporation.id
  end
  
  
  def check_corporation_allow
    jump_to("/errors/unauthorized") unless @corporation.allow
  end
  
end
