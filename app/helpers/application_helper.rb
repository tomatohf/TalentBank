# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def format_datetime(datetime)
    datetime && datetime.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def format_date(date)
    date && date.strftime("%Y-%m-%d")
  end
  
  def format_short_date(date)
    date && date.strftime("%y-%m-%d")
  end
  
  def format_short_datetime(date)
    date && date.strftime("%y-%m-%d %H:%M:%S")
  end
  
  def format_zh_date(date)
    date && %Q!#{date.year}年#{date.month}月#{date.mday}日 星期#{["天", "一", "二", "三", "四", "五", "六"][date.wday]}!
  end
  
  def format_time(date)
    date && date.strftime("%H:%M:%S")
  end
  
  
  def paging_buttons(collection, params = {})
    will_paginate(
      collection,
      :previous_label => "‹ 上一页",
      :next_label => "下一页 ›",
      :param_name => :page, # parameter name for page number in URLs (default: :page)
      :page_links => true, # when false, only previous/next links are rendered (default: true) 
      # :separator => "", # string separator for page HTML elements (default: single space)
      # :inner_window => 4, # how many links are shown around the current page (default: 4)
      # :outer_window => 1, # how many links are around the first and the last page (default: 1)
      :class => params.delete(:class) || "pagination", # CSS class name for the generated DIV (default: "pagination")
      :params => params # additional parameters when generating pagination links (eg. :controller => "foo", :action => nil)
    )
  end
  
  
  def render_school_view(template, school_abbr, options = {})
    school_abbr = "base" unless partial_exist?(template, school_abbr)
    school_abbr = ::DEFAULT_SCHOOL_VIEW unless partial_exist?(template, school_abbr)
    render(:partial => "#{template}/#{school_abbr}", :locals => options)
  end
  
  def partial_exist?(path, partial)
    File.exist?("#{RAILS_ROOT}/app/views#{path}/_#{partial}.html.erb")
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
    %Q!
      #{"(" if bracket}<font color="red">*</font>#{")" if bracket}
    !
  end
  
  
  def attribute_escape(text)
    # remove single quotes, so that it can be used in html attribute safely
    text.gsub("'", "")
  end
  alias a attribute_escape
  
end
