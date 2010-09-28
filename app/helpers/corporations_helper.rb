module CorporationsHelper

  def fill_corporation_profile(profile, params)
    profile.email = params[:email] && params[:email].strip
    profile.phone = params[:phone] && params[:phone].strip
    profile.contact = params[:contact] && params[:contact].strip
    profile.contact_gender = case params[:contact_gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    profile.contact_title = params[:contact_title] && params[:contact_title].strip
    
    profile.business_scope = params[:business_scope] && params[:business_scope].strip
    profile.address = params[:address] && params[:address].strip
    profile.zip = params[:zip] && params[:zip].strip
    profile.website = params[:website] && params[:website].strip
    
    profile.nature_id = params[:nature]
    profile.size_id = params[:size]
    profile.industry_category_id = params[:industry_category]
    profile.industry_id = params[:industry]
    profile.province_id = params[:province]
    profile.city_id = params[:city]
    
    profile.desc = params[:desc] && params[:desc].strip
  end
  
end
