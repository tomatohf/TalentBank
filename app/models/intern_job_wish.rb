class InternJobWish < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :job, :class_name => "Job", :foreign_key => "job_id"
  
  
  validates_presence_of :student_id, :job_id
  
  
  Belongs_To_Keys = [:student_id, :job_id]
  include Utils::UniqueBelongs
  
  
  include Utils::InternWishHelpers
  
end
