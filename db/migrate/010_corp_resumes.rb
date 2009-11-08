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

  end

  def self.down
    
    drop_table :corp_viewed_resumes
    
  end
end
