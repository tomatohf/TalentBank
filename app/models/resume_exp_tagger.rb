class ResumeExpTagger < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id, :tag_id
  
  
  Belongs_To_Keys = [:resume_id, :tag_id]
  include Utils::UniqueBelongs
  
  
  def self.check_tag_domain(tag_id, domain_id)
    ResumeExpTag.find(domain_id, tag_id)
  end
  
end
