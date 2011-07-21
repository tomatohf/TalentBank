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
  
  has_many :intern_corporation_wishes, :class_name => "InternCorporationWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_corporation_blacklists, :class_name => "InternCorporationBlacklist", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_wishes, :class_name => "InternJobWish", :foreign_key => "student_id", :dependent => :destroy
  has_many :intern_job_blacklists, :class_name => "InternJobBlacklist", :foreign_key => "student_id", :dependent => :destroy
  
  has_many :intern_logs, :class_name => "InternLog", :foreign_key => "student_id", :dependent => :destroy
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes number, name
    
    has school_id, university_id, college_id, major_id, edu_level_id, graduation_year, updated_at, created_at
    has complete
    
    indexes profile.phone, :as => :phone
    indexes profile.email, :as => :email
    indexes profile.address, :as => :address
    indexes profile.zip, :as => :zip
    
    indexes intern_profile.birthplace, :as => :intern_birthplace
    indexes intern_profile.birthmonth, :as => :intern_birthmonth
    indexes intern_profile.intention, :as => :intern_intention
    indexes intern_profile.skill, :as => :intern_skill
    indexes intern_profile.experience, :as => :intern_experience
    indexes intern_profile.desc, :as => :intern_desc
    
    has "IFNULL(student_profiles.gender, 2)", :type => :integer, :as => :gender
    has profile.political_status_id, :as => :political_status_id
    
    has intern_profile.begin_at, :as => :intern_begin_at
    has intern_profile.period_id, :as => :intern_period_id
    has intern_profile.workday_id, :as => :intern_workday_id
    has intern_profile.major_id, :as => :intern_major_id
    has intern_profile.salary, :as => :intern_salary
    has intern_profile.created_at, :as => :intern_created_at
    
    has intern_industry_wishes.industry_category_id, :as => :intern_wish_industry_category_id
    has intern_industry_wishes.industry_id, :as => :intern_wish_industry_id
    has intern_job_category_wishes.job_category_class_id, :as => :intern_wish_job_category_class_id
    has intern_job_category_wishes.job_category_id, :as => :intern_wish_job_category_id
    has intern_corp_nature_wishes.nature_id, :as => :intern_wish_nature_id
    has intern_job_district_wishes.job_district_id, :as => :intern_wish_job_district_id
    has intern_corporation_wishes.corporation_id, :as => :intern_wish_corporation_id
    has intern_job_wishes.job_id, :as => :intern_wish_job_id
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_industry_wishes.industry_category_id, 'y') SEPARATOR ',')",
      :as => :intern_wish_industry_category_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_industry_wishes.industry_id, 'i') SEPARATOR ',')",
      :as => :intern_wish_industry_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_job_category_wishes.job_category_class_id, 's') SEPARATOR ',')",
      :as => :intern_wish_job_category_class_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_job_category_wishes.job_category_id, 'c') SEPARATOR ',')",
      :as => :intern_wish_job_category_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_corp_nature_wishes.nature_id, 'n') SEPARATOR ',')",
      :as => :intern_wish_nature_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_job_district_wishes.job_district_id, 'd') SEPARATOR ',')",
      :as => :intern_wish_job_district_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_corporation_wishes.corporation_id, 'o') SEPARATOR ',')",
      :as => :intern_wish_corporation_ids
    )
    indexes(
      "GROUP_CONCAT(DISTINCT CONCAT('j', intern_job_wishes.job_id, 'b') SEPARATOR ',')",
      :as => :intern_wish_job_ids
    )
    indexes("'j0j'", :as => :match_all)
    
    has(
      "GROUP_CONCAT(DISTINCT IF(intern_industry_blacklists.industry_id, '', intern_industry_blacklists.industry_category_id) SEPARATOR ',')",
      :as => :intern_blacklist_industry_category_id,
      :type => :multi
    )
    has intern_industry_blacklists.industry_id, :as => :intern_blacklist_industry_id
    has(
      "GROUP_CONCAT(DISTINCT IF(intern_job_category_blacklists.job_category_id, '', intern_job_category_blacklists.job_category_class_id) SEPARATOR ',')",
      :as => :intern_blacklist_job_category_class_id,
      :type => :multi
    )
    has intern_job_category_blacklists.job_category_id, :as => :intern_blacklist_job_category_id
    has intern_corp_nature_blacklists.nature_id, :as => :intern_blacklist_nature_id
    has intern_job_district_blacklists.job_district_id, :as => :intern_blacklist_job_district_id
    has intern_corporation_blacklists.corporation_id, :as => :intern_blacklist_corporation_id
    has intern_job_blacklists.job_id, :as => :intern_blacklist_job_id
    
    has intern_logs.created_at, :as => :intern_logs_created_at
    has intern_logs.job_id, :as => :intern_logs_job_id
    has(
      "GROUP_CONCAT(IFNULL(intern_logs.result_id, 0) ORDER BY intern_logs.occur_at DESC SEPARATOR ',')",
      :as => :intern_log_latest_result_id,
      :type => :integer
    )
    
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
    
    filters.merge!(:complete => options[:complete]) unless options[:complete].nil?
    filters.merge!(:gender => options[:gender] ? 1 : 0) unless options[:gender].nil?
    
    [:university_id, :college_id, :major_id, :edu_level_id, :graduation_year].each do |filter_key|
      filter_value = options[filter_key]
      filters.merge!(filter_key => filter_value) unless filter_value.blank?
    end
    
    created_at_range = options[:created_at] || []
    created_at_from = created_at_range[0] || Time.parse(InternLog.intern_begin_at)
    created_at_to = created_at_range[1] || Time.now
    filters.merge!(:created_at => created_at_from .. created_at_to)
    
    filters.merge!(:intern_begin_at => options[:begin_at_range]) unless options[:begin_at_range].blank?
    
    filters.merge!(:intern_major_id => options[:job_major_id]) unless options[:job_major_id].blank?
    
    self.search(
      name,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@weight DESC, updated_at DESC",
      :field_weights => {},
      :with => filters,
      :include => includes
    )
  end
  
  
  def self.job_search(school_id, job, corporation_profile, page = 1, options = {})
    filters = {:school_id => school_id}
    filters[:intern_begin_at] = Time.parse(InternLog.intern_begin_at) .. job.begin_at unless job.begin_at.blank?
    filters[:intern_period_id] = job.period_id .. JobPeriod.data.last[:id] unless job.period_id.blank?
    filters[:intern_workday_id] = job.workday_id .. JobWorkday.data.last[:id] unless job.workday_id.blank?
    filters[:edu_level_id] = EduLevel.data.first[:id] .. job.edu_level_id unless job.edu_level_id.blank?
    filters[:graduation_year] = JobGraduation.get_graduation_year_range(job.graduation_id) unless job.graduation_id.blank?
    filters[:gender] = job.gender ? 1 : 0 unless job.gender.nil?
    filters[:political_status_id] = job.political_status_id unless job.political_status_id.blank?
    filters[:intern_major_id] = job.major_id unless job.major_id.blank?
    filters[:intern_log_latest_result_id] = InternLogEventResult.find_by_intern_status(:unemployed).map { |result|
      result[:id]
    } << 0 if options[:only_unemployed]
    filters[:intern_log_latest_result_id] = 0 if options[:only_no_intern_log]
    # :only_no_intern_log has higher priority than :only_unemployed
    filters[:university_id] = options[:university_id] unless options[:university_id].blank?
    filters[:created_at] = options[:created_at] .. Time.now if options[:created_at]
    
    blacklists = {}
    blacklists[:intern_blacklist_industry_category_id] = corporation_profile.industry_category_id unless corporation_profile.industry_category_id.blank?
    blacklists[:intern_blacklist_industry_id] = corporation_profile.industry_id unless corporation_profile.industry_id.blank?
    blacklists[:intern_blacklist_nature_id] = corporation_profile.nature_id unless corporation_profile.nature_id.blank?
    blacklists[:intern_blacklist_job_category_class_id] = job.category_class_id unless job.category_class_id.blank?
    blacklists[:intern_blacklist_job_category_id] = job.category_id unless job.category_id.blank?
    blacklists[:intern_blacklist_job_district_id] = job.district_id unless job.district_id.blank?
    blacklists[:intern_blacklist_corporation_id] = job.corporation_id
    blacklists[:intern_blacklist_job_id] = job.id
    blacklists[:intern_salary] = (job.salary.to_i + 1) .. 1010 unless job.salary.to_i > 1000
    blacklists[:intern_logs_job_id] = job.id if options[:only_no_related_intern_log]
    
    wishes = [%Q!"j0j"!]
    wishes << %Q!"j#{corporation_profile.industry_category_id}y"! unless corporation_profile.industry_category_id.blank?
    wishes << %Q!"j#{corporation_profile.industry_id}i"! unless corporation_profile.industry_id.blank?
    wishes << %Q!"j#{corporation_profile.nature_id}n"! unless corporation_profile.nature_id.blank?
    wishes << %Q!"j#{job.category_class_id}s"! unless job.category_class_id.blank?
    wishes << %Q!"j#{job.category_id}c"! unless job.category_id.blank?
    wishes << %Q!"j#{job.district_id}d"! unless job.district_id.blank?
    wishes << %Q!"j#{job.corporation_id}o"!
    wishes << %Q!"j#{job.id}b"!
    wishes = wishes.join("|")
    
    keyword = options[:keyword]
    
    self.search(
      keyword.blank? ? wishes : "#{keyword} (#{wishes})",
      :page => page, :per_page => 10,
      :match_mode => :extended2,
      :order => "@weight DESC, created_at DESC",
      :field_weights => {
        :intern_wish_industry_category_ids => 4,
        :intern_wish_industry_ids => 8,
        :intern_wish_nature_ids => 2,
        :intern_wish_job_category_class_ids => 10,
        :intern_wish_job_category_ids => 10,
        :intern_wish_job_district_ids => 6,
        :intern_wish_corporation_ids => 20,
        :intern_wish_job_ids => 30
      },
      :with => filters,
      :without => blacklists,
      :include => options[:include] || []
    )
  end
  
  
  CKP_calling_mark = "calling_mark"
  
  def self.calling_mark_key(student_id)
    "#{CKP_calling_mark}_#{student_id}"
  end
  
  def get_calling_mark
    self.class.get_calling_mark(self.id)
  end
  def self.get_calling_mark(student_id)
    Rails.cache.read(self.calling_mark_key(student_id))
  end
  
  def mark_calling(teacher_id)
    self.class.mark_calling(self.id, teacher_id)
  end
  def self.mark_calling(student_id, teacher_id)
    Rails.cache.write(self.calling_mark_key(student_id), teacher_id, :expires_in => Cache_TTL[:normal])
  end
  
  def clear_calling_mark
    self.class.clear_calling_mark(self.id)
  end
  def self.clear_calling_mark(student_id)
    Rails.cache.delete(self.calling_mark_key(student_id))
  end
  
end
