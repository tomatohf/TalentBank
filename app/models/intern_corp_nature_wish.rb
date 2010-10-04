class InternCorpNatureWish < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id, :nature_id
  
  
  Belongs_To_Keys = [:student_id, :nature_id]
  include Utils::UniqueBelongs
  
  
  include Utils::InternWishHelpers
  
end
