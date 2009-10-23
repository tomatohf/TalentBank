module CorporationsHelper

  def collect_query_conditions(params, keyword_key)
    college_id = params[:college]
    major_id = params[:major]
    edu_level_id = params[:edu_level]
    graduation_year = params[:graduation_year]

    keyword = params[keyword_key] && params[keyword_key].strip

    domain_id = params[:domain] && params[:domain].to_i

    tags = []
    (ResumeExpTag.data[domain_id] || []).each do |tag|
      tags << tag[:id] if params["tag_#{tag[:id]}".to_sym] == "true"
    end

    skills = []
    Skill.data.each do |skill|
      param = params["skill_input_#{skill[:id]}".to_sym]
      skills << [skill[:id], param.to_i] unless param.blank?
    end
  
    CorpQuery.build_conditions(
      domain_id,
      [college_id, major_id, edu_level_id, graduation_year],
      tags,
      skills,
      keyword
    )
  end
  
end
