class CorpQueryMark < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  belongs_to :query, :class_name => "CorpQuery", :foreign_key => "query_id"
  
  
  validates_presence_of :corporation_id, :query_id
  
  validates_presence_of :name, :message => "请输入 名称"
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  
end
