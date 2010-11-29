class CorporationRecord < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"


  validates_presence_of :corporation_id
  
  validates_presence_of :notes, :message => "请输入 内容"
  validates_length_of :notes, :maximum => 500, :message => "内容 超过长度限制", :allow_nil => false
  
end
