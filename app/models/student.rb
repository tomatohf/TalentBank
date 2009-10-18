class Student < ActiveRecord::Base
  
  belongs_to :school, :class_name => "School", :foreign_key => "school_id"
  
  has_one :profile, :class_name => "StudentProfile", :foreign_key => "student_id", :dependent => :destroy
  
  
  attr_protected :enabled, :active
  
  validates_presence_of :school_id
  
  validates_presence_of :number, :message => "请输入 学号"
  validates_presence_of :password, :message => "请输入 密码"
  validates_presence_of :name, :message => "请输入 姓名"
  
  validates_length_of :number, :maximum => 25, :message => "学号 超过长度限制", :allow_nil => false
  validates_length_of :name, :maximum => 25, :message => "姓名 超过长度限制", :allow_nil => false
  
  validates_uniqueness_of :number, :case_sensitive => false, :scope => :school_id, :message => "学号 已经存在"
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :message => "密码 与 确认密码 不相同"
  
  
  named_scope :enabled, :conditions => { :enabled => true }
  named_scope :active, :conditions => { :active => true }
  
  
  
  def self.authenticate(abbr, number, pwd)
    student = self.get_from_number(abbr, number)
    student = nil if student && (student.password != pwd)
    student
  end
  
  def self.get_from_number(abbr, number)
    self.find(:first, :conditions => ["school_id = ? and number = ?", School.get_school_info(abbr)[0], number])
  end
  
end
