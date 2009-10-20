class CorpQuery < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  has_many :tags, :class_name => "CorpQueryExpTag", :foreign_key => "query_id", :dependent => :destroy
  has_many :skills, :class_name => "CorpQuerySkill", :foreign_key => "query_id", :dependent => :destroy
  
  has_many :marks, :class_name => "CorpQueryMark", :foreign_key => "query_id", :dependent => :destroy
  
  
  
  def fill()
    
  end
  
  
  def tags
    # TODO - parse out the tag ids from conditions field ...
    []
  end
  
end
