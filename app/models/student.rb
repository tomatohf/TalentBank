class Student < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :school, :class_name => "School", :foreign_key => "school_id"
  
  has_one :profile, :class_name => "StudentProfile", :foreign_key => "student_id", :dependent => :destroy
  has_one :job_photo, :class_name => "JobPhoto", :foreign_key => "student_id", :dependent => :destroy
  has_many :edu_exps, :class_name => "EduExp", :foreign_key => "student_id", :dependent => :destroy
  
  has_many :resumes, :class_name => "Resume", :foreign_key => "student_id", :dependent => :destroy
  
  has_many :blocked_corps, :class_name => "BlockedCorp", :foreign_key => "student_id", :dependent => :destroy
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes number, name
    
    has school_id, university_id, college_id, major_id, edu_level_id, graduation_year, updated_at
    
    set_property(
      :delta => DailyDelta,
      :column => :updated_at,
      # :rate => 70.minutes,
      :hour => Overall_Index_Hour,
      :minute => Overall_Index_Minute,
      :batch => 100
    )
    
  end
  
  
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
  
  
  include Utils::NotDeletable
  
  after_save { |student|
    student.renew_resume_updated_at(student.updated_at)
  }
  
  
  
  def self.authenticate(abbr, number, pwd)
    student = self.get_from_number(abbr, number)
    student = nil if student && (student.password != pwd)
    student
  end
  
  def self.get_from_number(abbr, number)
    self.find(:first, :conditions => ["school_id = ? and number = ?", School.get_school_info(abbr)[0], number])
  end
  
  
  def renew_resume_updated_at(time)
    self.class.renew_resume_updated_at(self.id, time)
  end
  def self.renew_resume_updated_at(student_id, time)
    Resume.find(
      :all,
      :conditions => ["student_id = ?", student_id]
    ).each do |resume|
      resume.after_change(time)
    end
  end
  
  
  def self.school_search(name, school_id, includes, page = 1, per_page = 10, options = {})
    filters = {:school_id => school_id}
    [:university_id, :college_id, :major_id, :edu_level_id, :graduation_year].each do |filter_key|
      filter_value = options[filter_key]
      filters.merge!(filter_key => filter_value) unless filter_value.blank?
    end
    
    self.search(
      name,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, updated_at DESC",
      :field_weights => {},
      :with => filters,
      :include => includes
    )
  end
  
  
  def get_name
    self.name
  end
  
end
