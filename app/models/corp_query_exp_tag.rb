class CorpQueryExpTag < ActiveRecord::Base
  
  belongs_to :query, :class_name => "CorpQuery", :foreign_key => "query_id"
  
  
  validates_presence_of :query_id, :tag_id
  
end
