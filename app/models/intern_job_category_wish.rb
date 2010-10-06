class InternJobCategoryWish < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id, :job_category_class_id
  
  
  Belongs_To_Keys = [:student_id, :job_category_class_id, :job_category_id]
  include Utils::UniqueBelongs
  
  
  include Utils::InternWishHelpers
  
end
