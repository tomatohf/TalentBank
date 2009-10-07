class ResumeExpContent < ActiveRecord::Base
  
  belongs_to :exp, :class_name => "ResumeExp", :foreign_key => "exp_id"
  
  
  validates_presence_of :exp_id
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 250, :message => "内容 超过长度限制", :allow_nil => false
  
end
