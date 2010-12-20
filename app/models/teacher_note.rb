class TeacherNote < ActiveRecord::Base
  
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"


  validates_presence_of :target_type_id, :target_id, :teacher_id
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 500, :message => "内容 超过长度限制", :allow_nil => false
  
end
