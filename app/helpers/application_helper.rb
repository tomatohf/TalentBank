# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def format_datetime(datetime)
    datetime && to_local_time(datetime).strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def format_date(date)
    date && to_local_time(date).strftime("%Y-%m-%d")
  end
  
  def format_short_date(date)
    date && to_local_time(date).strftime("%y-%m-%d")
  end
  
  def format_short_datetime(date)
    date && to_local_time(date).strftime("%y-%m-%d %H:%M:%S")
  end
  
  def format_zh_date(date)
    date && (date = to_local_time(date)) && %Q!#{date.year}年#{date.month}月#{date.mday}日 星期#{["天", "一", "二", "三", "四", "五", "六"][date.wday]}!
  end
  
  def format_time(date)
    date && to_local_time(date).strftime("%H:%M:%S")
  end
  
  def to_local_time(datetime)
    if datetime.kind_of?(DateTime)
      Time.local(datetime.year, datetime.month, datetime.mday, datetime.hour, datetime.min, datetime.sec)
    else
      datetime.to_time
    end.getlocal
  end
  
  def day_end(date)
    Time.local(date.year, date.month, date.mday, 23, 59, 59)
  end
  
  
  def paging_buttons(collection, params = {})
    will_paginate(
      collection,
      :previous_label => params.delete(:previous_label) || "‹ 上一页",
      :next_label => params.delete(:next_label) || "下一页 ›",
      :param_name => :page, # parameter name for page number in URLs (default: :page)
      :page_links => true, # when false, only previous/next links are rendered (default: true) 
      # :separator => "", # string separator for page HTML elements (default: single space)
      # :inner_window => 4, # how many links are shown around the current page (default: 4)
      # :outer_window => 1, # how many links are around the first and the last page (default: 1)
      :class => params.delete(:class) || "pagination", # CSS class name for the generated DIV (default: "pagination")
      :params => params # additional parameters when generating pagination links (eg. :controller => "foo", :action => nil)
    ) if collection && collection.size > 0
  end
  
  
  def render_school_partial(partial, school_abbr, options = {})
    path = school_partial_root(school_abbr)
    path = school_partial_root("base") unless File.exist?("#{RAILS_ROOT}/app/views#{path}/_#{partial}.html.erb")
    render(:partial => "#{path}/#{partial}", :locals => options)
  end
  def school_partial_root(school_abbr)
    "/common/school_partials/#{school_abbr}"
  end
  
  
  def talent_page_title(page_title)
    content_for(:page_title) { page_title }
  end
  
  
  def list_model_validate_errors(model)
    model.errors.map { |attr, error|
      error
    }.join("<br />")
  end
  
  
  def required_mark(bracket = true)
    %Q!#{"(" if bracket}<font color="red">*</font>#{")" if bracket}!
  end
  
  
  def attribute_escape(text)
    # remove single quotes, so that it can be used in html attribute safely
    text.gsub("'", "")
  end
  alias a attribute_escape
  
end
