class ResumeSkill < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  belongs_to :student_skill, :class_name => "StudentSkill", :foreign_key => "student_skill_id"
  
  
  validates_presence_of :resume_id, :student_skill_id
  
  
  Belongs_To_Keys = [:resume_id, :student_skill_id]
  include Utils::UniqueBelongs
  
end
