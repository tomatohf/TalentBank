class ResumeHobby < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_length_of :content, :maximum => 500, :message => "特长和爱好 超过长度限制", :allow_nil => true
  
  
  
  Belongs_To_Keys = [:resume_id]
  include Utils::UniqueBelongs
  
end
