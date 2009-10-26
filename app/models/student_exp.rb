class StudentExp < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  validates_presence_of :period, :message => "请输入 时间段"
  validates_length_of :period, :maximum => 25, :message => "时间段 超过长度限制", :allow_nil => false
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_length_of :title, :maximum => 25, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_length_of :sub_title, :maximum => 15, :message => "子标题 超过长度限制", :allow_nil => true
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 500, :message => "内容 超过长度限制", :allow_nil => false
  
end
