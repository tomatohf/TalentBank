class TeacherNoteTargetType < HashModel::Simple
  
  def self.data
    [
      {
        :id => 10, :name => "corporations", :title => "企业",
        :url => Proc.new { |target| "/corporations/#{target.id}" }
      },
      {
        :id => 20, :name => "students", :title => "学生",
        :url => Proc.new { |target| "/students/#{target.id}" }
      },
      {
        :id => 30, :name => "jobs", :title => "岗位",
        :url => Proc.new { |target| "/corporations/#{target.corporation_id}/jobs/#{target.id}" }
      }
    ]
  end
  
end
