class Resume < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  has_many :simple_contents, :class_name => "ResumeSimpleContent", :foreign_key => "resume_id", :dependent => :destroy
  has_many :exp_sections, :class_name => "ResumeExpSection", :foreign_key => "resume_id", :dependent => :destroy
  has_many :list_sections, :class_name => "ResumeListSection", :foreign_key => "resume_id", :dependent => :destroy
  
  
  validates_presence_of :student_id, :domain_id
  
  
  named_scope :published, :conditions => { :published => true }
  
end
