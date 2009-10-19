class CorpQuerySkill < ActiveRecord::Base
  
  belongs_to :query, :class_name => "CorpQuery", :foreign_key => "query_id"
  
  
  validates_presence_of :query_id, :skill_id, :value
  
end
