# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def render_school_view(template, school_abbr)
    school_abbr = ::DEFAULT_SCHOOL_VIEW unless File.exist?("#{RAILS_ROOT}/app/views#{template}/_#{school_abbr}.html.erb")
    render(:partial => "#{template}/#{school_abbr}")
  end
  
  
  def talent_page_title(page_title)
    content_for(:page_title) { page_title }
  end
  
  
  def list_model_validate_errors(model)
    errors = ""
    model.errors.each do |attr, error|
      errors += "#{error}<br />"
    end
    errors
  end
  
end
