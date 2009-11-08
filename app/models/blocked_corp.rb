class BlockedCorp < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  validates_presence_of :student_id, :corporation_id
  
  
  Belongs_To_Keys = [:student_id, :corporation_id]
  include Utils::UniqueBelongs
  
  
  after_save { |blocked_corp|
    Student.renew_resume_updated_at(blocked_corp.student_id, blocked_corp.updated_at)
  }
  
  after_destroy { |blocked_corp|
    Student.renew_resume_updated_at(blocked_corp.student_id, Time.now)
  }
  
end
