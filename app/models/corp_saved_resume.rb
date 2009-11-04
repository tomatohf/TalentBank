class CorpSavedResume < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :corporation_id, :resume_id
  
  
  Belongs_To_Keys = [:corporation_id, :resume_id]
  include Utils::UniqueBelongs
  
end
