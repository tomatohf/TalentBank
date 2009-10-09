class Resumes < ActiveRecord::Migration
  def self.up
    
    create_table :student_profiles, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :phone, :string, :limit => 25
      t.column :email, :string
      
      t.column :address, :string
      t.column :zip, :string, :limit => 10
      
      t.column :gender, :boolean
      t.column :political_status_id, :integer, :limit => 2
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :student_profiles, :student_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_profiles (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_profiles WHERE id = 10000")
    
    
    create_table :edu_exps, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :period, :string, :limit => 25
      
      t.column :university, :string, :limit => 25
      t.column :college, :string, :limit => 25
      t.column :major, :string, :limit => 25
      
      t.column :edu_type, :string, :limit => 25
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :edu_exps, :student_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO edu_exps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM edu_exps WHERE id = 10000")
    
    
    create_table :resumes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :domain_id, :integer, :limit => 2
      
      t.column :online, :boolean, :default => false
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resumes, [:student_id, :domain_id]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resumes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resumes WHERE id = 10000")
    
    
    create_table :resume_job_intentions, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :job_intention, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_job_intentions, :resume_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_job_intentions (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_job_intentions WHERE id = 10000")
    
    
    create_table :resume_list_contents, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :hobbies, :string
      
      t.column :awards, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_list_contents, :resume_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_list_contents (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_list_contents WHERE id = 10000")
    
    
    create_table :resume_exp_sections, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :title, :string, :limit => 25
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_exp_sections, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_exp_sections (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_exp_sections WHERE id = 10000")
    
    create_table :resume_exps, :force => true do |t|
      t.column :section_id, :integer
      
      t.column :period, :string, :limit => 25
      
      t.column :title, :string, :limit => 25
      t.column :sub_title, :string, :limit => 15
      
      t.column :content, :string, :limit => 500
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_exps, :section_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_exps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_exps WHERE id = 10000")
    
    
    create_table :resume_list_sections, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :title, :string, :limit => 25
      
      t.column :content, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_list_sections, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_list_sections (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_list_sections WHERE id = 10000")

  end

  def self.down
    
    drop_table :resume_list_sections
    
    drop_table :resume_exps
    drop_table :resume_exp_sections
    
    drop_table :resume_list_contents
    drop_table :resume_job_intentions
    
    drop_table :resumes
    
    drop_table :edu_exps
    drop_table :student_profiles
    
  end
end
