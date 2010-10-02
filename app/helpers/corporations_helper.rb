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
  
  
  def fill_corporation_job(job, params)
    job.name = params[:name] && params[:name].strip
    job.category_class_id = params[:job_category_class]
    job.category_id = params[:job_category]
    job.manager = params[:manager] && params[:manager].strip
    job.desc = params[:desc] && params[:desc].strip
    job.district_id = params[:job_district]
    job.place = params[:place] && params[:place].strip
    job.salary = params[:salary] && params[:salary].strip
    job.welfare = params[:welfare] && params[:welfare].strip
    job.number = params[:number] && params[:number].strip
    job.interview_number = params[:interview_number] && params[:interview_number].strip
    
    
    job.begin_at = params[:begin_at] && params[:begin_at].strip
    job.period_id = params[:job_period]
    job.workday_id = params[:job_workday]
    job.edu_level_id = params[:edu_level]
    job.graduation_id = params[:job_graduation]
    job.major_id = params[:job_major]
    job.requirement = params[:requirement] && params[:requirement].strip
    job.recruit_end_at = params[:recruit_end_at] && params[:recruit_end_at].strip
  end
  
end
