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
  		["edit_job_exps", "相关经历"],
  		["edit_abilities", "相关能力"],
  		["edit_hobbies", "特长和爱好"],
  		["edit_awards", "荣誉和奖励"],
  		["edit_lists", "附加信息"]
    ]
  end
  
end
