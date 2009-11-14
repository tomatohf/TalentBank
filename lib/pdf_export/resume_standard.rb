module PdfExport
  
  class ResumeStandard < Base
    
    def draw(resume)
      doc = init_document
      return doc if resume.nil?
      
      
      photo = JobPhoto.get_record(resume.student_id).image.url(:normal)
      draw_photo(doc, photo) unless photo.blank?
      
      draw_name(doc, resume.student.name)
      
      profile = StudentProfile.get_record(resume.student_id)
      draw_profile(
        doc,
        {
          :phone => profile.phone,
          :email => profile.email,
          
          :address => profile.address,
          :zip => profile.zip,
          :gender => profile.gender,
          :political_status => profile.political_status_id && PoliticalStatus.find(profile.political_status_id)[:name],
        }
      )
      
      draw_job_intention(doc, resume.job_intention && resume.job_intention.content, photo.blank?)
      
      
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
			draw_resume_exps(doc, exp_sections) if exp_sections.size > 0
			
			
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
          
          :begin_left => 0,
          :begin_bottom => 769,
          :total_width => 520,
          :total_height => 760,
          :font_size_title => 18,
          :font_size_sub_title => 11,
          :height_sub_title => 17,
          :font_size_content => 10,
          :vertical_pad => 2,
          :indents_single => " "
        }
      )
    end
    
    
    def draw_photo(doc, photo)
      doc.image(
        open("http://#{@styles[:host]}#{photo}"),
        :at => [460, @styles[:begin_bottom]],
        :width => 60,
        :height => 80
      )
    end
    
    def draw_name(doc, name)
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        name,
        :width => 400,
        :if_bg => false,
        :vertical_padding => @styles[:vertical_pad],
        :font => :zh,
        :font_size => @styles[:font_size_title],
        :font_style => :bold
      )
    end
    
    def draw_profile(doc, profile)
      add_table(
        doc,
        [
          [
            "#{@styles[:indents_single]}电话: #{profile[:phone]}",
            "#{@styles[:indents_single]*4}电子邮件: ",
            "#{profile[:email]}"
          ]
        ],
        :vertical_padding => @styles[:vertical_pad],
        :left_position => @styles[:begin_left],
        :font_config => {
          :font_size => @styles[:font_size_content]
        },
        :font_configs => {
          0 => {:font => :zh, :font_style => :normal},
          1 => {:font => :zh, :font_style => :bold},
          2 => {:font => :zh, :font_style => :bold}
        }
      )
      
      
      line3 = "#{@styles[:indents_single]}"
      ifblock = false
      unless profile[:gender].nil?
        line3 += "性别: #{profile[:gender] ? '男' : '女'}"
        ifblock = true;
      end
      unless profile[:political_status].blank?
        line3 += "#{@styles[:indents_single]*4}" if ifblock
        line3 += "政治面貌: #{profile[:political_status]}"
        ifblock = true unless ifblock
      end
      unless profile[:address].blank?
        line3 += "#{@styles[:indents_single]*4}" if ifblock
        line3 += "地址: #{profile[:address]}"
        ifblock = true unless ifblock
      end
      unless profile[:zip].blank?
        line3 += "#{@styles[:indents_single]*4}" if ifblock
        line3 += "邮编: #{profile[:zip]}"
        ifblock = true unless ifblock
      end
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        line3,
        :vertical_padding => @styles[:vertical_pad],
        :font => :zh,
        :font_size => @styles[:font_size_content]
      )
    end
    
    def draw_job_intention(doc, job_intention, no_photo)
      tem_width = 448
      tem_width = @styles[:total_width] if no_photo
      if job_intention.blank?
        add_cell(doc, [@styles[:begin_left],get_y_cursor(doc)],"  ",{:width => tem_width, :height => @styles[:height_sub_title], :vertical_padding => @styles[:vertical_pad], :font => :zh, :font_size => @styles[:font_size_sub_title], :font_sytle => :bold})
        add_cell(doc, [@styles[:begin_left],get_y_cursor(doc)],"#{@styles[:indents_single]*3}",{:height => 20, :vertical_padding => @styles[:vertical_pad], :font => :zh, :font_size => @styles[:font_size_content],:test => "test"})
      else
        add_cell(doc, [@styles[:begin_left],get_y_cursor(doc)],"#{@styles[:indents_single]}求职意向: ",{:width => tem_width, :vertical_padding => @styles[:vertical_pad], :height => @styles[:height_sub_title], :if_bg => true,:font => :zh, :font_size => @styles[:font_size_sub_title], :font_sytle => :bold})
        add_cell(doc, [@styles[:begin_left],get_y_cursor(doc)],"#{@styles[:indents_single]*3}#{job_intention}",{:height => 20, :vertical_padding => 4, :font => :zh, :font_size => @styles[:font_size_content]})
      end
    end
    
    
    def draw_edu_exps(doc, edu_exps)
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        "#{@styles[:indents_single]}教育经历",
        :width => @styles[:total_width],
        :height => @styles[:height_sub_title],
        :vertical_padding => @styles[:vertical_pad],
        :if_bg => true,
        :font => :zh,
        :font_size => @styles[:font_size_sub_title],
        :font_sytle => :bold
      )

      add_table(
        doc,
        edu_exps.collect { |edu_exp|
          [
            "#{@styles[:indents_single]*3}#{edu_exp.period}","#{edu_exp.university}",
            "#{edu_exp.college}",
            "#{edu_exp.major}",
            "#{edu_exp.edu_type}"
          ]
        },
        :vertical_padding => 4,
        :left_position => @styles[:begin_left],
        :height => 20,
        :widths => {0 => 100,1 => 140,2 => 110,3 => 110, 4 => 60},
        :font_config => {:font => :zh , :font_size => @styles[:font_size_content]},
        :font_configs => {
          0 => {:font_style => :normal},
          1 => {:font_style => :bold},
          2 => {:font_style => :bold},
          3 => {:font_style => :bold},
          4 => {:font_style => :bold}
        }
      )
    end
    
    
    def draw_resume_exps(doc, exp_sections)
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
				
				
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "#{@styles[:indents_single]}#{exp_section[:title]}",
          :width => @styles[:total_width],
          :height => @styles[:height_sub_title],
          :vertical_padding => @styles[:vertical_pad],
          :if_bg => true,
          :font => :zh,
          :font_size => @styles[:font_size_sub_title],
          :font_sytle => :bold
        )
        

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
            add_table(
              doc,
              [
                [
                  "#{@styles[:indents_single]*3}#{exp.period}",
                  "#{exp.title}",
                  "#{exp.sub_title}"
                ]
              ],
              :vertical_padding => 4,
              :left_position => @styles[:begin_left],
              :height => 20,
              :widths => {0 => 110, 1 => 310, 2 => 100},
              :aligns =>{0 => :left, 1 => :left, 2 => :right},
              :font_config => {:font => :zh , :font_size => @styles[:font_size_content]},
              :font_configs => {
                0 => {:font_style => :normal},
                1 => {:font_style => :bold},
                2 => {:font_style => :bold}
              }
            )
            
            add_table(
              doc,
              lines(exp.content).collect { |line|
                [
                  "#{@styles[:indents_single]*20}",
                  "●    ",
                  "#{line.strip}"
                ]
              },
              :left_position => @styles[:begin_left],
              :font_config => {:font => :zh},
              :font_configs => {
                0 => {:font_size => @styles[:font_size_content]},
                1 => {:font_size => 3},
                2 => {:font_size => @styles[:font_size_content]}
              },
              :vertical_paddings => {
                0 => @styles[:vertical_pad],
                1 => 7,
                2 => @styles[:vertical_pad]
              }
            )
          end
        end
        
        
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "",
          :width => @styles[:total_width],
          :height => 4
        )
      end
    end
    
    
    def draw_award(doc, award)
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)], "#{@styles[:indents_single]}荣誉和奖励",
        :width => @styles[:total_width],
        :height => @styles[:height_sub_title],
        :vertical_padding => @styles[:vertical_pad],
        :if_bg => true, :font => :zh,
        :font_size => @styles[:font_size_sub_title],
        :font_sytle => :bold
      )
      
      lines(award).each do |line|
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "#{@styles[:indents_single]*3}#{line.strip}",
          :font => :zh,
          :vertical_padding => @styles[:vertical_pad],
          :font_size => @styles[:font_size_content]
        )
      end
      
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        "",
        :width => @styles[:total_width],
        :height => 4
      )
    end
    
    
    def draw_hobby(doc, hobby)
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        "#{@styles[:indents_single]}特长和爱好",
        :width => @styles[:total_width],
        :height => @styles[:height_sub_title],
        :vertical_padding => @styles[:vertical_pad],
        :if_bg => true ,
        :font => :zh,
        :font_size => @styles[:font_size_sub_title],
        :font_sytle => :bold
      )
      
      lines(hobby).each do |line|
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "#{@styles[:indents_single]*3}#{line.strip}",
          :vertical_padding => @styles[:vertical_pad],
          :font => :zh,
          :font_size => @styles[:font_size_content]
        )
      end
      
      add_cell(
        doc,
        [@styles[:begin_left], get_y_cursor(doc)],
        "",
        :width => @styles[:total_width],
        :height => 4
      )
    end
    
    
    def draw_list_sections(doc, list_sections)
      list_sections.each do |list_section|
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "#{@styles[:indents_single]}#{list_section.title}",
          :width => @styles[:total_width],
          :height => @styles[:height_sub_title],
          :vertical_padding => @styles[:vertical_pad],
          :if_bg => true,
          :font => :zh,
          :font_size => @styles[:font_size_sub_title],
          :font_sytle => :bold
        )
        
        lines(list_section.content).each do |line|
          add_cell(
            doc,
            [@styles[:begin_left], get_y_cursor(doc)],
            "#{@styles[:indents_single]*3}#{line.strip}",
            :vertical_padding => @styles[:vertical_pad],
            :font => :zh,
            :font_size => @styles[:font_size_content]
          )
        end
        
        add_cell(
          doc,
          [@styles[:begin_left], get_y_cursor(doc)],
          "",
          :width => @styles[:total_width],
          :height => 4
        )
      end
    end
    
  end
  
end