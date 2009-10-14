class ResumeExpTagger < ActiveRecord::Base
  
  belongs_to :exp, :class_name => "ResumeExp", :foreign_key => "exp_id"
  
  
  validates_presence_of :exp_id, :tag_id
  
  
  
  Belongs_To_Keys = [:exp_id, :tag_id]
  include Utils::UniqueBelongs
  
  
  def self.check_tag_domain(tag_id, domain_id)
    ResumeExpTag.find(domain_id, tag_id)
  end
  
end
