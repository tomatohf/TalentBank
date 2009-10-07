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

ActiveRecord::Schema.define(:version => 4) do

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

  create_table "resume_exp_contents", :force => true do |t|
    t.integer  "exp_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exp_contents", ["exp_id"], :name => "index_resume_exp_contents_on_exp_id"

  create_table "resume_exp_sections", :force => true do |t|
    t.integer  "resume_id"
    t.string   "title",      :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exp_sections", ["resume_id"], :name => "index_resume_exp_sections_on_resume_id"

  create_table "resume_exps", :force => true do |t|
    t.integer  "section_id"
    t.string   "period",     :limit => 25
    t.string   "title",      :limit => 25
    t.string   "sub_title",  :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exps", ["section_id"], :name => "index_resume_exps_on_section_id"

  create_table "resume_list_sections", :force => true do |t|
    t.integer  "resume_id"
    t.string   "title",      :limit => 25
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_list_sections", ["resume_id"], :name => "index_resume_list_sections_on_resume_id"

  create_table "resume_simple_contents", :force => true do |t|
    t.integer  "resume_id"
    t.string   "job_intentions"
    t.string   "hobbies"
    t.string   "awards"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_simple_contents", ["resume_id"], :name => "index_resume_simple_contents_on_resume_id", :unique => true

  create_table "resumes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "domain_id",  :limit => 2
    t.boolean  "published",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resumes", ["student_id", "domain_id"], :name => "index_resumes_on_student_id_and_domain_id"

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

  create_table "students", :force => true do |t|
    t.string   "number",       :limit => 25
    t.string   "password"
    t.boolean  "active",                     :default => true
    t.integer  "school_id"
    t.string   "name",         :limit => 25
    t.integer  "college_id"
    t.integer  "major_id"
    t.integer  "edu_level_id", :limit => 2
    t.integer  "enter_year",   :limit => 2
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
