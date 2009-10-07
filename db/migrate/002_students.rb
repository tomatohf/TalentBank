class Students < ActiveRecord::Migration
  def self.up
    
    create_table :schools, :force => true do |t|
      t.column :abbr, :string, :limit => 15
      t.column :password, :string
      t.column :active, :boolean, :default => true
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO schools (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM schools WHERE id = 10000")
    
    
    create_table :teachers, :force => true do |t|
      t.column :uid, :string, :limit => 25
      t.column :password, :string
      t.column :active, :boolean, :default => true
      
      t.column :name, :string, :limit => 15
      t.column :email, :string
      
      t.column :school_id, :integer
      
      t.column :admin, :boolean, :default => false
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO teachers (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM teachers WHERE id = 10000")
    
    
    create_table :students, :force => true do |t|
      t.column :number, :string, :limit => 25
      t.column :password, :string
      t.column :active, :boolean, :default => true
      
      t.column :school_id, :integer
      
      t.column :name, :string, :limit => 25
      
      t.column :college_id, :integer
      t.column :major_id, :integer
      
      t.column :edu_level_id, :integer, :limit => 2
      t.column :enter_year, :integer, :limit => 2
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO students (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM students WHERE id = 10000")

  end

  def self.down
    
    drop_table :students
    drop_table :teachers
    drop_table :schools
    
  end
end
