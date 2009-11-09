class CorpResumeTag < ActiveRecord::Base
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30, :message => "名称 超过长度限制", :allow_nil => false
  
  # the following validation would increase DB SQL query and is NOT necessary
  # since the duplicated :name is avoided at app level
  # and the DB unique index validation would fail when duplicated :name values are found
  # validates_uniqueness_of :name, :case_sensitive => true, :message => "名称 已经存在"
  
  
  
  Belongs_To_Keys = [:name]
  include Utils::UniqueBelongs
  
end
