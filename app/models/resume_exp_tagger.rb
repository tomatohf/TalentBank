class ResumeExpTagger < ActiveRecord::Base
  
  belongs_to :exp, :class_name => "ResumeExp", :foreign_key => "exp_id"
  
  
  validates_presence_of :exp_id, :tag_id
  
  
  
  def self.get_tagger(exp_id, tag_id)
    tagger = self.find(:first, :conditions => ["exp_id = ? and tag_id = ?", exp_id, tag_id])
    tagger || self.new(:exp_id => exp_id, :tag_id => tag_id)
  end
  
  
  def self.check_tag_domain(tag_id, domain_id)
    ResumeExpTag.find(domain_id, tag_id)
  end
  
end
