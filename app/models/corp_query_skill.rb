class CorpQuerySkill < ActiveRecord::Base
  
  belongs_to :query, :class_name => "CorpQuery", :foreign_key => "query_id"
  
  
  validates_presence_of :query_id, :skill_id, :value
  
  
  
  Belongs_To_Keys = [:skill_id, :query_id]
  include Utils::UniqueBelongs
  
end
