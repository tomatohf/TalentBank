class Student < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :school, :class_name => "School", :foreign_key => "school_id"
  
  has_one :profile, :class_name => "StudentProfile", :foreign_key => "student_id", :dependent => :destroy
  has_one :job_photo, :class_name => "JobPhoto", :foreign_key => "student_id", :dependent => :destroy
  has_many :edu_exps, :class_name => "EduExp", :foreign_key => "student_id", :dependent => :destroy
  
  has_many :resumes, :class_name => "Resume", :foreign_key => "student_id", :dependent => :destroy
  
  has_many :blocked_corps, :class_name => "BlockedCorp", :foreign_key => "student_id", :dependent => :destroy
  
  has_one :intern_profile, :class_name => "InternProfile", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_industry_wishes, :class_name => "InternIndustryWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_industry_blacklists, :class_name => "InternIndustryBlacklist", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_category_wishes, :class_name => "InternJobCategoryWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_category_blacklists, :class_name => "InternJobCategoryBlacklist", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_corp_nature_wishes, :class_name => "InternCorpNatureWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_corp_nature_blacklists, :class_name => "InternCorpNatureBlacklist", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_district_wishes, :class_name => "InternJobDistrictWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_district_blacklists, :class_name => "InternJobDistrictBlacklist", :foreign_key => "student_id", :dependent => :destroy
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes number, name
    
    has school_id, university_id, college_id, major_id, edu_level_id, graduation_year, updated_at
    
    has intern_profile.begin_at, :as => :intern_begin_at
    has intern_profile.period_id, :as => :intern_period_id
    has intern_profile.workday_id, :as => :intern_workday_id
    has intern_profile.major_id, :as => :intern_major_id
    has intern_profile.salary, :as => :intern_salary
    
    has intern_industry_wishes.industry_category_id, :as => :intern_wish_industry_category_id
    has intern_industry_wishes.industry_id, :as => :intern_wish_industry_id
    has(
      "GROUP_CONCAT(DISTINCT IF(intern_industry_blacklists.industry_id, '', intern_industry_blacklists.industry_category_id) SEPARATOR ',')",
      :as => :intern_blacklist_industry_category_id,
      :type => :multi
    )
    has intern_industry_blacklists.industry_id, :as => :intern_blacklist_industry_id
    
    has intern_job_category_wishes.job_category_class_id, :as => :intern_wish_job_category_class_id
    has intern_job_category_wishes.job_category_id, :as => :intern_wish_job_category_id
    has(
      "GROUP_CONCAT(DISTINCT IF(intern_job_category_blacklists.job_category_id, '', intern_job_category_blacklists.job_category_class_id) SEPARATOR ',')",
      :as => :intern_blacklist_job_category_class_id,
      :type => :multi
    )
    has intern_job_category_blacklists.job_category_id, :as => :intern_blacklist_job_category_id
    
    has intern_corp_nature_wishes.nature_id, :as => :intern_wish_nature_id
    has intern_corp_nature_blacklists.nature_id, :as => :intern_blacklist_nature_id
    
    has intern_job_district_wishes.job_district_id, :as => :intern_wish_job_district_id
    has intern_job_district_blacklists.job_district_id, :as => :intern_blacklist_job_district_id
    
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
  
  
  def get_name
    self.name
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
  
  
  def self.job_search(school_id, job, corporation_profile, page = 1, options = {})
    filters = {:school_id => school_id}
    filters[:intern_begin_at] = Time.parse("2010-10-01") .. job.begin_at unless job.begin_at.blank?
    filters[:intern_period_id] = job.period_id .. JobPeriod.data.last[:id] unless job.period_id.blank?
    filters[:intern_workday_id] = job.workday_id .. JobWorkday.data.last[:id] unless job.workday_id.blank?
    filters[:edu_level_id] = EduLevel.data.first[:id] .. job.edu_level_id unless job.edu_level_id.blank?
    filters[:graduation_year] = JobGraduation.get_graduation_year_range(job.graduation_id) unless job.graduation_id.blank?
    filters[:intern_major_id] = job.major_id unless job.major_id.blank?
    
    blacklists = {}
    blacklists[:intern_blacklist_industry_category_id] = corporation_profile.industry_category_id unless corporation_profile.industry_category_id.blank?
    blacklists[:intern_blacklist_industry_id] = corporation_profile.industry_id unless corporation_profile.industry_id.blank?
    blacklists[:intern_blacklist_nature_id] = corporation_profile.nature_id unless corporation_profile.nature_id.blank?
    blacklists[:intern_blacklist_job_category_class_id] = job.category_class_id unless job.category_class_id.blank?
    blacklists[:intern_blacklist_job_category_id] = job.category_id unless job.category_id.blank?
    blacklists[:intern_blacklist_job_district_id] = job.district_id unless job.district_id.blank?
    blacklists[:intern_salary] = (job.salary.to_i + 1) .. 1010 unless job.salary.to_i > 1000
    
    self.search(
      :page => page, :per_page => 10,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, updated_at DESC",
      :field_weights => {},
      :with => filters,
      :without => blacklists,
      :include => options[:include] || []
    )
  end
  
end
