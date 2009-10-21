class CorpSavedQuery < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  validates_presence_of :corporation_id
  
  validates_presence_of :name, :message => "请输入 名称"
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  
end
