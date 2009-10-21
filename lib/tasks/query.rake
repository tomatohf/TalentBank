namespace :query do
  
  desc "synchronize corp query tags and corp query skills database records with corp queries"
  task :update_corp_query_tags_and_skills => :environment do
    CorpQuery.find(
      :all,
      :conditions => ["id > ?", CorpQuery.get_synchronized_query_id]
    ).each do |query|
      tags, skills = query.tags_and_skills
      
      tags.each do |tag_id|
        tag = CorpQueryExpTag.new(:query_id => query.id, :tag_id => tag_id)
        
      end
    end
  end
  
end
