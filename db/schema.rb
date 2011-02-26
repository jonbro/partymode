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

ActiveRecord::Schema.define(:version => 0) do

  create_table "authors", :force => true do |t|
    t.string   "login",          :limit => 80
    t.string   "password",       :limit => 40
    t.string   "email",          :limit => 80
    t.string   "security_token", :limit => 40, :default => "", :null => false
    t.datetime "token_expiry",                                 :null => false
    t.integer  "varified",                     :default => 0,  :null => false
    t.string   "gravatar",       :limit => 80
    t.string   "gravatar_hash",  :limit => 80, :default => "", :null => false
    t.text     "profile",                                      :null => false
  end

  add_index "authors", ["login"], :name => "login", :unique => true

  create_table "demographics", :force => true do |t|
    t.text "age",       :null => false
    t.text "gender",    :null => false
    t.text "location",  :null => false
    t.text "ethnicity", :null => false
  end

  create_table "launch_reminders", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
  end

  create_table "party_files", :force => true do |t|
    t.string   "filename",   :default => "", :null => false
    t.string   "title"
    t.string   "thing_type"
    t.integer  "position",   :default => 0,  :null => false
    t.datetime "created_on",                 :null => false
  end

  create_table "posts", :force => true do |t|
    t.string   "author",        :limit => 127, :default => "", :null => false
    t.text     "body"
    t.datetime "created_on",                                   :null => false
    t.integer  "party_file_id"
    t.integer  "user_id",                      :default => 0,  :null => false
    t.datetime "updated_on",                                   :null => false
  end

  add_index "posts", ["body"], :name => "body"

  create_table "replies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "body"
    t.datetime "created_on"
    t.text     "title",      :null => false
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "users", :force => true do |t|
    t.string "name"
    t.string "password"
  end

  create_table "venues", :force => true do |t|
    t.text    "name",                                         :null => false
    t.text    "location",                                     :null => false
    t.text    "hours",                                        :null => false
    t.text    "contact_email",                                :null => false
    t.text    "contact_phone",                                :null => false
    t.string  "image",         :limit => 200, :default => "", :null => false
    t.integer "author_id",                    :default => 0,  :null => false
  end

  create_table "wiki_page_versions", :force => true do |t|
    t.integer  "wiki_page_id"
    t.integer  "version"
    t.string   "title"
    t.text     "body"
    t.string   "author"
    t.datetime "updated_at"
  end

  create_table "wiki_pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "author"
    t.integer  "version"
    t.datetime "updated_at"
  end

end