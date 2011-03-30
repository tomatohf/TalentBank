module TeacherCorporationJobsHelper

  def remove_newline(text)
    text.gsub(/\r\n?/, "\n").gsub!(/\n+/, "")
  end
  
  
  def sms_common(corporation, job)
    district = JobDistrict.find(job.district_id)
    result = JobResult.find(job.result_id)
    
    %Q!#{corporation.get_name}，#{job.get_name}:#{remove_newline(job.requirement)}#{result && result[:name]}。! +
    %Q!工作地址:#{district && district[:name].gsub(" ", "")}#{job.place}。!
  end
  
  
  def sms(corporation, job)
    sms_common(corporation, job) +
    "有意申请该岗位者，请于2小时内致电60517703或60516910"
  end
  
  
  def sms_2(corporation, job, teacher)
    email = teacher.email.blank? ? "student@qiaobutang.com" : teacher.email
    
    sms_common(corporation, job) +
    %Q!有意申请该岗位者，请在#{format_date(job.recruit_end_at)}之前，将您的简历发送到#{email}!
  end
  
end
