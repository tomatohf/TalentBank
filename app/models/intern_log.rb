class InternLog < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"
  
  belongs_to :job, :class_name => "Job", :foreign_key => "job_id"
  
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes job.name
    
    has student_id, teacher_id, job_id, event_id, result_id, occur_at, updated_at, created_at
    
    has student.school_id, :as => :school_id
    has student.university_id, :as => :university_id
    has student.college_id, :as => :college_id
    has student.major_id, :as => :major_id
    has student.edu_level_id, :as => :edu_level_id
    has student.graduation_year, :as => :graduation_year
    
    has job.corporation_id, :as => :corporation_id
    has job.category_class_id, :as => :job_category_class_id
    has job.category_id, :as => :job_category_id
    has job.district_id, :as => :job_district_id
    has job.salary, :as => :job_salary
    has job.number, :as => :job_number
    has job.interview_number, :as => :job_interview_number
    
    has job.corporation.profile.industry_category_id, :as => :corporation_industry_category_id
    has job.corporation.profile.industry_id, :as => :corporation_industry_id
    has job.corporation.profile.nature_id, :as => :corporation_nature_id
    
    
    set_property(
      :delta => DailyDelta,
      :column => :updated_at,
      # :rate => 70.minutes,
      :hour => Overall_Index_Hour,
      :minute => Overall_Index_Minute,
      :batch => 100
    )
    
  end
  
  
  
  validates_presence_of :student_id, :teacher_id
  
  validates_presence_of :job_id, :message => "请输入 岗位编号"
  validates_presence_of :event_id, :message => "请输入 记录事件"
  validates_presence_of :result_id, :message => "请输入 事件结果"
  validates_presence_of :occur_at, :message => "请输入 发生时间"
  
  
  
  def self.intern_begin_at
    "2008-10-01"
  end
  
  
  def self.latest_by_students(students, options)
    Hash[
      *
      self.find(
        :all,
        {
          :joins => "LEFT JOIN intern_logs logs ON intern_logs.student_id = logs.student_id AND intern_logs.occur_at < logs.occur_at",
          :conditions => ["logs.occur_at IS NULL and intern_logs.student_id in (?)", students]
        }.merge(options)
      ).group_by { |log| log.student_id }.map { |student_id, logs|
        [student_id, logs.max { |x, y| x.updated_at <=> y.updated_at } ]
      }.flatten
    ]
  end
  
  
  Status = {
    :unemployed => "待业",
    :interview => "面试",
    :intern => "实习",
    :employed => "留用"
  }
  def determine_status
    self.class.determine_status(self.event_id, self.result_id)
  end
  def self.determine_status(event_id, result_id)
    status_key = InternLogEventResult.determine_intern_status(event_id, result_id)
    status_key && Status[status_key]
  end
  
  
  def self.student_count(school_id, to)
    to_time = Time.local(to.year, to.month, to.mday, 23, 59, 59)
    self.search_count(
      :with_attributes => false,
      
      :group_by => "student_id",
      :group_function => :attr,
      :with => {
        :school_id => school_id,
        :updated_at => Time.parse(self.intern_begin_at)..to_time
      }
    ) || 0
  end
  
end
