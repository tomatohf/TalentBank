class ResumeHobby < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_length_of :content, :maximum => 250, :message => "特长和爱好 超过长度限制", :allow_nil => true
  
  
  
  Belongs_To_Key = :resume_id
  include Utils::UniqueBelongs
  
end
