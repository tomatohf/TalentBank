class InternProfiles < ActiveRecord::Migration
  def self.up
    
    create_table :intern_profiles, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :begin_at, :datetime
      t.column :period_id, :integer, :limit => 2
      t.column :workday_id, :integer, :limit => 2
      t.column :major_id, :integer, :limit => 2
      
      
      t.column :salary, :decimal
      
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :intern_profiles, :student_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_profiles (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_profiles WHERE id = 10000")
    
    
    create_table :intern_industry_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :industry_category_id, :integer, :limit => 2
      t.column :industry_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_industry_wishes, [:student_id, :industry_category_id, :industry_id],
              :unique => true,
              :name => :index_intern_industry_wishes_on_student_and_industry
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_industry_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_industry_wishes WHERE id = 10000")
    
    create_table :intern_industry_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :industry_category_id, :integer, :limit => 2
      t.column :industry_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_industry_blacklists, [:student_id, :industry_category_id, :industry_id],
              :unique => true,
              :name => :index_intern_industry_blacklists_on_student_and_industry
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_industry_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_industry_blacklists WHERE id = 10000")
    
    
    create_table :intern_job_category_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_category_class_id, :integer, :limit => 2
      t.column :job_category_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_category_wishes, [:student_id, :job_category_class_id, :job_category_id],
              :unique => true,
              :name => :index_intern_job_category_wishes_on_student_and_category
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_category_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_category_wishes WHERE id = 10000")
    
    create_table :intern_job_category_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_category_class_id, :integer, :limit => 2
      t.column :job_category_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_category_blacklists, [:student_id, :job_category_class_id, :job_category_id],
              :unique => true,
              :name => :index_intern_job_category_blacklists_on_student_and_category
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_category_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_category_blacklists WHERE id = 10000")
    
    
    create_table :intern_corp_nature_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :nature_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_corp_nature_wishes, [:student_id, :nature_id],
              :unique => true,
              :name => :index_intern_corp_nature_wishes_on_student_and_nature
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_corp_nature_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_corp_nature_wishes WHERE id = 10000")
    
    create_table :intern_corp_nature_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :nature_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_corp_nature_blacklists, [:student_id, :nature_id],
              :unique => true,
              :name => :index_intern_corp_nature_blacklists_on_student_and_nature
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_corp_nature_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_corp_nature_blacklists WHERE id = 10000")
    
    
    create_table :intern_job_district_wishes, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_district_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_district_wishes, [:student_id, :job_district_id],
              :unique => true,
              :name => :index_intern_job_district_wishes_on_student_and_district
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_district_wishes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_district_wishes WHERE id = 10000")
    
    create_table :intern_job_district_blacklists, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :job_district_id, :integer, :limit => 2
      
      t.column :updated_at, :datetime
    end
    add_index :intern_job_district_blacklists, [:student_id, :job_district_id],
              :unique => true,
              :name => :index_intern_job_district_blacklists_on_student_and_district
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_job_district_blacklists (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_job_district_blacklists WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :intern_job_district_blacklists
    drop_table :intern_job_district_wishes
    
    
    drop_table :intern_corp_nature_blacklists
    drop_table :intern_corp_nature_wishes
    
    
    drop_table :intern_job_category_blacklists
    drop_table :intern_job_category_wishes
    
    
    drop_table :intern_industry_blacklists
    drop_table :intern_industry_wishes
    
    
    drop_table :intern_profiles
    
  end
end
