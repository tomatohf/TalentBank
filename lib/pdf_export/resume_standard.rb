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
          
          :photo_width => 2.5.cm,
          :photo_left_margin => 6.mm,
          
          :font_size_name => 18,
          :font_size_title => 11,
          
          :profile_space => " " * 3,
          :profile_line_height => 1.mm,
          
          :title_bg_color => "EEEEEE",
          :title_padding_h => 2.mm,
          :title_padding_v => 1.mm,
          
          :content_indent => 6.mm,
          :content_padding_v => 2.mm,
          :content_right_margin => 2.mm,
          
          ##########
          
          :begin_left => 0,
          :total_width => 520,
          :total_height => 760,
          :font_size_sub_title => 11,
          :height_sub_title => 17,
          :vertical_pad => 2,
          :indents_single => " "
        }
      )
    end
    
    
    def draw_section_title(doc, text)
      doc.font(:zh)
      
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
    
    
    def draw_section_content(doc, &block)
      doc.move_down(@styles[:content_padding_v])
      
      doc.bounding_box(
        [@styles[:content_indent], get_cursor(doc)],
        :width => doc.bounds.width - @styles[:content_indent] - @styles[:content_right_margin]
      ) do
        block.call(doc) if block_given?
      end
      
      doc.move_down(@styles[:content_padding_v])
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
      doc.move_down(@styles[:content_padding_v])
      
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
        doc.move_down(@styles[:profile_line_height])
        zh_text(doc, optional_profiles.join(@styles[:profile_space]))
      end
      
      doc.move_down(@styles[:content_padding_v])
    end
    
    def draw_job_intention(doc, job_intention)
      draw_section_title(doc, "求职意向")
      draw_section_content(doc) do |doc|
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
        doc.move_down(photo_with_margin_height - cursor_height) if photo_with_margin_height > cursor_height
      end
    end
    
    
    def draw_edu_exps(doc, edu_exps)
      draw_section_title(doc, "教育经历")
      #draw_section_content(doc) do |doc|
      #  zh_text(doc, job_intention)
      #end

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
          [@styles[:begin_left], get_cursor(doc)],
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
          [@styles[:begin_left], get_cursor(doc)],
          "",
          :width => @styles[:total_width],
          :height => 4
        )
      end
    end
    
    
    def draw_award(doc, award)
      add_cell(
        doc,
        [@styles[:begin_left], get_cursor(doc)], "#{@styles[:indents_single]}荣誉和奖励",
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
          [@styles[:begin_left], get_cursor(doc)],
          "#{@styles[:indents_single]*3}#{line.strip}",
          :font => :zh,
          :vertical_padding => @styles[:vertical_pad],
          :font_size => @styles[:font_size_content]
        )
      end
      
      add_cell(
        doc,
        [@styles[:begin_left], get_cursor(doc)],
        "",
        :width => @styles[:total_width],
        :height => 4
      )
    end
    
    
    def draw_hobby(doc, hobby)
      add_cell(
        doc,
        [@styles[:begin_left], get_cursor(doc)],
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
          [@styles[:begin_left], get_cursor(doc)],
          "#{@styles[:indents_single]*3}#{line.strip}",
          :vertical_padding => @styles[:vertical_pad],
          :font => :zh,
          :font_size => @styles[:font_size_content]
        )
      end
      
      add_cell(
        doc,
        [@styles[:begin_left], get_cursor(doc)],
        "",
        :width => @styles[:total_width],
        :height => 4
      )
    end
    
    
    def draw_list_sections(doc, list_sections)
      list_sections.each do |list_section|
        add_cell(
          doc,
          [@styles[:begin_left], get_cursor(doc)],
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
            [@styles[:begin_left], get_cursor(doc)],
            "#{@styles[:indents_single]*3}#{line.strip}",
            :vertical_padding => @styles[:vertical_pad],
            :font => :zh,
            :font_size => @styles[:font_size_content]
          )
        end
        
        add_cell(
          doc,
          [@styles[:begin_left], get_cursor(doc)],
          "",
          :width => @styles[:total_width],
          :height => 4
        )
      end
    end
    
  end
  
end