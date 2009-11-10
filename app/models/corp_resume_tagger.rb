class CorpResumeTagger < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corp_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  belongs_to :tag, :class_name => "CorpResumeTag", :foreign_key => "tag_id"
  
  
  validates_presence_of :corp_id, :resume_id, :tag_id
  
  
  Belongs_To_Keys = [:corp_id, :resume_id, :tag_id]
  include Utils::UniqueBelongs
  
  
  def self.corp_resume_tags(corp_id, resume_id)
    self.corp_resume_taggers(corp_id, resume_id).collect { |tagger| tagger.tag.name }
  end
  
  def self.corp_resume_taggers(corp_id, resume_id)
    self.find(
      :all,
      :conditions => ["corp_id = ? and resume_id = ?", corp_id, resume_id],
      :include => [:tag]
    )
  end
  
  
  def self.corp_tags(corp_id)
    self.find(
      :all,
      :conditions => ["corp_id = ?", corp_id],
      :from => "corp_resume_taggers FORCE INDEX(index_corp_resume_taggers_on_corp_id_and_tag_id_and_created_at)",
      :group => "tag_id",
      :include => [:tag]
    ).collect { |tagger| tagger.tag.name }
  end
  
end
