module StudentsHelper

  def fill_student_editable_fields(student, params)
    student.name = params[:name] && params[:name].strip
    
    student.university_id = params[:university_id]
    student.college_id = params[:college_id]
    student.major_id = params[:major_id]
    student.edu_level_id = params[:edu_level_id]
    student.graduation_year = params[:graduation_year]
  end
  
end
