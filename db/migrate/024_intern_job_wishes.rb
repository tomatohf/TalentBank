class InternJobWishes < ActiveRecord::Migration
  def self.up
    
    create_table :intern_job_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_wishes, [:student_id, :job_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_wishes WHERE id = 10000")
    
    create_table :intern_job_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_blacklists, [:student_id, :job_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_blacklists WHERE id = 10000")
    
    
    create_table :intern_corporation_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :corporation_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :intern_corporation_wishes, [:student_id, :corporation_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_corporation_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_corporation_wishes WHERE id = 10000")
    
    create_table :intern_corporation_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :corporation_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :intern_corporation_blacklists, [:student_id, :corporation_id],
              :unique => true,
              :name => :index_intern_corporation_blacklists_on_student_and_corporation
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_corporation_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_corporation_blacklists WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :intern_corporation_blacklists
    drop_table :intern_corporation_wishes
    
    drop_table :intern_job_blacklists
    drop_table :intern_job_wishes
    
  end
end
