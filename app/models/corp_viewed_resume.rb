class CorpViewedResume < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :corporation_id, :resume_id
  
  
  def self.record(corp_id, resume_id)
    self.new(
      :corporation_id => corp_id,
      :resume_id => resume_id
    ).save
  end
  
end
