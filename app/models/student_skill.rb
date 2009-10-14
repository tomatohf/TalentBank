class StudentSkill < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_many :resume_skills, :class_name => "ResumeSkill", :foreign_key => "student_skill_id", :dependent => :destroy
  
  
  validates_presence_of :student_id, :skill_id, :value
  
  
  
  Belongs_To_Keys = [:student_id, :skill_id]
  include Utils::UniqueBelongs
  
end
