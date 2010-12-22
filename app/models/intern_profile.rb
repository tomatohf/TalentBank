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
  
  validates_length_of :birthplace, :maximum => 25, :message => "籍贯 超过长度限制", :allow_nil => true
  validates_length_of :birthmonth, :maximum => 10, :message => "出生年月 超过长度限制", :allow_nil => true
  validates_length_of :intention, :maximum => 300, :message => "实习意向 超过长度限制", :allow_nil => true
  validates_length_of :skill, :maximum => 300, :message => "技能证书 超过长度限制", :allow_nil => true
  validates_length_of :experience, :maximum => 1500, :message => "以往工作/实习经历 超过长度限制", :allow_nil => true
  validates_length_of :desc, :maximum => 300, :message => "其它信息 超过长度限制", :allow_nil => true
  
  
  
  Belongs_To_Keys = [:student_id]
  include Utils::UniqueBelongs
  
  
  
  after_save { |profile|
    profile.student.renew_updated_at(profile.updated_at)
  }
  
end
