class CorpViewedResume < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes resume.student.name, :as => :student_name
    
    has updated_at, corporation_id, resume_id
    
    has resume.domain_id, :as => :domain_id
    
    has resume.student.school_id, :as => :school_id
    has resume.student.college_id, :as => :college_id
    has resume.student.major_id, :as => :major_id
    has resume.student.edu_level_id, :as => :edu_level_id
    has resume.student.graduation_year, :as => :graduation_year
    
    set_property(
      :delta => DailyDelta,
      :column => :updated_at,
      # :rate => 70.minutes,
      :hour => Overall_Index_Hour,
      :minute => Overall_Index_Minute,
      :batch => 100
    )
    
  end
  
  
  validates_presence_of :corporation_id, :resume_id
  
  
  def self.record(corp_id, resume_id)
    self.new(
      :corporation_id => corp_id,
      :resume_id => resume_id
    ).save
  end
  
  
  def self.period_counts(group_function, from, to)
    from_time = Time.local(from.year, from.month, from.mday, 0, 0, 0)
    to_time = Time.local(to.year, to.month, to.mday, 23, 59, 59)
    
    filters = {
      :updated_at => from_time..to_time
    }
    
    self.search(
      :group_by => "updated_at",
      :group_function => group_function,
      :group_clause => "@group ASC",
      # :match_mode => Search_Match_Mode,
      # :order => "updated_at ASC",
      :with => filters
    )
  end
  
end
