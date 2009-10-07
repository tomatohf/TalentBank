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

ActiveRecord::Schema.define(:version => 3) do

  create_table "schools", :force => true do |t|
    t.string   "abbr",       :limit => 15
    t.string   "password"
    t.boolean  "active",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["abbr"], :name => "index_schools_on_abbr", :unique => true

  create_table "students", :force => true do |t|
    t.string   "number",       :limit => 25
    t.string   "password"
    t.boolean  "active",                     :default => true
    t.integer  "school_id"
    t.integer  "college_id"
    t.integer  "major_id"
    t.integer  "edu_level_id"
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
