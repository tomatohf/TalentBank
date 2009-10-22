namespace :query do
  
  desc "synchronize corp query tags and corp query skills database records with corp queries"
  task :update_corp_query_tags_and_skills => :environment do
    CorpQuery.find(
      :all,
      :conditions => ["id >= ?", CorpQuery.get_synchronized_query_id]
    ).each do |query|
      tags, skills = query.tags_and_skills
      
      tags.each do |tag_id|
        tag = CorpQueryExpTag.get_record(tag_id, query.id)
        tag.save! if tag.new_record?
      end
      
      skills.each do |skill_info|
        skill = CorpQuerySkill.get_record(skill_info[0], query.id)
        skill.value = skill_info[1]
        skill.save! if skill.new_record?
      end
      
      CorpQuery.set_synchronized_query_id_cache(query.id)
    end
  end
  
end
