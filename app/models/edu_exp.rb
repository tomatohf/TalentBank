class EduExp < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  validates_length_of :university, :maximum => 25, :message => "大学 超过长度限制", :allow_nil => true
  validates_length_of :college, :maximum => 25, :message => "学院 超过长度限制", :allow_nil => true
  validates_length_of :major, :maximum => 25, :message => "专业 超过长度限制", :allow_nil => true
  
  validates_length_of :edu_type, :maximum => 25, :message => "教育类型 超过长度限制", :allow_nil => true
  
end
