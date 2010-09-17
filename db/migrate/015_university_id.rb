class UniversityId < ActiveRecord::Migration
  def self.up
    
    add_column :students, :university_id, :integer
    Student.reset_column_information
    Student.find(
      :all,
      :include => [:school]
    ).each do |student|
      student.university_id = Schools.get_school(student.school.abbr).universities.first
      student.save!
    end
    
    
    add_column :corp_queries, :university_id, :integer
    CorpQuery.reset_column_information
    CorpQuery.find(
      :all,
      :include => {:corporation => :school}
    ).each do |query|
      query.university_id = Schools.get_school(query.corporation.school.abbr).universities.first
      query.save!
    end
    
  end

  def self.down
    
    remove_column :corp_queries, :university_id
    
    remove_column :students, :university_id
    
  end
end
