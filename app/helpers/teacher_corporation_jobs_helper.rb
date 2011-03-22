module TeacherCorporationJobsHelper

  def remove_newline(text)
    text.gsub(/\r\n?/, "\n").gsub!(/\n+/, "")
  end
  
  
  def sms(corporation, job)
    district = JobDistrict.find(job.district_id)
    result = JobResult.find(job.result_id)
    
    %Q!#{corporation.get_name}›#{job.get_name}:#{remove_newline(job.requirement)}#{result && result[:name]}。! +
    %Q!工作地址:#{district && "#{district[:name]}›"}#{job.place}。! +
    "有意申请该岗位者，请于2小时内致电60517703或60516910".gsub(/\s/, "")
  end
  
end
