class ResumeStudentExp < ActiveRecord::Base
  
  belongs_to :section, :class_name => "ResumeExpSection", :foreign_key => "section_id"
  belongs_to :student_exp, :class_name => "StudentExp", :foreign_key => "exp_id"
  
  
  validates_presence_of :section_id, :exp_id
  
  
  Belongs_To_Keys = [:section_id, :exp_id]
  include Utils::UniqueBelongs
  
end
