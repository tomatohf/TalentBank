class ResumeListSkill < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_presence_of :name, :message => "请输入 名称"
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  
  validates_length_of :level, :maximum => 15, :message => "程度 超过长度限制", :allow_nil => true
  
end
