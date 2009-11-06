class StudentProfileCopy < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  # validates_presence_of :phone, :message => "请输入 电话"
  # validates_length_of :phone, :maximum => 25, :message => "电话 超过长度限制", :allow_nil => false
  # 
  # validates_presence_of :email, :message => "请输入 电子邮件"
  # validates_length_of :email, :maximum => 250, :message => "电子邮件 超过长度限制", :allow_nil => false
  # 
  # 
  # validates_length_of :address, :maximum => 250, :message => "地址 超过长度限制", :allow_nil => true
  # 
  # validates_length_of :zip, :maximum => 10, :message => "邮编 超过长度限制", :allow_nil => true
  
  
  Belongs_To_Keys = [:student_id]
  include Utils::UniqueBelongs
  
  
  def self.copy_profile(profile)
    copy = self.get_record(profile.student_id)
    
    copy.phone = profile.phone
    copy.email = profile.email
    
    copy.address = profile.address
    copy.zip = profile.zip
    copy.gender = profile.gender
    copy.political_status_id = profile.political_status_id
    
    copy.save
  end
  
end
