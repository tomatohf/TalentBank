class StudentSkill < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_many :resume_skills, :class_name => "ResumeSkill", :foreign_key => "student_skill_id", :dependent => :destroy
  
  
  validates_presence_of :student_id, :skill_id, :value
  
  
  Belongs_To_Keys = [:student_id, :skill_id]
  include Utils::UniqueBelongs
  
  
  after_save { |student_skill|
    student_skill.renew_resume_updated_at(student_skill.updated_at)
  }
  
  after_destroy { |student_skill|
    student_skill.renew_resume_updated_at(Time.now)
  }
  
  
  def resumes
    Resume.find(
      :all,
      :conditions => ["student_skills.id = ?", self.id],
      :readonly => false,
      :joins => "INNER JOIN resume_skills ON resume_skills.resume_id = resumes.id " +
                "INNER JOIN student_skills ON student_skills.id = resume_skills.student_skill_id"
    )
  end
  
  
  def renew_resume_updated_at(time)
    self.resumes.each do |resume|
      resume.renew_updated_at(time)
    end
  end
  
end
