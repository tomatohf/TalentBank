class Resume < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_one :job_intention, :class_name => "ResumeJobIntention", :foreign_key => "resume_id", :dependent => :destroy
  has_one :award, :class_name => "ResumeAward", :foreign_key => "resume_id", :dependent => :destroy
  has_one :hobby, :class_name => "ResumeHobby", :foreign_key => "resume_id", :dependent => :destroy
  
  has_many :exp_sections, :class_name => "ResumeExpSection", :foreign_key => "resume_id", :dependent => :destroy
  has_many :list_sections, :class_name => "ResumeListSection", :foreign_key => "resume_id", :dependent => :destroy
  
  has_many :skills, :class_name => "ResumeSkill", :foreign_key => "resume_id", :dependent => :destroy
  has_many :list_skills, :class_name => "ResumeListSkill", :foreign_key => "resume_id", :dependent => :destroy
  
  has_many :exp_taggers, :class_name => "ResumeExpTagger", :foreign_key => "resume_id", :dependent => :destroy
  
  
  define_index do
    
    indexes student.name, :as => :student_name
    
    # indexes student.edu_exps.period, :as => :edu_exp_period
    indexes student.edu_exps.university, :as => :edu_exp_university
    indexes student.edu_exps.college, :as => :edu_exp_college
    indexes student.edu_exps.major, :as => :edu_exp_major
    indexes student.edu_exps.edu_type, :as => :edu_exp_edu_type
    
    indexes job_intention.content, :as => :job_intention
    indexes award.content, :as => :award
    indexes hobby.content, :as => :hobby
    
    indexes list_sections.title, :as => :list_section_title
    indexes list_sections.content, :as => :list_section_content
    
    indexes list_skills.name, :as => :list_skill_name
    indexes list_skills.level, :as => :list_skill_level
    
    indexes exp_sections.title, :as => :exp_section_title
    
    # indexes exp_sections.resume_student_exps.student_exp.period, :as => :student_exp_period
    indexes exp_sections.resume_student_exps.student_exp.title, :as => :student_exp_title
    indexes exp_sections.resume_student_exps.student_exp.sub_title, :as => :student_exp_sub_title
    indexes exp_sections.resume_student_exps.student_exp.content, :as => :student_exp_content
    
    # indexes exp_sections.exps.period, :as => :resume_exp_period
    indexes exp_sections.exps.title, :as => :resume_exp_title
    indexes exp_sections.exps.sub_title, :as => :resume_exp_sub_title
    indexes exp_sections.exps.content, :as => :resume_exp_content
    
    
    has student.school_id, :as => :school_id
    has student.college_id, :as => :college_id
    has student.major_id, :as => :major_id
    has student.edu_level_id, :as => :edu_level_id
    has student.graduation_year, :as => :graduation_year
    
    has domain_id, online
    
    has exp_taggers.tag_id, :as => :exp_tag_id
    
    # TODO - how to index student skills for searching ...
    # has skills.student_skill.skill_id, :as => :skill_id
    
    
    # the index:delta operation will run every 60 minutes (1 hour),
    # which reserves 15 minutes because the indexing will take some time.
    set_property :delta => :datetime, :delta_column => :updated_at, :threshold => 75.minutes
    
  end
  
  
  validates_presence_of :student_id, :domain_id
  
  
  named_scope :online, :conditions => { :online => true }
  
  
  
  def self.edit_parts
    [
      ["edit_job_intention", "求职意向"],
  		["resume_exp_sections", "相关经历"],
  		["resume_skills", "技能和证书"],
  		["edit_awards", "荣誉和奖励"],
  		["edit_hobbies", "特长和爱好"],
  		["resume_list_sections", "附加信息"]
    ]
  end
  
  
  def self.load_contents(resumes, includes)
    self.preload_associations(resumes, includes)
  end
  
end
