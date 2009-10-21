class CorpQuery < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  has_many :tags, :class_name => "CorpQueryExpTag", :foreign_key => "query_id", :dependent => :destroy
  has_many :skills, :class_name => "CorpQuerySkill", :foreign_key => "query_id", :dependent => :destroy
  
  
  
  Sep_Part = "!"
  Sep_Value = "_"
  Sep_pair = "-"
  def self.build_conditions(domain_id, info, tags, skills, keyword)
    [
      domain_id,
      build_conditions_info(info),
      build_conditions_tags(tags),
      build_conditions_skills(skills),
      keyword
    ].join(Sep_Part)
  end
  def self.build_conditions_info(info)
    info.join(Sep_Value)
  end
  def self.build_conditions_tags(tags)
    tags.join(Sep_Value)
  end
  def self.build_conditions_skills(skills)
    skills.collect{|skill| skill.join(Sep_pair) }.join(Sep_Value)
  end
  
  
  def self.parse_from_conditions(conditions = "")
    domain_id, info, tags, skills, keyword = conditions.split(Sep_Part, 5)
    college_id, major_id, edu_level_id, graduation_year = info.split(Sep_Value)
    self.new(
      :college_id => college_id,
      :major_id => major_id,
      :edu_level_id => edu_level_id,
      :graduation_year => graduation_year,
      
      :domain_id => domain_id,
      
      :keyword => keyword,
      
      :other_conditions => [tags, skills].join(Sep_Part)
    )
  end
  
  
  def get_tags(tags_conditions)
    (tags_conditions || (self.other_conditions || "").split(Sep_Part)[0]).split(Sep_Value)
  end
  
  def get_skills(skills_conditions)
    (skills_conditions || (self.other_conditions || "").split(Sep_Part)[1]).split(Sep_Value).collect { |pair| pair.split(Sep_pair) }
  end
  
  def tags_and_skills
    tags, skills = (self.other_conditions || "").split(Sep_Part)
    [
      get_tags(tags),
      get_skills(skills)
    ]
  end
  
end
