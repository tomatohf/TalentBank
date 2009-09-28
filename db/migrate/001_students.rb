class Students < ActiveRecord::Migration
  def self.up
    
    create_table :schools, :force => true do |t|
      t.column :abbreviation, :string, :limit => 15
      t.column :name, :string, :limit => 50
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO schools (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM schools WHERE id = 10000")
    
    
    create_table :students, :force => true do |t|
      t.column :number, :string, :limit => 25
      t.column :password, :string
      
      t.column :school_id, :integer
      
      t.column :active, :boolean, :default => true
      t.column :enabled, :boolean, :default => true
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO students (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM students WHERE id = 10000")
    
    
    create_table :autologins, :force => true do |t|
      t.column :session_id, :string
      t.column :student_id, :integer

      t.column :expire_time, :datetime
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

  end

  def self.down
    drop_table :autologins
    drop_table :students
    drop_table :schools
  end
end
