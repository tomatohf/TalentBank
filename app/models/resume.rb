class Resume < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_one :job_intention, :class_name => "ResumeJobIntention", :foreign_key => "resume_id", :dependent => :destroy
  has_one :hobby, :class_name => "ResumeHobby", :foreign_key => "resume_id", :dependent => :destroy
  has_one :award, :class_name => "ResumeAward", :foreign_key => "resume_id", :dependent => :destroy
  
  has_many :exp_sections, :class_name => "ResumeExpSection", :foreign_key => "resume_id", :dependent => :destroy
  has_many :list_sections, :class_name => "ResumeListSection", :foreign_key => "resume_id", :dependent => :destroy
  
  
  validates_presence_of :student_id, :domain_id
  
  
  named_scope :online, :conditions => { :online => true }
  
  
  
  def self.edit_parts
    [
      ["edit_job_intention", "求职意向"],
  		["resume_exp_sections", "相关经历"],
  		["edit_skills", "技能和证书"],
  		["edit_awards", "荣誉和奖励"],
  		["edit_hobbies", "特长和爱好"],
  		["resume_list_sections", "附加信息"]
    ]
  end
  
  
  def self.load_contents(resumes, includes)
    self.preload_associations(resumes, includes)
  end
  
end
