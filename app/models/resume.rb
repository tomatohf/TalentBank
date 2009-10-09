class Resume < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_one :job_intention, :class_name => "ResumeJobIntention", :foreign_key => "resume_id", :dependent => :destroy
  has_one :list_content, :class_name => "ResumeListContent", :foreign_key => "resume_id", :dependent => :destroy
  
  has_many :exp_sections, :class_name => "ResumeExpSection", :foreign_key => "resume_id", :dependent => :destroy
  has_many :list_sections, :class_name => "ResumeListSection", :foreign_key => "resume_id", :dependent => :destroy
  
  
  validates_presence_of :student_id, :domain_id
  
  
  named_scope :online, :conditions => { :online => true }
  
end
