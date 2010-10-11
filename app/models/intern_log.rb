class InternLog < ActiveRecord::Base
  
  include Utils::ActiveRecordHelpers
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes corporation.name
    
    has student_id, teacher_id, corporation_id, event_id, result_id, occur_at
    
    has student.school_id, :as => :school_id
    has student.university_id, :as => :university_id
    has student.college_id, :as => :college_id
    has student.major_id, :as => :major_id
    has student.edu_level_id, :as => :edu_level_id
    has student.graduation_year, :as => :graduation_year
    
    
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
  
  validates_presence_of :corporation_id, :message => "请输入 企业"
  validates_presence_of :event_id, :message => "请输入 记录事件"
  validates_presence_of :result_id, :message => "请输入 事件结果"
  validates_presence_of :occur_at, :message => "请输入 发生时间"
  
  
  
  def self.latest_by_students(students, options)
    Hash[
      self.find(
        :all,
        {
          :joins => "LEFT JOIN intern_logs logs ON intern_logs.student_id = logs.student_id AND intern_logs.occur_at < logs.occur_at",
          :conditions => ["logs.occur_at IS NULL and intern_logs.student_id in (?)", students]
        }.merge(options)
      ).group_by { |log| log.student_id }.map { |student_id, logs|
        [student_id, logs.max { |x, y| x.updated_at <=> y.updated_at } ]
      }
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
  
end
