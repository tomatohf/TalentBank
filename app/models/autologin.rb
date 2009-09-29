class Autologin < ActiveRecord::Base
  
  attr_protected :session_id, :student_id, :expire_time
  
  validates_presence_of :session_id, :student_id, :expire_time
  
  
  
  def self.delete_by_student(student_id)
    self.delete_all(["student_id = ?", student_id])
  end
  
  def self.find_record(student_id, session_id)
    self.find(:first, :conditions => ["student_id = ? and session_id = ?", student_id, session_id])
  end
  
  def self.get_by_student(student_id)
    self.find(:first, :conditions => ["student_id = ?", student_id])
  end
  
  def self.clear_expired_records
    self.delete_all(["expire_time < ?", Time.now])
  end
  
  def self.delete_record(student_id, session_id)
    self.delete_all(["student_id = ? and session_id = ?", student_id, session_id])
  end
  
end
