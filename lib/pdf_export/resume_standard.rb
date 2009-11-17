module PdfExport
  
  class ResumeStandard < Base
    
    def draw(resume)
      doc = init_document
      return doc if resume.nil?
      
      
      draw_basic_info(doc, resume)
      
      
      edu_exps = EduExp.find(:all, :conditions => ["student_id = ?", resume.student_id])
      draw_edu_exps(doc, edu_exps) if edu_exps.size > 0
      
      
      Resume.load_contents(
				resume,
				:exp_sections => [
					{
						:resume_student_exps => :student_exp
					},
					:exps
				]
			)
			exp_sections = resume.exp_sections
			draw_exps(doc, exp_sections) if exp_sections.size > 0
			
			
			student_skills = StudentSkill.find(
				:all,
				:joins => "INNER JOIN resume_skills ON resume_skills.student_skill_id = student_skills.id",
				:conditions => ["resume_skills.resume_id = ?", resume.id]
			)
			resume_list_skills = resume.list_skills
			draw_skills(doc, student_skills, resume_list_skills) if student_skills.size + resume_list_skills.size > 0
			
			
			award = resume.award && resume.award.content
			draw_award(doc, award) unless award.blank?
			
			
			hobby = resume.hobby && resume.hobby.content
			draw_hobby(doc, hobby) unless hobby.blank?
			
			
			draw_list_sections(doc, resume.list_sections)
      
      
      doc
    end
    
    
    private
    
    def default_styles
      super.merge(
        {
          :host => "",
          
          :Subject => "简历",
          
          :photo_width => 2.5.cm,
          :photo_left_margin => 6.mm,
          
          :font_size_name => 18,
          :font_size_title => 12,
          
          :profile_space => " " * 3,
          
          :title_bg_color => "EEEEEE",
          :title_padding_h => 2.mm,
          :title_padding_v => 1.mm,
          
          :content_indent => 6.mm,
          :content_padding_v => 2.mm,
          :content_right_margin => 2.mm,
          :content_line_height => 1.mm,
          
          :exp_period_width => 4.cm,
          :exp_content_indent => 3.3.cm,
          :exp_title_extra_padding => 1.mm
        }
      )
    end
    
    
    def draw_section_title(doc, text)
      cell = Prawn::Table::Cell.new(
        :point => [0, get_cursor(doc)],
        :document => doc,
        :text => text,
        :width => doc.bounds.width,
        :horizontal_padding => @styles[:title_padding_h],
        :vertical_padding => @styles[:title_padding_v],
        :border_width => 0,
        :font_size => @styles[:font_size_title],
        :font_style => :normal
      )
      cell.background_color = @styles[:title_bg_color]
      cell.draw()
    end
    
    
    def draw_section_content(doc, padding_v, use_table = {})
      move_down(doc, padding_v)
      
      if use_table
        draw_section_content_table(
          doc,
          yield,
          use_table
        ) if block_given?
      else
        doc.span(
          doc.bounds.width - @styles[:content_indent] - @styles[:content_right_margin],
          :position => @styles[:content_indent]
        ) do
          yield(doc) if block_given?
        end
      end
      
      move_down(doc, padding_v)
    end
    
    
    def draw_section_content_table(doc, contents, options)
      margin_left = options.delete(:margin_left) || @styles[:content_indent]
      margin_right = options.delete(:margin_right) || @styles[:content_right_margin]
      
      doc.table(
        contents.collect { |row| [row, ""].flatten },
        {
          :position => margin_left,
          :font_size => @styles[:font_size_content],
          :vertical_padding => get_table_padding_v,
          :horizontal_padding => 0,
          :border_width => 0,
          :width => doc.bounds.width - margin_left,
          :column_widths => {
            (contents.first.size + 1) => margin_right
          }.merge(options.delete(:column_widths) || {})
        }.merge(options)
      )
    end
    
    
    def draw_list_content(doc, content, icon = "")
      (content_lines = lines(content)).each_index do |i|
        move_down(doc, @styles[:content_line_height]) if i > 0
        zh_text(doc, "#{icon}#{content_lines[i].strip}")
      end
    end
    
    
    def draw_list_section(doc, title, content)
      draw_section_title(doc, title)
      
      draw_section_content(doc, @styles[:content_padding_v], false) do |doc|
        draw_list_content(doc, content)
      end
    end
    
    
    def draw_photo(doc, photo)
      page = doc.bounds
      
      safe_image(
        doc,
        open("http://#{@styles[:host]}#{photo}"),
        :at => [
          page.width - @styles[:photo_width] - @styles[:title_padding_h],
          page.height
        ],
        :width => @styles[:photo_width]
      )
    end
    
    def draw_name(doc, name)
      zh_text(
        doc,
        name,
        :size => @styles[:font_size_name],
        :style => :bold
      )
    end
    
    def draw_profile(doc, profile)
      move_down(doc, @styles[:content_padding_v])
      
      zh_text(
        doc,
        [
          "电话: #{profile.phone}",
          "电子邮件: #{profile.email}"
        ].join(@styles[:profile_space])
      )
      
      
      optional_profiles = []
      optional_profiles << %Q!性别: #{profile.gender ? "男" : "女"}! unless profile.gender.nil?
      optional_profiles << %Q!政治面貌: #{PoliticalStatus.find(profile.political_status_id)[:name]}! unless profile.political_status_id.nil?
      optional_profiles << %Q!地址: #{profile.address}! unless profile.address.blank?
      optional_profiles << %Q!邮编: #{profile.zip}! unless profile.zip.blank?
      if optional_profiles.size > 0
        move_down(doc, @styles[:content_line_height])
        zh_text(doc, optional_profiles.join(@styles[:profile_space]))
      end
      
      move_down(doc, @styles[:content_padding_v])
    end
    
    def draw_job_intention(doc, job_intention)
      draw_section_title(doc, "求职意向")
      
      draw_section_content(doc, @styles[:content_padding_v], false) do |doc|
        zh_text(doc, job_intention)
      end
    end
    
    
    def draw_basic_info(doc, resume)
      photo = JobPhoto.get_record(resume.student_id).image.url(:cropped)
      photo_drawn = !photo.blank? && draw_photo(doc, photo)
      
      page = doc.bounds
      info_width = page.width - @styles[:title_padding_h] - (photo_drawn ? (@styles[:photo_left_margin] + @styles[:photo_width]) : 0)

      doc.bounding_box(
        [@styles[:title_padding_h], get_cursor(doc)],
        :width => info_width - @styles[:title_padding_h]
      ) do
        draw_name(doc, resume.student.name)
        draw_profile(doc, StudentProfile.get_record(resume.student_id))
      end
      
      job_intention = resume.job_intention && resume.job_intention.content
      unless job_intention.blank?
        doc.bounding_box(
          [0, get_cursor(doc)],
          :width => info_width
        ) do
          draw_job_intention(doc, job_intention)
        end
      end
      
      
      if photo_drawn
        cursor_height = page.height - get_cursor(doc)
        photo_with_margin_height = photo_drawn.scaled_height + @styles[:content_padding_v]
        move_down(doc, photo_with_margin_height - cursor_height) if photo_with_margin_height > cursor_height
      end
    end
    
    
    def draw_edu_exps(doc, edu_exps)
      draw_section_title(doc, "教育经历")
      
      draw_section_content(
        doc,
        get_padding_v_for_table_content,
        :column_widths => {0 => @styles[:exp_period_width]}
      ) do
        edu_exps.collect { |edu_exp|
          [
            edu_exp.period,
            edu_exp.university,
            edu_exp.college,
            edu_exp.major,
            edu_exp.edu_type
          ]
        }
      end
    end
    
    
    def draw_exps(doc, exp_sections)
      exp_sections.each do |exp_section|
        order = exp_section.get_exp_order

				exps = {}
				exp_section.exps.each do |exp|
					exps[exp.id] = exp
				end

				resume_student_exps = {}
				exp_section.resume_student_exps.each do |resume_student_exp|
					resume_student_exps[resume_student_exp.id] = resume_student_exp
				end
				
				
        draw_section_title(doc, exp_section.title)
        
        move_down(doc, get_padding_v_for_table_content)
        
        order.each do |o|
          exp_id = o[1].to_i
					exp = case o[0].to_i
						when ResumeExpSection::Student_Exp
							resume_student_exp = resume_student_exps[exp_id]
							resume_student_exp && resume_student_exp.student_exp
						when ResumeExpSection::Resume_Exp
							exps[exp_id]
						else
							nil
					end
					
          if exp
            draw_section_content(
              doc,
              0,
              :column_widths => {0 => @styles[:exp_period_width]},
              :align => {2 => :right}
            ) do
              [
                [
                  exp.period,
                  "<b>#{exp.title}</b>",
                  "<b>#{h(exp.sub_title)}</b>"
                ]
              ]
            end
            
            move_down(doc, @styles[:exp_title_extra_padding])
              
            draw_section_content(
              doc,
              0,
              :column_widths => {0 => @styles[:exp_content_indent]}
            ) do
              lines(exp.content).collect { |line|
                ["", "&bull; #{line.strip}"]
              }
            end
            
            move_down(doc, @styles[:exp_title_extra_padding])
          end
        end
        
        move_down(doc, get_padding_v_for_table_content)
      end
    end
    
    
    def draw_skills(doc, student_skills, resume_list_skills)
      draw_section_title(doc, "技能和证书")
      
      draw_section_content(
        doc,
        get_padding_v_for_table_content,
        :align => {1 => :right}
      ) do
        student_skills.collect { |student_skill|
          skill = Skill.find(student_skill.skill_id)
          [
            skill[:name],
            SkillValueTypes.get_type(skill[:value_type]).render_label(skill[:data], student_skill.value)
          ]
        } + resume_list_skills.collect { |resume_list_skill|
          [
            resume_list_skill.name,
            resume_list_skill.level
          ]
        }
      end
    end
    
    
    def draw_award(doc, award)
      draw_list_section(doc, "荣誉和奖励", award)
    end
    
    
    def draw_hobby(doc, hobby)
      draw_list_section(doc, "特长和爱好", hobby)
    end
    
    
    def draw_list_sections(doc, list_sections)
      list_sections.each do |list_section|
        draw_list_section(doc, list_section.title, list_section.content) unless list_section.title.blank? || list_section.content.blank?
      end
    end
    
    
    def get_table_padding_v
      @styles[:content_line_height]/2
    end
    
    def get_padding_v_for_table_content
      padding_v = @styles[:content_padding_v] - @styles[:content_line_height]/2
      padding_v = 0 if padding_v < 0
      padding_v
    end
    
  end
  
end