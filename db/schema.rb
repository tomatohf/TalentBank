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

ActiveRecord::Schema.define(:version => 33) do

  create_table "blocked_corps", :force => true do |t|
    t.integer  "student_id"
    t.integer  "corporation_id"
    t.datetime "updated_at"
  end

  add_index "blocked_corps", ["student_id", "corporation_id"], :name => "index_blocked_corps_on_student_id_and_corporation_id", :unique => true

  create_table "corp_queries", :force => true do |t|
    t.integer  "corporation_id"
    t.integer  "college_id"
    t.integer  "major_id"
    t.integer  "edu_level_id",     :limit => 2
    t.integer  "graduation_year",  :limit => 2
    t.integer  "domain_id",        :limit => 2
    t.string   "keyword"
    t.string   "other_conditions"
    t.boolean  "from_saved"
    t.datetime "updated_at"
    t.integer  "university_id"
  end

  add_index "corp_queries", ["updated_at"], :name => "index_corp_queries_on_updated_at"

  create_table "corp_query_exp_tags", :force => true do |t|
    t.integer  "query_id"
    t.integer  "tag_id"
    t.datetime "updated_at"
  end

  add_index "corp_query_exp_tags", ["tag_id", "query_id"], :name => "index_corp_query_exp_tags_on_tag_id_and_query_id", :unique => true

  create_table "corp_query_skills", :force => true do |t|
    t.integer  "query_id"
    t.integer  "skill_id"
    t.integer  "value",      :limit => 2
    t.datetime "updated_at"
  end

  add_index "corp_query_skills", ["skill_id", "query_id"], :name => "index_corp_query_skills_on_skill_id_and_query_id", :unique => true

  create_table "corp_resume_taggers", :force => true do |t|
    t.integer  "corp_id"
    t.integer  "resume_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corp_resume_taggers", ["corp_id", "created_at"], :name => "index_corp_resume_taggers_on_corp_id_and_created_at"
  add_index "corp_resume_taggers", ["corp_id", "resume_id", "tag_id"], :name => "index_corp_resume_taggers_on_corp_id_and_resume_id_and_tag_id", :unique => true
  add_index "corp_resume_taggers", ["corp_id", "tag_id", "created_at"], :name => "index_corp_resume_taggers_on_corp_id_and_tag_id_and_created_at"

  create_table "corp_resume_tags", :force => true do |t|
    t.string   "name",       :limit => 30
    t.datetime "updated_at"
  end

  add_index "corp_resume_tags", ["name"], :name => "index_corp_resume_tags_on_name", :unique => true

  create_table "corp_saved_queries", :force => true do |t|
    t.integer  "corporation_id"
    t.string   "conditions"
    t.string   "name",           :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corp_saved_queries", ["corporation_id", "created_at"], :name => "index_corp_saved_queries_on_corporation_id_and_created_at"

  create_table "corp_viewed_resumes", :force => true do |t|
    t.integer  "corporation_id"
    t.integer  "resume_id"
    t.datetime "updated_at"
  end

  add_index "corp_viewed_resumes", ["updated_at"], :name => "index_corp_viewed_resumes_on_updated_at"

  create_table "corporation_profiles", :force => true do |t|
    t.integer  "corporation_id"
    t.string   "email"
    t.string   "phone"
    t.string   "contact",              :limit => 100
    t.boolean  "contact_gender"
    t.string   "contact_title",        :limit => 15
    t.string   "address"
    t.string   "zip",                  :limit => 10
    t.string   "website"
    t.integer  "nature_id",            :limit => 2
    t.integer  "size_id",              :limit => 2
    t.integer  "industry_id",          :limit => 2
    t.integer  "province_id",          :limit => 2
    t.integer  "city_id",              :limit => 2
    t.string   "desc",                 :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "industry_category_id", :limit => 2
    t.string   "business_scope"
    t.integer  "job_district_id",      :limit => 2
  end

  add_index "corporation_profiles", ["corporation_id"], :name => "index_corporation_profiles_on_corporation_id", :unique => true

  create_table "corporations", :force => true do |t|
    t.string   "uid",              :limit => 25
    t.string   "password"
    t.boolean  "active",                         :default => true
    t.integer  "school_id"
    t.boolean  "allow_query",                    :default => false
    t.string   "name",             :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id"
    t.integer  "intern_status_id", :limit => 2
  end

  add_index "corporations", ["school_id", "created_at"], :name => "index_corporations_on_school_id_and_created_at"
  add_index "corporations", ["school_id", "name"], :name => "index_corporations_on_school_id_and_name", :unique => true
  add_index "corporations", ["school_id", "uid"], :name => "index_corporations_on_school_id_and_uid", :unique => true
  add_index "corporations", ["updated_at"], :name => "index_corporations_on_updated_at"

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

  create_table "intern_corp_nature_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "nature_id",  :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_corp_nature_blacklists", ["student_id", "nature_id"], :name => "index_intern_corp_nature_blacklists_on_student_and_nature", :unique => true

  create_table "intern_corp_nature_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "nature_id",  :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_corp_nature_wishes", ["student_id", "nature_id"], :name => "index_intern_corp_nature_wishes_on_student_and_nature", :unique => true

  create_table "intern_corporation_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "corporation_id"
    t.datetime "updated_at"
  end

  add_index "intern_corporation_blacklists", ["student_id", "corporation_id"], :name => "index_intern_corporation_blacklists_on_student_and_corporation", :unique => true

  create_table "intern_corporation_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "corporation_id"
    t.datetime "updated_at"
  end

  add_index "intern_corporation_wishes", ["student_id", "corporation_id"], :name => "index_intern_corporation_wishes_on_student_id_and_corporation_id", :unique => true

  create_table "intern_industry_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "industry_category_id", :limit => 2
    t.integer  "industry_id",          :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_industry_blacklists", ["student_id", "industry_category_id", "industry_id"], :name => "index_intern_industry_blacklists_on_student_and_industry", :unique => true

  create_table "intern_industry_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "industry_category_id", :limit => 2
    t.integer  "industry_id",          :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_industry_wishes", ["student_id", "industry_category_id", "industry_id"], :name => "index_intern_industry_wishes_on_student_and_industry", :unique => true

  create_table "intern_job_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_id"
    t.datetime "updated_at"
  end

  add_index "intern_job_blacklists", ["student_id", "job_id"], :name => "index_intern_job_blacklists_on_student_id_and_job_id", :unique => true

  create_table "intern_job_category_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_category_class_id", :limit => 2
    t.integer  "job_category_id",       :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_job_category_blacklists", ["student_id", "job_category_class_id", "job_category_id"], :name => "index_intern_job_category_blacklists_on_student_and_category", :unique => true

  create_table "intern_job_category_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_category_class_id", :limit => 2
    t.integer  "job_category_id",       :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_job_category_wishes", ["student_id", "job_category_class_id", "job_category_id"], :name => "index_intern_job_category_wishes_on_student_and_category", :unique => true

  create_table "intern_job_district_blacklists", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_district_id", :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_job_district_blacklists", ["student_id", "job_district_id"], :name => "index_intern_job_district_blacklists_on_student_and_district", :unique => true

  create_table "intern_job_district_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_district_id", :limit => 2
    t.datetime "updated_at"
  end

  add_index "intern_job_district_wishes", ["student_id", "job_district_id"], :name => "index_intern_job_district_wishes_on_student_and_district", :unique => true

  create_table "intern_job_wishes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "job_id"
    t.datetime "updated_at"
  end

  add_index "intern_job_wishes", ["student_id", "job_id"], :name => "index_intern_job_wishes_on_student_id_and_job_id", :unique => true

  create_table "intern_logs", :force => true do |t|
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.integer  "job_id"
    t.integer  "event_id",   :limit => 2
    t.integer  "result_id",  :limit => 2
    t.datetime "occur_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "intern_logs", ["job_id", "event_id", "result_id", "occur_at"], :name => "index_intern_logs_on_job_and_event_and_result_and_occur"
  add_index "intern_logs", ["student_id", "occur_at"], :name => "index_intern_logs_on_student_id_and_occur_at"
  add_index "intern_logs", ["updated_at"], :name => "index_intern_logs_on_updated_at"

  create_table "intern_profiles", :force => true do |t|
    t.integer  "student_id"
    t.datetime "begin_at"
    t.integer  "period_id",  :limit => 2
    t.integer  "workday_id", :limit => 2
    t.integer  "major_id",   :limit => 2
    t.integer  "salary",     :limit => 10,   :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birthplace", :limit => 25
    t.string   "birthmonth", :limit => 10
    t.string   "intention",  :limit => 300
    t.string   "skill",      :limit => 300
    t.string   "experience", :limit => 2000
    t.string   "desc",       :limit => 300
  end

  add_index "intern_profiles", ["student_id"], :name => "index_intern_profiles_on_student_id", :unique => true

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

  create_table "jobs", :force => true do |t|
    t.integer  "corporation_id"
    t.string   "name",                :limit => 50
    t.integer  "category_class_id",   :limit => 2
    t.integer  "category_id",         :limit => 2
    t.string   "manager",             :limit => 50
    t.string   "desc",                :limit => 1000
    t.integer  "district_id",         :limit => 2
    t.string   "place",               :limit => 200
    t.integer  "salary",              :limit => 10,   :precision => 10, :scale => 0
    t.string   "welfare",             :limit => 300
    t.integer  "number",              :limit => 2
    t.integer  "interview_number",    :limit => 2
    t.datetime "begin_at"
    t.integer  "period_id",           :limit => 2
    t.integer  "workday_id",          :limit => 2
    t.integer  "edu_level_id",        :limit => 2
    t.integer  "graduation_id",       :limit => 2
    t.integer  "major_id",            :limit => 2
    t.string   "requirement",         :limit => 500
    t.datetime "recruit_end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "gender"
    t.integer  "political_status_id", :limit => 2
    t.integer  "result_id",           :limit => 2
    t.integer  "intern_status_id",    :limit => 2
  end

  add_index "jobs", ["corporation_id", "created_at"], :name => "index_jobs_on_corporation_id_and_created_at"

  create_table "notices", :force => true do |t|
    t.integer  "account_type_id", :limit => 1
    t.integer  "account_id"
    t.integer  "type_id",         :limit => 2
    t.boolean  "unread",                         :default => true
    t.string   "content",         :limit => 300
    t.datetime "updated_at"
  end

  add_index "notices", ["account_type_id", "account_id", "unread", "updated_at"], :name => "index_notices_on_account_and_unread_and_updated_at"

  create_table "requests", :force => true do |t|
    t.integer  "account_type_id",   :limit => 1
    t.integer  "account_id"
    t.integer  "requester_type_id", :limit => 1
    t.integer  "requester_id"
    t.integer  "type_id",           :limit => 2
    t.integer  "reference_id"
    t.string   "data",              :limit => 600
    t.datetime "updated_at"
  end

  add_index "requests", ["account_type_id", "account_id", "type_id", "reference_id"], :name => "index_requests_on_account_and_type_and_reference"
  add_index "requests", ["requester_type_id", "requester_id", "type_id", "reference_id"], :name => "index_requests_on_requester_and_type_and_reference"

  create_table "resume_awards", :force => true do |t|
    t.integer  "resume_id"
    t.string   "content",    :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_awards", ["resume_id"], :name => "index_resume_awards_on_resume_id", :unique => true

  create_table "resume_comments", :force => true do |t|
    t.integer  "resume_id"
    t.integer  "part_type_id",    :limit => 2
    t.integer  "part_id"
    t.integer  "account_type_id", :limit => 1
    t.integer  "account_id"
    t.string   "content",         :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_comments", ["account_type_id", "account_id", "created_at"], :name => "index_resume_comments_on_account_and_created_at"
  add_index "resume_comments", ["resume_id"], :name => "index_resume_comments_on_resume_id"

  create_table "resume_exp_sections", :force => true do |t|
    t.integer  "resume_id"
    t.string   "title",      :limit => 25
    t.string   "exp_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_exp_sections", ["resume_id"], :name => "index_resume_exp_sections_on_resume_id"

  create_table "resume_exp_taggers", :force => true do |t|
    t.integer  "resume_id"
    t.integer  "tag_id"
    t.datetime "updated_at"
  end

  add_index "resume_exp_taggers", ["resume_id", "tag_id"], :name => "index_resume_exp_taggers_on_resume_id_and_tag_id", :unique => true

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
    t.string   "content",    :limit => 500
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
    t.string   "content",    :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_list_sections", ["resume_id"], :name => "index_resume_list_sections_on_resume_id"

  create_table "resume_list_skills", :force => true do |t|
    t.integer  "resume_id"
    t.string   "name",       :limit => 50
    t.string   "level",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_list_skills", ["resume_id"], :name => "index_resume_list_skills_on_resume_id"

  create_table "resume_revisions", :force => true do |t|
    t.integer  "resume_id"
    t.integer  "teacher_id"
    t.integer  "part_type_id", :limit => 2
    t.integer  "part_id"
    t.integer  "action_id",    :limit => 1
    t.string   "data",         :limit => 1000
    t.boolean  "applied",                      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resume_revisions", ["resume_id"], :name => "index_resume_revisions_on_resume_id"
  add_index "resume_revisions", ["teacher_id", "created_at"], :name => "index_resume_revisions_on_teacher_id_and_created_at"

  create_table "resume_skills", :force => true do |t|
    t.integer  "resume_id"
    t.integer  "student_skill_id"
    t.datetime "updated_at"
  end

  add_index "resume_skills", ["resume_id", "student_skill_id"], :name => "index_resume_skills_on_resume_id_and_student_skill_id", :unique => true
  add_index "resume_skills", ["student_skill_id", "resume_id"], :name => "index_resume_skills_on_student_skill_id_and_resume_id"

  create_table "resume_student_exps", :force => true do |t|
    t.integer  "section_id"
    t.integer  "exp_id"
    t.datetime "updated_at"
  end

  add_index "resume_student_exps", ["exp_id"], :name => "index_resume_student_exps_on_exp_id"
  add_index "resume_student_exps", ["section_id", "exp_id"], :name => "index_resume_student_exps_on_section_id_and_exp_id", :unique => true

  create_table "resumes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "domain_id",  :limit => 2
    t.boolean  "online",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",                  :default => false
  end

  add_index "resumes", ["student_id", "domain_id"], :name => "index_resumes_on_student_id_and_domain_id", :unique => true
  add_index "resumes", ["updated_at"], :name => "index_resumes_on_updated_at"

  create_table "schools", :force => true do |t|
    t.string   "abbr",       :limit => 15
    t.string   "password"
    t.boolean  "active",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["abbr"], :name => "index_schools_on_abbr", :unique => true

  create_table "student_exps", :force => true do |t|
    t.integer  "student_id"
    t.string   "period",     :limit => 25
    t.string   "title",      :limit => 25
    t.string   "sub_title",  :limit => 15
    t.string   "content",    :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_exps", ["student_id"], :name => "index_student_exps_on_student_id"

  create_table "student_profile_copies", :force => true do |t|
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

  add_index "student_profile_copies", ["student_id"], :name => "index_student_profile_copies_on_student_id", :unique => true

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
    t.integer  "university_id"
    t.boolean  "complete",                      :default => false
  end

  add_index "students", ["school_id", "created_at"], :name => "index_students_on_school_id_and_created_at"
  add_index "students", ["school_id", "number"], :name => "index_students_on_school_id_and_number", :unique => true
  add_index "students", ["updated_at"], :name => "index_students_on_updated_at"

  create_table "teacher_notes", :force => true do |t|
    t.integer  "target_type_id", :limit => 2
    t.integer  "target_id"
    t.integer  "teacher_id"
    t.string   "content",        :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teacher_notes", ["target_type_id", "target_id", "created_at"], :name => "index_teacher_notes_on_target_and_created_at"

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
    t.boolean  "statistic",                :default => false
    t.boolean  "resume",                   :default => true
    t.boolean  "revision",                 :default => false
    t.boolean  "student",                  :default => false
  end

  add_index "teachers", ["school_id", "created_at"], :name => "index_teachers_on_school_id_and_created_at"
  add_index "teachers", ["school_id", "revision"], :name => "index_teachers_on_school_id_and_revision"
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
