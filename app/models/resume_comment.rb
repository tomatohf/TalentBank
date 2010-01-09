class ResumeComment < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id, :account_type_id, :account_id
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 1000, :message => "内容 超过长度限制", :allow_nil => false
  
end
