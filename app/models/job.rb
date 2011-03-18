class Job < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  
  validates_presence_of :corporation_id
  
  validates_presence_of :name, :message => "请输入 名称"
  validates_presence_of :desc, :message => "请输入 工作内容"
  validates_presence_of :district_id, :message => "请输入 工作区域"
  validates_presence_of :place, :message => "请输入 工作地址"
  validates_presence_of :salary, :message => "请输入 薪酬"
  validates_presence_of :number, :message => "请输入 招聘人数"
  validates_presence_of :recruit_end_at, :message => "请输入 招聘终止日期"
  
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :manager, :maximum => 50, :message => "负责人 超过长度限制", :allow_nil => true
  validates_length_of :desc, :maximum => 500, :message => "工作内容 超过长度限制", :allow_nil => false
  validates_length_of :place, :maximum => 200, :message => "工作地址 超过长度限制", :allow_nil => false
  validates_length_of :welfare, :maximum => 300, :message => "福利待遇 超过长度限制", :allow_nil => true
  validates_length_of :requirement, :maximum => 500, :message => "其它要求 超过长度限制", :allow_nil => true
  
  validates_numericality_of :salary, :message => "薪酬 必须是大于等于0的数字", :allow_nil => false, :greater_than_or_equal_to => 0
  validates_numericality_of :number, :message => "招聘人数 必须是大于等于0的整数", :allow_nil => false, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :interview_number, :message => "面试人数 必须是大于等于0的整数", :allow_nil => true, :greater_than_or_equal_to => 0, :only_integer => true
  
  
  
  def self.list_from_corporation(corporation_id)
    self.find(
      :all,
      :conditions => ["corporation_id = ?", corporation_id],
      :order => "created_at DESC"
    )
  end
  
  
  def get_name
    self.name
  end
  
end
