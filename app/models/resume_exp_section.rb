class ResumeExpSection < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  has_many :exps, :class_name => "ResumeExp", :foreign_key => "section_id", :dependent => :destroy
  has_many :resume_student_exps, :class_name => "ResumeStudentExp", :foreign_key => "section_id", :dependent => :destroy
  
  
  validates_presence_of :resume_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_length_of :title, :maximum => 25, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  Student_Exp = 1
  Resume_Exp = 2
  
  Sep_Exp = "_"
  Sep_Pair = "-"
  
  def self.parse_exp_order(order)
    (order || "").split(Sep_Exp).collect { |pair| pair.split(Sep_Pair) }
  end
  
  def get_exp_order
    self.class.parse_exp_order(self.exp_order)
  end
  
  def set_exp_order(order)
    self.exp_order = order.collect{|pair| pair.join(Sep_Pair)}.join(Sep_Exp)
  end
  
  def add_exp_order(exp_type, exp_id)
    order = get_exp_order
    order << [exp_type, exp_id]
    set_exp_order(order)
  end
  
  def remove_exp_order(exp_type, exp_id)
    order = get_exp_order
    
    position = -1
    order.each_index do |i|
      if order[i][0] == exp_type.to_s && order[i][1] == exp_id.to_s
        position = i
        break
      end
    end
    order.delete_at(position) if position > 0
    
    set_exp_order(order)
  end
  
  def self.build_order_pair(exp_type, exp_id)
    [exp_type, exp_id].join(Sep_Pair)
  end
  
end
