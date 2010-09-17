class TeacherStudentsController < ApplicationController
  
  layout "teachers"
  
  
  Student_Page_Size = 10
  
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => []
  
  before_filter :check_teacher
  
  before_filter :check_teacher_resume
  
  before_filter :check_resume, :only => [:resume]
  
  before_filter :check_student, :only => []
  
  
  def index
    @number = params[:n] && params[:n].strip
    
    @students = unless @number.blank?
      Student.search(
        :conditions => {:number => @number},
        :with => {:school_id => @teacher.school_id},
        :include => request.xhr? ? [] : [:resumes]
      )
    else
      @university_id = params[:u] && params[:u].strip
      @college_id = params[:c] && params[:c].strip
      @major_id = params[:m] && params[:m].strip
      @edu_level_id = params[:e] && params[:e].strip
      @graduation_year = params[:g] && params[:g].strip
      
      @name = params[:name] && params[:name].strip
      
      filters = {:school_id => @teacher.school_id}
      [:university_id, :college_id, :major_id, :edu_level_id, :graduation_year].each do |filter_key|
        filter_value = self.instance_variable_get("@#{filter_key}")
        filters.merge!(filter_key => filter_value) unless filter_value.blank?
      end
      
      page = params[:page]
      page = 1 unless page =~ /\d+/
      Student.search(
        @name,
        :page => page,
        :per_page => Student_Page_Size,
        :match_mode => Student::Search_Match_Mode,
        :order => "@relevance DESC, updated_at DESC",
        :field_weights => {},
        :with => filters,
        :include => request.xhr? ? [] : [:resumes]
      )
    end
    
    if request.xhr?
      return render(
        :layout => false,
        :inline => %Q!
          <% @students.each do |student| %>
            <a href="#" id="filter_student_<%= student.id %>" class="filter_item_link">
              <%= h(student.name) %></a>
          <% end %>
          
          <%= paging_buttons(@students) %>
        !
      )
    end
  end
  
  
  def resume
    if @resume.hidden
      return render(
        :layout => true,
        :inline => %Q!
          <div style="font-size: 14px; padding-top: 30px;">
            <div class="warn_msg">简历已被删除 ...</div>
          </div>
        !
      )
    end
    
    
    @taggers = @resume.exp_taggers
    @taggers.to_s # for eager loading ...
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_resume
    jump_to("/errors/unauthorized") unless @teacher.resume
  end
  
  
  def check_student
    @student = Student.find(params[:id])
    jump_to("/errors/forbidden") unless @student.school_id == @teacher.school_id
  end
  
  
  def check_resume
    @resume = Resume.find(params[:id])
    jump_to("/errors/forbidden") unless @resume.student.school_id == @teacher.school_id
  end
  
end
