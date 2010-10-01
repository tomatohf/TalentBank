class InternJobDistrictWish < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id, :job_district_id
  
  
  Belongs_To_Keys = [:student_id, :job_district_id]
  include Utils::UniqueBelongs
  
end
