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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161025005718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "street_1",   limit: nil, default: "",      null: false
    t.string   "street_2",   limit: nil, default: "",      null: false
    t.string   "city",       limit: nil, default: "Apex",  null: false
    t.string   "state",      limit: nil, default: "NC",    null: false
    t.string   "zip_code",   limit: nil, default: "27502", null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "admins", force: true do |t|
    t.string   "email",                  limit: nil, default: "", null: false
    t.string   "encrypted_password",     limit: nil, default: "", null: false
    t.string   "reset_password_token",   limit: nil
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: nil
    t.string   "last_sign_in_ip",        limit: nil
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: nil, default: "", null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["name"], name: "index_admins_on_name", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "baptismal_certificates", force: true do |t|
    t.date     "birth_date"
    t.date     "baptismal_date"
    t.string   "church_name",               limit: nil
    t.string   "father_first",              limit: nil
    t.string   "father_last",               limit: nil
    t.string   "father_middle",             limit: nil
    t.string   "mother_first",              limit: nil
    t.string   "mother_middle",             limit: nil
    t.string   "mother_maiden",             limit: nil
    t.string   "mother_last",               limit: nil
    t.string   "certificate_filename",      limit: nil
    t.string   "certificate_content_type",  limit: nil
    t.binary   "certificate_file_contents"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "church_address_id"
  end

  add_index "baptismal_certificates", ["church_address_id"], name: "index_baptismal_certificates_on_church_address_id", using: :btree

  create_table "candidate_events", force: true do |t|
    t.date     "completed_date"
    t.boolean  "verified"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "candidate_id"
  end

  add_index "candidate_events", ["candidate_id"], name: "index_candidate_events_on_candidate_id", using: :btree

  create_table "candidate_sheets", force: true do |t|
    t.string   "first_name",      limit: nil,                         default: "",        null: false
    t.string   "last_name",       limit: nil,                         default: "",        null: false
    t.decimal  "grade",                       precision: 2, scale: 0, default: 10,        null: false
    t.string   "candidate_email", limit: nil,                         default: "",        null: false
    t.string   "parent_email_1",  limit: nil,                         default: "",        null: false
    t.string   "parent_email_2",  limit: nil,                         default: "",        null: false
    t.string   "attending",       limit: nil,                         default: "The Way", null: false
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.integer  "address_id"
  end

  add_index "candidate_sheets", ["address_id"], name: "index_candidate_sheets_on_address_id", using: :btree

  create_table "candidates", force: true do |t|
    t.string   "encrypted_password",        limit: nil, default: "",    null: false
    t.string   "reset_password_token",      limit: nil
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: nil
    t.string   "last_sign_in_ip",           limit: nil
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "account_name",              limit: nil, default: "",    null: false
    t.boolean  "signed_agreement",                      default: false, null: false
    t.boolean  "baptized_at_stmm",                      default: true,  null: false
    t.integer  "baptismal_certificate_id"
    t.integer  "sponsor_covenant_id"
    t.integer  "pick_confirmation_name_id"
    t.boolean  "sponsor_agreement",                     default: false, null: false
    t.integer  "christian_ministry_id"
    t.integer  "candidate_sheet_id"
  end

  add_index "candidates", ["account_name"], name: "index_candidates_on_account_name", unique: true, using: :btree
  add_index "candidates", ["baptismal_certificate_id"], name: "index_candidates_on_baptismal_certificate_id", using: :btree
  add_index "candidates", ["candidate_sheet_id"], name: "index_candidates_on_candidate_sheet_id", using: :btree
  add_index "candidates", ["christian_ministry_id"], name: "index_candidates_on_christian_ministry_id", using: :btree
  add_index "candidates", ["pick_confirmation_name_id"], name: "index_candidates_on_pick_confirmation_name_id", using: :btree
  add_index "candidates", ["reset_password_token"], name: "index_candidates_on_reset_password_token", unique: true, using: :btree
  add_index "candidates", ["sponsor_covenant_id"], name: "index_candidates_on_sponsor_covenant_id", using: :btree

  create_table "christian_ministries", force: true do |t|
    t.boolean  "signed",                                       default: true, null: false
    t.text     "what_service"
    t.text     "where_service"
    t.text     "when_service"
    t.text     "helped_me"
    t.string   "christian_ministry_filename",      limit: nil
    t.string   "christian_ministry_content_type",  limit: nil
    t.binary   "christian_ministry_file_contents"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  create_table "confirmation_events", force: true do |t|
    t.string   "name",             limit: nil
    t.date     "the_way_due_date"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "instructions",                 default: "", null: false
    t.date     "chs_due_date"
  end

  add_index "confirmation_events", ["name"], name: "index_confirmation_events_on_name", using: :btree

  create_table "pick_confirmation_names", force: true do |t|
    t.string   "saint_name",                           limit: nil
    t.text     "about_saint"
    t.text     "why_saint"
    t.string   "pick_confirmation_name_filename",      limit: nil
    t.string   "pick_confirmation_name_content_type",  limit: nil
    t.binary   "pick_confirmation_name_file_contents"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "sponsor_covenants", force: true do |t|
    t.string   "sponsor_name",                      limit: nil
    t.boolean  "sponsor_attends_stmm",                          default: true, null: false
    t.string   "sponsor_church",                    limit: nil
    t.string   "sponsor_elegibility_filename",      limit: nil
    t.string   "sponsor_elegibility_content_type",  limit: nil
    t.binary   "sponsor_elegibility_file_contents"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "sponsor_covenant_filename",         limit: nil
    t.string   "sponsor_covenant_content_type",     limit: nil
    t.binary   "sponsor_covenant_file_contents"
  end

  create_table "to_dos", force: true do |t|
    t.integer  "confirmation_event_id"
    t.integer  "candidate_event_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "to_dos", ["candidate_event_id"], name: "index_to_dos_on_candidate_event_id", using: :btree
  add_index "to_dos", ["confirmation_event_id"], name: "index_to_dos_on_confirmation_event_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
