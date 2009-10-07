class ResumeExpSection < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  has_many :exps, :class_name => "ResumeExp", :foreign_key => "section_id", :dependent => :destroy
  
  
  validates_presence_of :resume_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_length_of :title, :maximum => 25, :message => "标题 超过长度限制", :allow_nil => false
  
end
