class CorpQueryExpTag < ActiveRecord::Base
  
  belongs_to :query, :class_name => "CorpQuery", :foreign_key => "query_id"
  
  
  validates_presence_of :query_id, :tag_id
  
  
  
  Belongs_To_Keys = [:tag_id, :query_id]
  include Utils::UniqueBelongs
  
end
