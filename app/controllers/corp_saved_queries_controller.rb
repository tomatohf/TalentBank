class CorpSavedQueriesController < ApplicationController
  
  layout "corporations"
  
  
  before_filter :check_login_for_corporation
  
  before_filter :check_active, :only => [:create, :update, :destroy]
  
  before_filter :check_corporation
  
  before_filter :check_saved_query, :except => [:index, :create]
  
  before_filter :check_corporation_allow_query
  
  
  def create
    @saved_query = CorpSavedQuery.new(
      :corporation_id => @corporation.id,
      :conditions => CorpResumesController.helpers.collect_query_conditions(params, :keyword_input),
      :name => params[:name] && params[:name].strip
    )

    if @saved_query.save
      render :layout => false, :text => %Q!
        <p class="success_msg">
          操作成功, 查询条件已保存
        </p>
      !
    else
      render :layout => false, :inline => %Q!
    	  <p class="error_msg">
          保存失败, 再试一次吧
          <% if @saved_query.errors.size > 0 %>
            <br />
          	<%= list_model_validate_errors(@saved_query) %>
          <% end %>
        </p>
      !
    end
  end
  
  
  def index
    @saved_queries = CorpSavedQuery.find(
      :all,
      :conditions => ["corporation_id = ?", @corporation.id],
      :order => "created_at DESC"
    )
  end
  
  
  def edit
    
  end
  
  def update
    @saved_query.name = params[:name] && params[:name].strip
    
    if @saved_query.save
      saved_query_time = ApplicationController.helpers.format_datetime(@saved_query.created_at)
      flash[:success_msg] = "操作成功, 保存于 #{saved_query_time} 的查询的名称已更新"
      return jump_to("/corporations/#{@corporation.id}/corp_saved_queries")
    end
    
    render :action => "edit"
  end
  
  
  def destroy
    @saved_query.destroy
    
    saved_query_time = ApplicationController.helpers.format_datetime(@saved_query.created_at)
    flash[:success_msg] = "操作成功, 已删除保存于 #{saved_query_time} 的查询"
  
    jump_to("/corporations/#{@corporation.id}/corp_saved_queries")
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
  
end
