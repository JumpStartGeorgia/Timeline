# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130619134303) do

  create_table "categories", :force => true do |t|
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["type_id"], :name => "index_categories_on_type_id"

  create_table "categories_events", :force => true do |t|
    t.integer  "category_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_events", ["category_id"], :name => "index_categories_events_on_category_id"
  add_index "categories_events", ["event_id"], :name => "index_categories_events_on_event_id"

  create_table "category_translations", :force => true do |t|
    t.integer  "category_id"
    t.string   "locale"
    t.string   "name"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_translations", ["category_id"], :name => "index_category_translations_on_category_id"
  add_index "category_translations", ["locale"], :name => "index_category_translations_on_locale"
  add_index "category_translations", ["name"], :name => "index_category_translations_on_name"

  create_table "event_translations", :force => true do |t|
    t.integer  "event_id"
    t.string   "locale"
    t.string   "headline"
    t.text     "story"
    t.string   "media"
    t.string   "credit"
    t.string   "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_img_file_name"
    t.string   "media_img_content_type"
    t.integer  "media_img_file_size"
    t.datetime "media_img_updated_at"
    t.boolean  "media_img_verified",     :default => false
  end

  add_index "event_translations", ["event_id"], :name => "index_event_translations_on_event_id"
  add_index "event_translations", ["locale"], :name => "index_event_translations_on_locale"

  create_table "events", :force => true do |t|
    t.string   "event_type"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "start_time"
    t.time     "end_time"
  end

  add_index "events", ["end_date", "end_time"], :name => "idx_events_end"
  add_index "events", ["start_date", "start_time"], :name => "idx_events_start"

  create_table "events_tags", :force => true do |t|
    t.integer  "category_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events_tags", ["category_id"], :name => "index_events_tags_on_category_id"
  add_index "events_tags", ["event_id"], :name => "index_events_tags_on_event_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
