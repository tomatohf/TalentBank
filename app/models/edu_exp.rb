class EduExp < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  validates_presence_of :period, :message => "请输入 时间段"
  validates_length_of :period, :maximum => 25, :message => "时间段 超过长度限制", :allow_nil => false
  
  validates_length_of :university, :maximum => 25, :message => "大学 超过长度限制", :allow_nil => true
  validates_length_of :college, :maximum => 25, :message => "学院 超过长度限制", :allow_nil => true
  validates_length_of :major, :maximum => 25, :message => "专业 超过长度限制", :allow_nil => true
  
  validates_length_of :edu_type, :maximum => 25, :message => "教育类型 超过长度限制", :allow_nil => true
  
  
  after_save { |edu_exp|
    Student.renew_resume_updated_at(edu_exp.student_id, edu_exp.updated_at)
  }
  
  after_destroy { |edu_exp|
    Student.renew_resume_updated_at(edu_exp.student_id, Time.now)
  }
  
end
