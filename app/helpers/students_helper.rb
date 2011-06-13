module StudentsHelper

  def fill_student_editable_fields(student, params)
    student.name = params[:name] && params[:name].strip
    
    student.university_id = params[:university_id]
    student.college_id = params[:college_id]
    student.major_id = params[:major_id]
    student.edu_level_id = params[:edu_level_id]
    student.graduation_year = params[:graduation_year]
  end
  
  
  def fill_student_profile(profile, params)
    profile.phone = params[:phone] && params[:phone].strip
    profile.email = params[:email] && params[:email].strip
    
    profile.address = params[:address] && params[:address].strip
    profile.zip = params[:zip] && params[:zip].strip
    
    profile.gender = case params[:gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    profile.political_status_id = params[:political_status]
  end
  
  
  def fill_student_intern_profile(profile, params)
    profile.begin_at = params[:begin_at] && params[:begin_at].strip
    profile.period_id = params[:job_period]
    profile.workday_id = params[:job_workday]
    profile.major_id = params[:job_major]
    profile.salary = params[:salary] && params[:salary].strip
    
    profile.birthplace = params[:birthplace] && params[:birthplace].strip
    profile.birthmonth = params[:birthmonth] && params[:birthmonth].strip
    profile.intention = params[:intention] && params[:intention].strip
    profile.skill = params[:skill] && params[:skill].strip
    profile.experience = params[:experience] && params[:experience].strip
    profile.desc = params[:desc] && params[:desc].strip
  end
  
  
  def fill_student_intern_log(log, params, job)
    log.job_id = job && job.id
    log.event_id = params[:event]
    log.result_id = params[:result]
    log.occur_at = params[:occur_at]
  end
  
  
  def import(students, school, school_id)
    saved = []
    failed = []
    
    universities = school.universities.map { |u_id| University.find(u_id) }
    
    (students.first.kind_of?(Array) ? students : [students]).each_with_index do |s, i|
      begin
        basic = s[0] || {}
        intern = s[1] || {}
        extra = s[2] || {}
        
        number = basic["number"]
        number = "#{Time.now.to_f}.#{i}" if number.blank?
        university = basic["university"]
        university_model = universities.detect { |u| u[:name] == university }
        student = Student.new(
          :school_id => school_id,
          :name => basic["name"],
          :number => number,
          :password => number,
          :edu_level_id => basic["edu_level"],
          :graduation_year => basic["graduation_year"]
        )
        student.university_id = university_model[:id] if university_model
        
        student_profile = StudentProfile.new(
          :phone => basic["phone"],
          :email => basic["email"],
          :gender => Utils.to_boolean(basic["gender"]),
          :political_status_id => basic["political_status"]
        )
        
        intern_profile = InternProfile.new(
          :begin_at => intern["begin_at"],
          :period_id => intern["job_period"],
          :workday_id => intern["job_workday"],
          :major_id => basic["job_major"],
          :salary => 0,
          :birthplace => basic["birthplace"],
          :birthmonth => basic["birthday"],
          :intention => intern["intention"],
          :skill => extra["skill"],
          :experience => extra["experience"],
          :desc => %Q!学校:#{university}\n学院:#{basic["college"]}\n专业:#{basic["major"]}\n服从岗位调剂:#{Utils.to_boolean(intern["allow_adjust"]) ? "是" : "否"}!
        )
        
        ActiveRecord::Base.transaction do
          student.save!
          
          student_profile.student_id = student.id
          student_profile.save!
          
          intern_profile.student_id = student.id
          intern_profile.save!
          
          intern["wishes"].each do |wish|
            wish_model = case wish["aspect"]
              when "job"
                wish_job = wish["job"]
                wish_job.blank? ? InternCorporationWish.new(:corporation_id => wish["corporation"]) : InternJobWish.new(:job_id => wish_job)
              when "industry"
                InternIndustryWish.new(
                  :industry_category_id => wish["industry_category"],
                  :industry_id => wish["industry"]
                )
              when "job_category"
                InternJobCategoryWish.new(
                  :job_category_class_id => wish["job_category_class"],
                  :job_category_id => wish["job_category"]
                )
              when "corp_nature"
                InternCorpNatureWish.new(:nature_id => wish["corp_nature"])
              when "job_district"
                InternJobDistrictWish.new(:job_district_id => wish["job_district"])
              else
                nil
            end
            
            unless wish_model.nil?
              wish_model.student_id = student.id
              wish_model.save!
            end
          end
          
          saved << s
        end
      rescue
        failed << s
      end
    end
    
    [saved, failed]
  end
  
end
