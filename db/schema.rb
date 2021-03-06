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

ActiveRecord::Schema.define(version: 20190227190222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accessions", force: true do |t|
    t.string   "accession_num"
    t.integer  "collection_id"
    t.text     "accession_note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "accession_state"
    t.integer  "created_by"
    t.integer  "modified_by"
  end

  create_table "collections", force: true do |t|
    t.string   "title"
    t.string   "collection_code"
    t.string   "partner_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "modified_by"
  end

  create_table "mlog_entries", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "accession_num"
    t.integer  "media_id"
    t.string   "mediatype"
    t.string   "manufacturer"
    t.string   "manufacturer_serial"
    t.text     "label_text"
    t.text     "media_note"
    t.string   "photo_url"
    t.string   "image_filename"
    t.string   "interface"
    t.string   "imaging_software"
    t.string   "hdd_interface"
    t.string   "imaging_success"
    t.string   "interpretation_success"
    t.string   "imaged_by"
    t.text     "imaging_note"
    t.string   "image_format"
    t.string   "encoding_scheme"
    t.string   "partition_table_format"
    t.integer  "number_of_partitions"
    t.string   "filesystem"
    t.boolean  "has_dfxml"
    t.boolean  "has_ftk_csv"
    t.integer  "image_size_bytes",         limit: 8
    t.string   "md5_checksum"
    t.string   "sha1_checksum"
    t.datetime "date_imaged"
    t.datetime "date_ftk_loaded"
    t.datetime "date_metadata_extracted"
    t.datetime "date_photographed"
    t.datetime "date_qc"
    t.datetime "date_packaged"
    t.datetime "date_transferred"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_image_segments"
    t.string   "ref_id"
    t.boolean  "has_mactime_csv"
    t.integer  "box_number"
    t.string   "stock_size"
    t.integer  "sip_id"
    t.string   "original_id"
    t.string   "disposition_note"
    t.string   "stock_unit"
    t.float    "stock_size_num"
    t.integer  "created_by"
    t.integer  "modified_by"
    t.integer  "collection_id"
    t.integer  "accession_id"
    t.boolean  "is_transferred"
    t.boolean  "is_refreshed"
    t.integer  "session_count"
    t.string   "content_type"
    t.string   "structure"
    t.string   "file_systems",                       default: [], array: true
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.datetime "deleted_at"
    t.boolean  "is_active"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
