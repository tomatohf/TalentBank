class StudentExp < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_many :resume_student_exps, :class_name => "ResumeStudentExp", :foreign_key => "exp_id", :dependent => :destroy
  
  
  validates_presence_of :student_id
  
  validates_presence_of :period, :message => "请输入 时间段"
  validates_length_of :period, :maximum => 25, :message => "时间段 超过长度限制", :allow_nil => false
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_length_of :title, :maximum => 25, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_length_of :sub_title, :maximum => 15, :message => "子标题 超过长度限制", :allow_nil => true
  
  validates_presence_of :content, :message => "请输入 内容"
  validates_length_of :content, :maximum => 500, :message => "内容 超过长度限制", :allow_nil => false
  
  
  after_save { |student_exp|
    student_exp.renew_resume_updated_at(student_exp.updated_at)
  }
  
  after_destroy { |student_exp|
    student_exp.renew_resume_updated_at(Time.now)
  }
  
  
  def resumes
    Resume.find(
      :all,
      :conditions => ["student_exps.id = ?", self.id],
      :readonly => false,
      :joins => "INNER JOIN resume_exp_sections ON resume_exp_sections.resume_id = resumes.id " +
                "INNER JOIN resume_student_exps ON resume_student_exps.section_id = resume_exp_sections.id " +
                "INNER JOIN student_exps ON student_exps.id = resume_student_exps.exp_id"
    )
  end
  
  
  def renew_resume_updated_at(time)
    self.resumes.each do |resume|
      resume.renew_updated_at(time)
    end
  end
  
end
