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
  
  
  include Utils::Searchable
  
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
    
    has student.blocked_corps.corporation_id, :as => :blocked_corp_id
    
    has domain_id, online, hidden, updated_at
    
    has exp_taggers.tag_id, :as => :exp_tag_id
    
    has skills.student_skill.skill_id, :as => :skill_id # just used to include SQL fragment: join student_skills
    has(
      "GROUP_CONCAT(DISTINCT CONCAT(student_skills.skill_id, student_skills.value) SEPARATOR ',')",
      :as => :skill_values,
      :type => :multi
    )
    
    
    # the :hour and :minute used here must be consistent with the values in crontab
    # while the :hour and :minute should be a little early than 
    # the overall index time in crontab
    # to ensure that the correct date is generated in sphinx conf file
    # 
    # the :rate should be a little larger than the crontab rate,
    # for the delta index itself would take some time
    set_property(
      :delta => DailyDelta,
      :column => :updated_at,
      # :rate => 70.minutes,
      :hour => Overall_Index_Hour,
      :minute => Overall_Index_Minute,
      :batch => 100
    )
    
  end
  
  
  validates_presence_of :student_id, :domain_id
  
  
  include Utils::NotDeletable
  
  
  
  def self.edit_parts
    [
      ["edit_job_intention", "求职意向"],
  		["exp_sections", "相关经历"],
  		["resume_skills", "技能和证书"],
  		["edit_awards", "荣誉和奖励"],
  		["edit_hobbies", "特长和爱好"],
  		["list_sections", "附加信息"]
    ]
  end
  
  
  def self.load_contents(resumes, includes)
    self.preload_associations(resumes, includes)
  end
  
  def load_contents(includes)
    self.class.load_contents(self, includes)
  end
  
  
  Resume_Page_Size = 20
  
  def self.corp_search(query, corporation, page = 1, query_tags = nil, query_skills = nil)
    query_tags, query_skills = query.tags_and_skills unless query_tags && query_skills
    valid_skill_values = query_skills.collect do |skill_id, skill_value|
      Skill.find(skill_id)[:data].collect {|d| d[:value] }.select {|v| v >= skill_value }.collect do |v|
        "#{skill_id}#{v}".to_i
      end
    end
    
    filters = {
      :online => true,
      :hidden => false
    }
    filters.merge!(:school_id => corporation.school_id)
    [:college_id, :major_id, :edu_level_id, :graduation_year, :domain_id].each do |filter_key|
      filter_value = query.send(filter_key)
      filters.merge!(filter_key => filter_value) unless filter_value.nil?
    end
    
    self.search(
      query.keyword,
      :page => page,
      :per_page => Resume_Page_Size,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, updated_at DESC",
      :field_weights => self.weights,
      :with => filters,
      :with_all => {
        :exp_tag_id => query_tags,
        :skill_values => valid_skill_values
      },
      :without => {
        :blocked_corp_id => corporation.id
      },
      :include => [
        {:student => :job_photo}
      ]
    )
  end
  
  def self.weights
    {
      # default weight is 1
      :student_name => 2,

      # :edu_exp_period => 1,
      :edu_exp_university => 4,
      :edu_exp_college => 4,
      :edu_exp_major => 4,
      :edu_exp_edu_type => 2,

      :job_intention => 8,
      :award => 6,
      :hobby => 5,

      :list_section_title => 4,
      :list_section_content => 5,

      :list_skill_name => 8,
      :list_skill_level => 2,

      :exp_section_title => 5,

      # :student_exp_period => 1,
      :student_exp_title => 10,
      :student_exp_sub_title => 10,
      :student_exp_content => 10,

      # :resume_exp_period => 1,
      :resume_exp_title => 10,
      :resume_exp_sub_title => 10,
      :resume_exp_content => 10
    }
  end
  
  
  def available?(corp_id)
    # the resume is (not hidden) and online and the corporation is NOT in the blacklist
    (!self.hidden) && self.online && BlockedCorp.get_record(self.student_id, corp_id).new_record?
  end
  
  
  def empty!
    self.job_intention && self.job_intention.destroy
    self.hobby && self.hobby.destroy
    self.award && self.award.destroy
    
    self.exp_sections.each { |exp_section| exp_section.destroy }
    
    self.skills.each { |skill| skill.destroy }
    self.list_skills.each { |list_skill| list_skill.destroy }
    
    self.list_sections.each { |list_section| list_section.destroy }
  end
  
  
  def copy_to(to_resume)
    begin
      ActiveRecord::Base.transaction do
        # clear contents of to_resume
        to_resume.empty!

        # copy resume contents
        
        # copy job_intention
        ResumeJobIntention.new(
          :resume_id => to_resume.id,
          :content => self.job_intention.content
        ).save! if self.job_intention
        
        # copy hobby
        ResumeHobby.new(
          :resume_id => to_resume.id,
          :content => self.hobby.content
        ).save! if self.hobby
        
        # copy award
        ResumeAward.new(
          :resume_id => to_resume.id,
          :content => self.award.content
        ).save! if self.award
        
        # copy exps
        self.load_contents(:exp_sections => [:resume_student_exps, :exps])
        self.exp_sections.each do |exp_section|
          new_section = ResumeExpSection.new(
            :resume_id => to_resume.id,
            :title => exp_section.title
          )
          new_section.save!
          
          order = exp_section.get_exp_order

					exps = exp_section.exps.inject({}) do |hash, exp|
						hash[exp.id] = exp
						hash
					end

					resume_student_exps = exp_section.resume_student_exps.inject({}) do |hash, exp|
						hash[exp.id] = exp
						hash
					end
					
          order.each do |o|
						exp_id = o[1].to_i
						exp_type = o[0].to_i
            exp = case exp_type
							when ResumeExpSection::Student_Exp
								resume_student_exp = resume_student_exps[exp_id]
								ResumeStudentExp.new(
								  :section_id => new_section.id,
								  :exp_id => resume_student_exp.exp_id
								) if resume_student_exp
							when ResumeExpSection::Resume_Exp
								resume_exp = exps[exp_id]
								ResumeExp.new(
								  :section_id => new_section.id,
								  :period => resume_exp.period,
								  :title => resume_exp.title,
								  :sub_title => resume_exp.sub_title,
								  :content => resume_exp.content
								) if resume_exp
							else
								nil
						end
						
						if exp
  						exp.save!
  						new_section.add_exp_order(exp_type, exp.id)
						end
					end
					
					new_section.save!
        end
        
        # copy resume skills
        self.skills.each do |skill|
				  ResumeSkill.new(
				    :resume_id => to_resume.id,
				    :student_skill_id => skill.student_skill_id
				  ).save!
			  end
			  
			  # copy resume list skills
        self.list_skills.each do |list_skill|
				  ResumeListSkill.new(
				    :resume_id => to_resume.id,
				    :name => list_skill.name,
				    :level => list_skill.level
				  ).save!
			  end
			  
			  # copy list sections
			  self.list_sections.each do |list_section|
			    ResumeListSection.new(
				    :resume_id => to_resume.id,
				    :title => list_section.title,
				    :content => list_section.content
				  ).save!
		    end
      end

      true
    rescue
      false
    end
  end
  
end
