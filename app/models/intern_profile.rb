class InternProfile < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  
  validates_presence_of :student_id
  
  validates_presence_of :begin_at, :message => "请输入 上岗时间"
  validates_presence_of :period_id, :message => "请输入 工作期限"
  validates_presence_of :workday_id, :message => "请输入 每周工作时间"
  validates_presence_of :major_id, :message => "请输入 相关专业"
  validates_presence_of :salary, :message => "请输入 薪酬"
  
  validates_numericality_of :salary, :message => "薪酬 必须是大于等于0的数字", :allow_nil => false, :greater_than_or_equal_to => 0
  
  
  
  Belongs_To_Keys = [:student_id]
  include Utils::UniqueBelongs
  
end
