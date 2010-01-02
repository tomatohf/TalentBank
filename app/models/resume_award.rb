class ResumeAward < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_length_of :content, :maximum => 250, :message => "荣誉和奖励 超过长度限制", :allow_nil => true
  
  
  
  Belongs_To_Keys = [:resume_id]
  include Utils::UniqueBelongs
  
end
