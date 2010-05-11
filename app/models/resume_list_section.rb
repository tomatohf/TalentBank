class ResumeListSection < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_length_of :title, :maximum => 25, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 500, :message => "内容 超过长度限制", :allow_nil => false
  
end
