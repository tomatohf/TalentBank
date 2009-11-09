class CorpResumes < ActiveRecord::Migration
  def self.up
    
    create_table :corp_viewed_resumes, :force => true do |t|
      t.column :corporation_id, :integer
      t.column :resume_id, :integer
      
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_viewed_resumes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_viewed_resumes WHERE id = 10000")
    
    
    create_table :corp_resume_tags, :force => true do |t|
      t.column :name, :string, :limit => 30
      
      t.column :updated_at, :datetime
    end
    add_index :corp_resume_tags, :name, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_resume_tags (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_resume_tags WHERE id = 10000")
    
    create_table :corp_resume_taggers, :force => true do |t|
      t.column :corp_id, :integer
      t.column :resume_id, :integer
      t.column :tag_id, :integer
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :corp_resume_taggers, [:corp_id, :resume_id, :tag_id], :unique => true
    add_index :corp_resume_taggers, [:corp_id, :tag_id, :created_at]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corp_resume_taggers (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corp_resume_taggers WHERE id = 10000")

  end

  def self.down
    
    drop_table :corp_resume_taggers
    drop_table :corp_resume_tags
    
    drop_table :corp_viewed_resumes
    
  end
end
