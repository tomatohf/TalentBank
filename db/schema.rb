# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "corp_queries", :force => true do |t|
    t.integer  "corporation_id"
    t.integer  "college_id"
    t.integer  "major_id"
    t.integer  "edu_level_id",     :limit => 2
    t.integer  "graduation_year",  :limit => 2
    t.integer  "domain_id",        :limit => 2
    t.string   "keyword"
    t.string   "other_conditions"
    t.datetime "created_at"
  end

  create_table "corp_query_exp_tags", :force => true do |t|
    t.integer  "query_id"
    t.integer  "tag_id"
    t.datetime "created_at"
  end

  add_index "corp_query_exp_tags", ["tag_id", "query_id"], :name => "index_corp_query_exp_tags_on_tag_id_and_query_id", :unique => true

  create_table "corp_query_skills", :force => true do |t|
    t.integer  "query_id"
    t.integer  "skill_id"
    t.integer  "value",      :limit => 2
    t.datetime "created_at"
  end

  add_index "corp_query_skills", ["skill_id", "query_id"], :name => "index_corp_query_skills_on_skill_id_and_query_id", :unique => true

  create_table "corp_saved_queries", :force => true do |t|
    t.integer  "corporation_id"
    t.string   "conditions"
    t.string   "name",           :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corp_saved_queries", ["corporation_id", "created_at"], :name => "index_corp_saved_queries_on_corporation_id_and_created_at"

  create_table "corporation_profiles", :force => true do |t|
    t.integer  "corporation_id"
    t.string   "email"
    t.string   "phone",          :limit => 25
    t.string   "contact",        :limit => 15
    t.boolean  "contact_gender"
    t.string   "contact_title",  :limit => 15
    t.string   "address"
    t.string   "zip",            :limit => 10
    t.string   "website"
    t.integer  "nature_id",      :limit => 2
    t.integer  "size_id",        :limit => 2
    t.integer  "industry_id",    :limit => 2
    t.integer  "province_id",    :limit => 2
    t.integer  "city_id",        :limit => 2
    t.string   "desc",           :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporation_profiles", ["corporation_id"], :name => "index_corporation_profiles_on_corporation_id", :unique => true

  create_table "corporations", :force => true do |t|
    t.string   "uid",        :limit => 25
    t.string   "password"
    t.boolean  "active",                   :default => true
    t.integer  "school_id"
    t.boolean  "allow",                    :default => false
    t.string   "name",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporations", ["school_id", "allow", "created_at"], :name => "index_corporations_on_school_id_and_allow_and_created_at"
  add_index "corporations", ["school_id", "created_at"], :name => "index_corporations_on_school_id_and_created_at"
  add_index "corporations", ["school_id", "uid"], :name => "index_corporations_on_school_id_and_uid", :unique => true

  create_table "edu_exps", :force => true do |t|
    t.integer  "student_id"
    t.string   "period",     :limit => 25
    t.string   "university", :limit => 25
    t.string   "college",    :limit => 25
    t.string   "major",      :limit => 25
    t.string   "edu_type",   :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edu_exps", ["student_id"], :name => "index_edu_exps_on_student_id"

  create_table "job_photos", :force => true do |t|
    t.integer  "student_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_photos", ["student_id"], :name => "index_job_photos_on_student_id", :unique => true

  create_table "resume_awards", :force => true do |t|
    t.integer  "resume_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_awards", ["resume_id"], :name => "index_resume_awards_on_resume_id", :unique => true

  create_table "resume_exp_sections", :force => true do |t|
    t.integer  "resume_id"
    t.string   "title",      :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exp_sections", ["resume_id"], :name => "index_resume_exp_sections_on_resume_id"

  create_table "resume_exp_taggers", :force => true do |t|
    t.integer  "exp_id"
    t.integer  "tag_id"
    t.datetime "created_at"
  end

  add_index "resume_exp_taggers", ["exp_id", "tag_id"], :name => "index_resume_exp_taggers_on_exp_id_and_tag_id", :unique => true

  create_table "resume_exps", :force => true do |t|
    t.integer  "section_id"
    t.string   "period",     :limit => 25
    t.string   "title",      :limit => 25
    t.string   "sub_title",  :limit => 15
    t.string   "content",    :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exps", ["section_id"], :name => "index_resume_exps_on_section_id"

  create_table "resume_hobbies", :force => true do |t|
    t.integer  "resume_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_hobbies", ["resume_id"], :name => "index_resume_hobbies_on_resume_id", :unique => true

  create_table "resume_job_intentions", :force => true do |t|
    t.integer  "resume_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_job_intentions", ["resume_id"], :name => "index_resume_job_intentions_on_resume_id", :unique => true

  create_table "resume_list_sections", :force => true do |t|
    t.integer  "resume_id"
    t.string   "title",      :limit => 25
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_list_sections", ["resume_id"], :name => "index_resume_list_sections_on_resume_id"

  create_table "resume_list_skills", :force => true do |t|
    t.integer  "resume_id"
    t.string   "name",       :limit => 50
    t.string   "level",      :limit => 15
    t.datetime "created_at"
  end

  add_index "resume_list_skills", ["resume_id"], :name => "index_resume_list_skills_on_resume_id"

  create_table "resume_skills", :force => true do |t|
    t.integer  "resume_id"
    t.integer  "student_skill_id"
    t.datetime "created_at"
  end

  add_index "resume_skills", ["resume_id", "student_skill_id"], :name => "index_resume_skills_on_resume_id_and_student_skill_id", :unique => true

  create_table "resumes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "domain_id",  :limit => 2
    t.boolean  "online",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resumes", ["student_id", "domain_id"], :name => "index_resumes_on_student_id_and_domain_id", :unique => true

  create_table "schools", :force => true do |t|
    t.string   "abbr",       :limit => 15
    t.string   "password"
    t.boolean  "active",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["abbr"], :name => "index_schools_on_abbr", :unique => true

  create_table "student_profiles", :force => true do |t|
    t.integer  "student_id"
    t.string   "phone",               :limit => 25
    t.string   "email"
    t.string   "address"
    t.string   "zip",                 :limit => 10
    t.boolean  "gender"
    t.integer  "political_status_id", :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_profiles", ["student_id"], :name => "index_student_profiles_on_student_id", :unique => true

  create_table "student_skills", :force => true do |t|
    t.integer  "student_id"
    t.integer  "skill_id"
    t.integer  "value",      :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_skills", ["student_id", "skill_id"], :name => "index_student_skills_on_student_id_and_skill_id", :unique => true

  create_table "students", :force => true do |t|
    t.string   "number",          :limit => 25
    t.string   "password"
    t.boolean  "active",                        :default => true
    t.integer  "school_id"
    t.string   "name",            :limit => 25
    t.integer  "college_id"
    t.integer  "major_id"
    t.integer  "edu_level_id",    :limit => 2
    t.integer  "graduation_year", :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "students", ["school_id", "number"], :name => "index_students_on_school_id_and_number", :unique => true

  create_table "teachers", :force => true do |t|
    t.string   "uid",        :limit => 25
    t.string   "password"
    t.boolean  "active",                   :default => true
    t.string   "name",       :limit => 15
    t.string   "email"
    t.integer  "school_id"
    t.boolean  "admin",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teachers", ["school_id", "created_at"], :name => "index_teachers_on_school_id_and_created_at"
  add_index "teachers", ["school_id", "uid"], :name => "index_teachers_on_school_id_and_uid", :unique => true

  create_table "trash_records", :force => true do |t|
    t.string   "trashable_type"
    t.integer  "trashable_id"
    t.binary   "data",           :limit => 16777215
    t.datetime "created_at"
  end

  add_index "trash_records", ["created_at", "trashable_type"], :name => "index_trash_records_on_created_at_and_trashable_type"
  add_index "trash_records", ["trashable_type", "trashable_id"], :name => "index_trash_records_on_trashable_type_and_trashable_id"

end
