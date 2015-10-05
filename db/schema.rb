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

ActiveRecord::Schema.define(version: 20150703165506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "admins", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "beta_testers", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_posts", force: true do |t|
    t.integer  "admin_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "preview_hash"
    t.boolean  "is_public",    default: false
    t.text     "description"
  end

  create_table "bookmark_lists", force: true do |t|
    t.integer "planner_id"
    t.string  "name"
  end

  add_index "bookmark_lists", ["planner_id"], name: "index_bookmark_lists_on_planner_id", using: :btree

  create_table "bookmarks", force: true do |t|
    t.integer "bookmark_list_id"
    t.integer "location_id"
  end

  add_index "bookmarks", ["bookmark_list_id"], name: "index_bookmarks_on_bookmark_list_id", using: :btree
  add_index "bookmarks", ["location_id"], name: "index_bookmarks_on_location_id", using: :btree

  create_table "claims", force: true do |t|
    t.integer "vendor_id"
    t.integer "location_id"
    t.string  "status",      default: "pending"
  end

  add_index "claims", ["location_id"], name: "index_claims_on_location_id", using: :btree
  add_index "claims", ["vendor_id"], name: "index_claims_on_vendor_id", using: :btree

  create_table "client_events", force: true do |t|
    t.integer  "vendor_id"
    t.string   "path"
    t.string   "html_id"
    t.string   "html_class"
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
    t.string   "time"
  end

  create_table "events", force: true do |t|
    t.integer  "planner_id"
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "full_address"
    t.string   "country_code"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "confirmed",                 default: false
    t.boolean  "tentative",                 default: false
    t.text     "hidden_contact_info"
    t.string   "contracted_by"
    t.boolean  "service_request_submitted", default: false
  end

  add_index "events", ["planner_id"], name: "index_events_on_planner_id", using: :btree

  create_table "events_locations", id: false, force: true do |t|
    t.integer "event_id"
    t.integer "location_id"
  end

  create_table "events_services", id: false, force: true do |t|
    t.integer "event_id"
    t.integer "service_id"
  end

  create_table "inquiries", force: true do |t|
    t.string   "type"
    t.string   "status",             default: "open"
    t.integer  "vendor_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "planner_id"
    t.uuid     "uuid",               default: "uuid_generate_v4()"
    t.boolean  "is_service_request", default: false
    t.integer  "staffer_id"
  end

  add_index "inquiries", ["planner_id"], name: "index_inquiries_on_planner_id", using: :btree
  add_index "inquiries", ["staffer_id"], name: "index_inquiries_on_staffer_id", using: :btree
  add_index "inquiries", ["vendor_id"], name: "index_inquiries_on_vendor_id", using: :btree

  create_table "inquiry_messages", force: true do |t|
    t.text     "content"
    t.integer  "inquiry_id"
    t.integer  "vendor_id"
    t.integer  "admin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "planner_id"
    t.boolean  "read",                         default: false
    t.string   "file_attachment_file_name"
    t.string   "file_attachment_content_type"
    t.integer  "file_attachment_file_size"
    t.datetime "file_attachment_updated_at"
    t.integer  "staffer_id"
  end

  add_index "inquiry_messages", ["admin_id"], name: "index_inquiry_messages_on_admin_id", using: :btree
  add_index "inquiry_messages", ["inquiry_id"], name: "index_inquiry_messages_on_inquiry_id", using: :btree
  add_index "inquiry_messages", ["planner_id"], name: "index_inquiry_messages_on_planner_id", using: :btree
  add_index "inquiry_messages", ["staffer_id"], name: "index_inquiry_messages_on_staffer_id", using: :btree
  add_index "inquiry_messages", ["vendor_id"], name: "index_inquiry_messages_on_vendor_id", using: :btree

  create_table "launch_subscribers", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_number"
    t.string   "full_address"
    t.integer  "vendor_id"
    t.string   "status",       default: "deactivated"
    t.string   "website"
    t.string   "email"
    t.integer  "admin_id"
    t.string   "country_code"
    t.boolean  "confirmed",    default: false
  end

  add_index "locations", ["admin_id"], name: "index_locations_on_admin_id", using: :btree

  create_table "locations_services", id: false, force: true do |t|
    t.integer "location_id"
    t.integer "service_id"
  end

  add_index "locations_services", ["location_id", "service_id"], name: "index_locations_services_on_location_id_and_service_id", unique: true, using: :btree
  add_index "locations_services", ["service_id"], name: "index_locations_services_on_service_id", using: :btree

  create_table "negotiation_messages", force: true do |t|
    t.integer  "negotiation_id"
    t.text     "content"
    t.string   "action"
    t.integer  "planner_id"
    t.integer  "vendor_id"
    t.integer  "bid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",                         default: false
    t.string   "file_attachment_file_name"
    t.string   "file_attachment_content_type"
    t.integer  "file_attachment_file_size"
    t.datetime "file_attachment_updated_at"
  end

  add_index "negotiation_messages", ["negotiation_id"], name: "index_negotiation_messages_on_negotiation_id", using: :btree
  add_index "negotiation_messages", ["planner_id"], name: "index_negotiation_messages_on_planner_id", using: :btree
  add_index "negotiation_messages", ["vendor_id"], name: "index_negotiation_messages_on_vendor_id", using: :btree

  create_table "negotiations", force: true do |t|
    t.integer  "vendor_rfp_id"
    t.string   "status",        default: "open"
    t.integer  "planner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",          default: "uuid_generate_v4()"
  end

  add_index "negotiations", ["planner_id"], name: "index_negotiations_on_planner_id", using: :btree
  add_index "negotiations", ["vendor_rfp_id"], name: "index_negotiations_on_vendor_rfp_id", using: :btree

  create_table "notifications", force: true do |t|
    t.boolean  "read",       default: false
    t.string   "title"
    t.text     "message"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority"
    t.integer  "vendor_id"
    t.integer  "planner_id"
    t.integer  "staffer_id"
  end

  add_index "notifications", ["planner_id"], name: "index_notifications_on_planner_id", using: :btree
  add_index "notifications", ["vendor_id"], name: "index_notifications_on_vendor_id", using: :btree

  create_table "planners", force: true do |t|
    t.string   "email",                     default: "",          null: false
    t.string   "encrypted_password",        default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "time_zone"
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
    t.string   "stripe_id"
    t.boolean  "subscribed"
    t.string   "sign_up_step",              default: "card_plan"
    t.string   "subscription_id"
    t.string   "billing_status",            default: "active"
    t.boolean  "accepted_terms_of_service"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.string   "country_code"
    t.string   "primary_phone_number"
    t.string   "primary_email"
    t.string   "primary_website"
    t.text     "hidden_hints"
    t.string   "cancelation_date"
  end

  add_index "planners", ["email"], name: "index_planners_on_email", unique: true, using: :btree
  add_index "planners", ["reset_password_token"], name: "index_planners_on_reset_password_token", unique: true, using: :btree

  create_table "seed_uploads", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_id"
    t.text     "sql_for_insert"
  end

  add_index "seed_uploads", ["admin_id"], name: "index_seed_uploads_on_admin_id", using: :btree

  create_table "service_rfps", force: true do |t|
    t.integer "event_id"
    t.integer "budget"
    t.text    "notes"
    t.integer "service_id"
    t.text    "hidden_locations"
    t.integer "radius"
    t.boolean "outside_arrangements", default: false
  end

  add_index "service_rfps", ["event_id"], name: "index_service_rfps_on_event_id", using: :btree
  add_index "service_rfps", ["service_id"], name: "index_service_rfps_on_service_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "settings", force: true do |t|
    t.integer  "planner_id"
    t.integer  "vendor_id"
    t.integer  "email_frequency", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "staffer_id"
  end

  add_index "settings", ["planner_id"], name: "index_settings_on_planner_id", using: :btree
  add_index "settings", ["staffer_id"], name: "index_settings_on_staffer_id", using: :btree
  add_index "settings", ["vendor_id"], name: "index_settings_on_vendor_id", using: :btree

  create_table "staffers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                     default: "",          null: false
    t.string   "encrypted_password",        default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "stripe_id"
    t.string   "billing_status",            default: "active"
    t.string   "name"
    t.string   "country_code"
    t.text     "description"
    t.boolean  "subscribed",                default: false,       null: false
    t.string   "time_zone"
    t.string   "primary_phone_number"
    t.string   "primary_email"
    t.string   "primary_website"
    t.string   "sign_up_step",              default: "card_plan", null: false
    t.string   "cancelation_date"
    t.string   "subscription_id"
    t.boolean  "accepted_terms_of_service"
    t.text     "hidden_hints"
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "full_address"
    t.string   "resume_file_name"
    t.string   "resume_content_type"
    t.integer  "resume_file_size"
    t.datetime "resume_updated_at"
  end

  add_index "staffers", ["email"], name: "index_staffers_on_email", unique: true, using: :btree
  add_index "staffers", ["reset_password_token"], name: "index_staffers_on_reset_password_token", unique: true, using: :btree

  create_table "vendor_rfps", force: true do |t|
    t.integer "service_rfp_id"
    t.integer "location_id"
  end

  add_index "vendor_rfps", ["location_id"], name: "index_vendor_rfps_on_location_id", using: :btree
  add_index "vendor_rfps", ["service_rfp_id"], name: "index_vendor_rfps_on_service_rfp_id", using: :btree

  create_table "vendors", force: true do |t|
    t.string   "email",                        default: "",          null: false
    t.string   "encrypted_password",           default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_id"
    t.string   "billing_status",               default: "active"
    t.string   "name"
    t.string   "country_code"
    t.text     "description"
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
    t.boolean  "subscribed",                   default: false,       null: false
    t.string   "time_zone"
    t.string   "primary_phone_number"
    t.string   "primary_email"
    t.string   "primary_website"
    t.string   "sign_up_step",                 default: "card_plan", null: false
    t.text     "active_location_ids"
    t.string   "cancelation_date"
    t.string   "subscription_id"
    t.string   "previous_active_location_ids"
    t.boolean  "accepted_terms_of_service"
    t.text     "hidden_hints"
  end

  add_index "vendors", ["email"], name: "index_vendors_on_email", unique: true, using: :btree
  add_index "vendors", ["reset_password_token"], name: "index_vendors_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
