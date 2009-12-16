class Revisions < ActiveRecord::Migration
  def self.up
    
    add_column :teachers, :resume, :boolean, :default => true
    add_column :teachers, :revision, :boolean, :default => false
    
    add_index :teachers, [:school_id, :revision]
    
    
    
    create_table :resume_revisions, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :teacher_id, :integer
      
      t.column :part_type_id, :integer, :limit => 2
      t.column :part_id, :integer
      
      t.column :action, :integer, :limit => 1
      
      t.column :data, :string, :limit => 1000
      
      t.column :applied, :boolean, :default => false
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_revisions, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_revisions (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_revisions WHERE id = 10000")
    
    
    create_table :resume_comments, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :part_type_id, :integer, :limit => 2
      t.column :part_id, :integer
      
      t.column :account_type, :integer, :limit => 1
      t.column :account_id, :integer
      
      t.column :content, :string, :limit => 1000
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_comments, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_comments (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_comments WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :resume_comments
    
    drop_table :resume_revisions
    
    
    
    remove_index :teachers, [:school_id, :revision]
    
    remove_column :teachers, :revision
    remove_column :teachers, :resume
    
  end
end
