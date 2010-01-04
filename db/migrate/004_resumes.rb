class Resumes < ActiveRecord::Migration
  def self.up
    
    create_table :job_photos, :force => true do |t|
      t.column :student_id, :integer
      
      # for paperclip ...
      t.column :image_file_name, :string # Original filename
      t.column :image_content_type, :string # Mime type
      t.column :image_file_size, :integer # File size in bytes
      t.column :image_updated_at, :datetime
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :job_photos, :student_id, :unique => true
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_photos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_photos WHERE id = 1000")
    
    
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
    
    
    create_table :student_exps, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :period, :string, :limit => 25
      
      t.column :title, :string, :limit => 25
      t.column :sub_title, :string, :limit => 15
      
      t.column :content, :string, :limit => 500
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :student_exps, :student_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_exps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_exps WHERE id = 10000")
    
    
    create_table :resumes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :domain_id, :integer, :limit => 2
      
      t.column :online, :boolean, :default => false
      
      t.column :hidden, :boolean, :default => false
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resumes, [:student_id, :domain_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resumes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resumes WHERE id = 10000")
    
    
    create_table :resume_job_intentions, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :content, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_job_intentions, :resume_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_job_intentions (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_job_intentions WHERE id = 10000")
    
    
    create_table :resume_hobbies, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :content, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_hobbies, :resume_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_hobbies (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_hobbies WHERE id = 10000")
    
    
    create_table :resume_awards, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :content, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_awards, :resume_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_awards (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_awards WHERE id = 10000")
    
    
    create_table :resume_exp_sections, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :title, :string, :limit => 25
      
      t.column :exp_order, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_exp_sections, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_exp_sections (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_exp_sections WHERE id = 10000")
    
    create_table :resume_student_exps, :force => true do |t|
      t.column :section_id, :integer
      t.column :exp_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :resume_student_exps, [:section_id, :exp_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_student_exps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_student_exps WHERE id = 10000")
    
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
    
    create_table :resume_exp_taggers, :force => true do |t|
      t.column :resume_id, :integer
      t.column :tag_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :resume_exp_taggers, [:resume_id, :tag_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_exp_taggers (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_exp_taggers WHERE id = 10000")
    
    
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
    
    
    create_table :student_skills, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :skill_id, :integer
      
      t.column :value, :integer, :limit => 2
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :student_skills, [:student_id, :skill_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_skills (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_skills WHERE id = 10000")
    
    create_table :resume_skills, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :student_skill_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :resume_skills, [:resume_id, :student_skill_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_skills (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_skills WHERE id = 10000")
    
    create_table :resume_list_skills, :force => true do |t|
      t.column :resume_id, :integer
      
      t.column :name, :string, :limit => 50
      t.column :level, :string, :limit => 15
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :resume_list_skills, :resume_id
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO resume_list_skills (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM resume_list_skills WHERE id = 10000")

  end

  def self.down
    
    drop_table :resume_list_skills
    drop_table :resume_skills
    drop_table :student_skills
    
    drop_table :resume_list_sections
    
    drop_table :resume_exp_taggers
    drop_table :resume_exps
    drop_table :resume_student_exps
    drop_table :resume_exp_sections
    
    drop_table :resume_awards
    drop_table :resume_hobbies
    drop_table :resume_job_intentions
    
    drop_table :resumes
    
    drop_table :student_exps
    drop_table :edu_exps
    drop_table :student_profiles
    drop_table :job_photos
    
  end
end
