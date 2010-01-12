class ResumeRevisionsController < ReviseResumesController
  
  insert_before_filter(
    :check_account,
    :check_active,
    :only => [:create, :destroy, :update_applied, :set_applied, :apply]
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_student,
    :only => [:update_applied, :diff, :set_applied, :apply]
  )
  
  insert_before_filter(
    :check_login_for_account,
    :check_account_type_teacher,
    :only => [:create, :destroy]
  )
  
  before_filter :check_revision, :except => [:create, :set_applied]
  
  
  def show
    jump_to("/errors/forbidden")
  end
  
  
  def create
    # put checks within action instead of before filter
    # since this actioin would NOT be cached
    # and the checks would NOT be used by other action
    part_type = ResumePartType.find(params[:revision_type_id].to_i)
    return jump_to("/errors/forbidden") unless part_type
    revision_action = ResumeRevision::Action.find_by(:name, params[:revision_action])
    return jump_to("/errors/forbidden") unless revision_action
    
    
    revision = ResumeRevision.new(
      :resume_id => @resume.id,
      :teacher_id => @teacher.id,
      :part_type_id => part_type[:id],
      :part_id => params[:revision_part_id],
      :action_id => revision_action[:id],
      :applied => false
    )
    revision.fill_data(
      case part_type[:name]
      when "edu"
        {
          :period => params[:edu_period] && params[:edu_period].strip,
          :university => params[:edu_university] && params[:edu_university].strip,
          :college => params[:edu_college] && params[:edu_college].strip,
          :major => params[:edu_major] && params[:edu_major].strip,
          :edu_type => params[:edu_type] && params[:edu_type].strip
        }
      when /_exp$/
        {
          :period => params[:exp_period] && params[:exp_period].strip,
          :title => params[:exp_title] && params[:exp_title].strip,
          :sub_title => params[:exp_sub_title] && params[:exp_sub_title].strip,
          :content => params[:exp_content] && params[:exp_content].strip
        }
      when /_skill$/
        return jump_to("/errors/forbidden") if part_type[:name] == "student_skill" && revision_action[:name] == "update"
        
        {
          :name => params[:skill_name] && params[:skill_name].strip,
          :level => params[:skill_level] && params[:skill_level].strip
        }
      when "list_section"
        {
          :title => params[:section_title] && params[:section_title].strip,
          :content => params[:section_content] && params[:section_content].strip
        }
      else
        return jump_to("/errors/forbidden") if revision_action[:name] == "add"
        
        param_key = part_type[:name].to_sym
        {:content => params[param_key] && params[param_key].strip}
      end
    ) unless revision_action[:name] == "delete"
    
    if revision.save!
      generate_notice(@teacher)

      return render(
        :partial => "/revise_resumes/revision",
        :object => revision,
        :locals => {:teachers => {@teacher.id => @teacher}}
      )
    end
    
    render :nothing => true
  end
  
  
  def destroy
    return jump_to("/errors/forbidden") unless @revision.teacher_id == @teacher.id
    
    @revision.destroy
    
    render :nothing => true
  end
  
  
  def update_applied
    @revision.applied = (params[:applied].to_i > 0)
    
    @revision.save!
    
    render :nothing => true
  end
  
  
  def diff
    render :partial => "/revise_resumes/revision_data", :locals => {:revision => @revision, :diff => true}
  end
  
  
  def set_applied
    ids = params[:revisions] || []
    ids.uniq!
    ids.compact!
    
    ResumeRevision.find(
      :all,
      :conditions => ["id in (?)", ids]
    ).each { |revision|
      if revision.resume_id == @resume.id
        revision.applied = true

        revision.save!
      end
    } if ids.size > 0
    
    render :nothing => true
  end
  
  
  def apply
    revision_action = ResumeRevision::Action.find(@revision.action_id)
    part_type = ResumePartType.find(@revision.part_type_id)
    
    part = if revision_action[:name] == "add"
      model_class = part_type[:add_as] || part_type[:model]
      ins = model_class && model_class.new
      ins.student_id = @student.id if ins.respond_to?(:student_id=)
      ins.resume_id = @resume.id if ins.respond_to?(:resume_id=)
      ins
    else
      part_type[:model] && part_type[:model].try_find(@revision.part_id)
    end
    
    revision_data = {}
    if revision_action[:name] == "delete"
      case part_type[:name]
      when /^(job_intention|award|hobby)$/
        part.content = ""
        part.save!
      when /_exp$/
        section = ResumeExpSection.find(params[:section])
        return jump_to("/errors/forbidden") unless section.resume_id == @resume.id
        
        exp, exp_type = if part_type[:name] == "student_exp"
          [
            ResumeStudentExp.get_record(section.id, part.id),
            ResumeExpSection::Student_Exp
          ]
        else
          [part, ResumeExpSection::Resume_Exp]
        end
        
        ActiveRecord::Base.transaction do
          exp.destroy

          section.remove_exp_order(exp_type, exp.id)
          section.save!
        end
      when "student_skill"
        ResumeSkill.get_record(@resume.id, part.id).destroy
      else
        part.destroy
      end
    else
      revision_data = @revision.get_data.each { |key, value| part.send("#{key}=", value) }
      
      if part_type[:name] =~ /_exp$/
        if revision_action[:name] == "add"
          section = ResumeExpSection.find(params[:section])
          return jump_to("/errors/forbidden") unless section.resume_id == @resume.id
          
          part.section_id = section.id
          
          ActiveRecord::Base.transaction do
            part.save!

            section.add_exp_order(ResumeExpSection::Resume_Exp, part.id)
            section.save!
          end
        else
          part.save!
        end
      else
        part.save!
      end
    end
    @resume.renew_updated_at(Time.now)
    
    @revision.applied = true
    @revision.save!
    
    revision_data[:id] = part.id if revision_action[:name] == "add"
    
    unless revision_data[:content].blank? || part_type[:name] == "job_intention"
      revision_data[:content] = Utils.lines(revision_data[:content])
    end
    
    render :json => {
      :action => revision_action[:name],
      :target => "#{part_type[:name]}_#{@revision.part_id}",
      :data => revision_data
    }
  end
  
  
  private
  
  def check_account_type_student
    jump_to("/errors/forbidden") unless params[:account_type] == "students"
  end
  
  
  def check_account_type_teacher
    jump_to("/errors/forbidden") unless params[:account_type] == "teachers"
  end
  
  
  def check_revision
    @revision = ResumeRevision.find(params[:id])
    jump_to("/errors/forbidden") unless @revision.resume_id == @resume.id
  end
  
  
  def generate_notice(teacher)
    teacher_account_type = AccountType.find_by(:name, "teachers")
    student_account_type = AccountType.find_by(:name, "students")
    domain = ResumeDomain.find(@resume.domain_id)
    
    Notice.generate(
      student_account_type[:id], @resume.student_id, "add_resume_revision",
      :teacher => "#{teacher.get_name}(#{teacher_account_type[:label]})",
      :resume => "#{domain[:name]}的简历",
      :url => "/#{student_account_type[:name]}/#{@resume.student_id}/revise_resumes/#{@resume.id}"
    )
  end
  
end
