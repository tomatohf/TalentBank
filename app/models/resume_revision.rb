class ResumeRevision < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"
  
  
  validates_presence_of :resume_id, :teacher_id, :part_type_id, :part_id, :action
  
  validates_length_of :data, :maximum => 1000, :message => "修改数据 超过长度限制", :allow_nil => true
  
  
  Actions = [
    {:id => 10, :name => "add", :label => "添加"},
    {:id => 20, :name => "delete", :label => "删除"},
    {:id => 30, :name => "update", :label => "修改"}
  ]
  
  
  include Utils::FieldHashable
  hash_field :data
  
end
