class ResumeRevision < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"
  
  
  validates_presence_of :resume_id, :teacher_id, :part_type_id, :part_id, :action_id
  
  validates_length_of :data, :maximum => 1000, :message => "修改数据 超过长度限制", :allow_nil => true
  
  
  class Action < HashModel::Simple
    def self.data
      # [
      #   {:id => action_id, :name => action_name, :label => action_label}
      # ]

      [
        {:id => 10, :name => "add", :label => "添加"},
        {:id => 20, :name => "delete", :label => "删除"},
        {:id => 30, :name => "update", :label => "修改"}
      ]
    end
  end
  
  
  include Utils::FieldHashable
  hash_field :data
  
end
