class InternCorporationWish < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  validates_presence_of :student_id, :corporation_id
  
  
  Belongs_To_Keys = [:student_id, :corporation_id]
  include Utils::UniqueBelongs
  
  
  include Utils::InternWishHelpers
  
end
