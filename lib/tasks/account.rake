namespace :account do
  
  desc "import student accounts"
  task :import_students => :environment do
    school_id = School.get_school_info(ENV["abbr"])[0]
    
    File.open(ENV["file"]).each do |row|
      fields = row.split(/\s+/)
      
      college = College.find_by(ENV["abbr"], :name, fields[2])
      major = Major.find_by(college[:id], :name, fields[3])
      edu_level = EduLevel.find_by(:name, fields[4])
      
      student = Student.new(
        :school_id => school_id,
        :number => fields[0],
        :password => fields[0],
        :name => fields[1],
        :college_id => college[:id],
        :major_id => major[:id],
        :edu_level_id => edu_level[:id],
        :graduation_year => fields[5]
      )
      
      puts "[ERROR] Fail to save row #{fields.inspect}" unless student.save
    end
  end
  
end
