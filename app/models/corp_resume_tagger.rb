class CorpResumeTagger < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corp_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  belongs_to :tag, :class_name => "CorpResumeTag", :foreign_key => "tag_id"
  
  
  validates_presence_of :corp_id, :resume_id, :tag_id
  
  
  Belongs_To_Keys = [:corp_id, :resume_id, :tag_id]
  include Utils::UniqueBelongs
  
  
  def self.corp_resume_taggers(corp_id, resume_id)
    self.find(
      :all,
      :conditions => ["corp_id = ? and resume_id in (?)", corp_id, [resume_id].flatten],
      :include => [:tag]
    )
  end
  
  def self.corp_resume_tags(corp_id, resume_id)
    self.corp_resume_taggers(corp_id, resume_id).group_by(&:resume_id).inject({}) do |resume_tags, (resume_id, taggers)|
      resume_tags[resume_id] = taggers.collect { |tagger| tagger.tag.name }
      resume_tags
    end
  end
  
  
  def self.corp_tags(corp_id, count = false)
    self.find(
      :all,
      :select => %Q!corp_resume_taggers.*#{", count(resume_id) as count" if count}!,
      :conditions => ["corp_id = ?", corp_id],
      :from => "corp_resume_taggers USE INDEX(index_corp_resume_taggers_on_corp_id_and_tag_id_and_created_at)",
      :group => "tag_id",
      :include => [:tag]
    ).collect { |tagger| count ? [tagger.tag.name, tagger.count] : tagger.tag.name }
  end
  
  
  def self.corp_saved_count(corp_id)
    self.count(
      :resume_id,
      :conditions => ["corp_id = ?", corp_id],
      :distinct => true
    )
  end
  
end
