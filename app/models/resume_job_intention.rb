class ResumeJobIntention < ActiveRecord::Base
  
  belongs_to :resume, :class_name => "Resume", :foreign_key => "resume_id"
  
  
  validates_presence_of :resume_id
  
  validates_length_of :job_intention, :maximum => 250, :message => "求职意向 超过长度限制", :allow_nil => true
  
  
  
  def self.get_job_intention(resume_id)
    job_intention = self.find(:first, :conditions => ["resume_id = ?", resume_id])
    job_intention || self.new(:resume_id => resume_id)
  end
  
end
