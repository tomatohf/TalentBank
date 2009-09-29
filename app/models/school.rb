class School < ActiveRecord::Base
  
  validates_presence_of :abbreviation, :message => "请输入 英文缩写"
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :abbreviation, :maximum => 15, :message => "英文缩写 超过长度限制", :allow_nil => false
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  
  validates_uniqueness_of :abbreviation, :case_sensitive => false, :message => "英文缩写 已经存在"
  
end