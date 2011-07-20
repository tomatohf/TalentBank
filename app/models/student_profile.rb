class StudentProfile < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  validates_presence_of :phone, :message => "请输入 电话"
  validates_length_of :phone, :maximum => 25, :message => "电话 超过长度限制", :allow_nil => false
  
  validates_presence_of :email, :message => "请输入 电子邮件"
  validates_length_of :email, :maximum => 250, :message => "电子邮件 超过长度限制", :allow_nil => false
  
  
  validates_length_of :address, :maximum => 250, :message => "地址 超过长度限制", :allow_nil => true
  
  validates_length_of :zip, :maximum => 10, :message => "邮编 超过长度限制", :allow_nil => true
  
  
  after_save { |student_profile|
    student_profile.student.renew_updated_at(student_profile.updated_at)
    student_profile.student.renew_resume_updated_at(student_profile.updated_at)
    
    StudentProfileCopy.copy_profile(student_profile)
  }
  
  after_create { |student_profile|
    Postman.deliver_student_created_mail(student_profile.student, student_profile) unless student_profile.email.blank?
  }
  
  
  Belongs_To_Keys = [:student_id]
  include Utils::UniqueBelongs
  
end
