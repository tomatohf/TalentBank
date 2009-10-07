class Resumes < ActiveRecord::Migration
  def self.up
    
    create_table :student_profiles, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :phone, :string, :limit => 25
      t.column :email, :string
      
      t.column :address, :string
      t.column :zip, :string, :limit => 10
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :student_profiles, :student_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_profiles (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_profiles WHERE id = 10000")
    
    
    create_table :edu_exps, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :start_year, :integer, :limit => 2
      t.column :start_month, :integer, :limit => 1
      
      t.column :end_year, :integer, :limit => 2
      t.column :end_month, :integer, :limit => 1
      
      t.column :university, :string, :limit => 25
      t.column :college, :string, :limit => 25
      t.column :major, :string, :limit => 25
      
      t.column :edu_type, :string, :limit => 25
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :edu_exps, :student_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO edu_exps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM edu_exps WHERE id = 10000")

  end

  def self.down
    
    drop_table :edu_exps
    drop_table :student_profiles
    
  end
end
