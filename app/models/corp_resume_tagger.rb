class CorpResumeTagger < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corp_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  belongs_to :tag, :class_name => "CorpResumeTag", :foreign_key => "tag_id"
  
  
  validates_presence_of :corp_id, :resume_id, :tag_id
  
  
  Belongs_To_Keys = [:corp_id, :resume_id, :tag_id]
  include Utils::UniqueBelongs
  
end
