class Postman < ActionMailer::Base
  
  helper :application
  
  
  def self.source
    "乔布堂"
  end
  
  def self.from
    "#{source} <noreply@qiaobutang.com>"
  end
  
  
  def interview_result_passed_notification(student, student_profile, job, corporation)
    recipients(
      [
        student_profile.email
      ]
    )
    
    from(self.class.from)
    subject("青年岗位见习行动-面试通知反馈 - 面试通过")
    body(
      :student => student,
      :student_profile => student_profile,
      :job => job,
      :corporation => corporation
    )
    content_type "text/html"
  end
  
  def interview_result_failed_notification(student, student_profile, job, corporation)
    recipients(
      [
        student_profile.email
      ]
    )
    
    from(self.class.from)
    subject("青年岗位见习行动-面试通知反馈")
    body(
      :student => student,
      :student_profile => student_profile,
      :job => job,
      :corporation => corporation
    )
    content_type "text/html"
  end
  
end
