class CorpQueries < ActiveRecord::Migration
  def self.up
    
    create_table :corp_queries, :force => true do |t|
      t.column :corporation_id, :integer
      
      t.column :college_id, :integer
      t.column :major_id, :integer
      t.column :edu_level_id, :integer, :limit => 2
      t.column :graduation_year, :integer, :limit => 2
      
      t.column :domain_id, :integer, :limit => 2
      
      t.column :keyword, :string
      
      t.column :other_conditions, :string
      
      t.column :created_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_queries (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_queries WHERE id = 10000")
    
    create_table :corp_query_exp_tags, :force => true do |t|
      t.column :query_id, :integer
      t.column :tag_id, :integer
      
      t.column :created_at, :datetime
    end
    add_index :corp_query_exp_tags, [:tag_id, :query_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_query_exp_tags (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_query_exp_tags WHERE id = 10000")
    
    create_table :corp_query_skills, :force => true do |t|
      t.column :query_id, :integer
      
      t.column :skill_id, :integer
      
      t.column :value, :integer, :limit => 2
      
      t.column :created_at, :datetime
    end
    add_index :corp_query_skills, [:skill_id, :query_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_query_skills (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_query_skills WHERE id = 10000")
    
    
    create_table :corp_saved_queries, :force => true do |t|
      t.column :corporation_id, :integer
      
      t.column :conditions, :string
      
      t.column :name, :string, :limit => 50
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :corp_saved_queries, [:corporation_id, :created_at]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_saved_queries (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_saved_queries WHERE id = 10000")

  end

  def self.down
    
    drop_table :corp_saved_queries
    
    drop_table :corp_query_skills
    drop_table :corp_query_exp_tags
    drop_table :corp_queries
    
  end
end
