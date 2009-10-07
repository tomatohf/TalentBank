class ResumeSimpleContent < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_length_of :job_intentions, :maximum => 250, :message => "求职意向 超过长度限制", :allow_nil => true
  
  validates_length_of :hobbies, :maximum => 250, :message => "特长和爱好 超过长度限制", :allow_nil => true
  
  validates_length_of :awards, :maximum => 250, :message => "荣誉和奖励 超过长度限制", :allow_nil => true
  
end
