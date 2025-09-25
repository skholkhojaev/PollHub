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

ActiveRecord::Schema.define(version: 2024_09_12_000010) do

  create_table "activities", force: :cascade do |t|
    t.integer "user_id"
    t.string "activity_type", null: false
    t.text "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "poll_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_comments_on_poll_id"
    t.index ["user_id", "poll_id", "created_at"], name: "index_comments_on_user_id_and_poll_id_and_created_at"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.integer "question_id", null: false
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "poll_invitations", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.integer "voter_id", null: false
    t.integer "invited_by_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_poll_invitations_on_invited_by_id"
    t.index ["poll_id", "voter_id"], name: "index_poll_invitations_on_poll_id_and_voter_id", unique: true
    t.index ["poll_id"], name: "index_poll_invitations_on_poll_id"
    t.index ["status"], name: "index_poll_invitations_on_status"
    t.index ["voter_id"], name: "index_poll_invitations_on_voter_id"
  end

  create_table "polls", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "status", default: "draft", null: false
    t.integer "organizer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: false
    t.index ["organizer_id"], name: "index_polls_on_organizer_id"
    t.index ["status"], name: "index_polls_on_status"
    t.index ["title"], name: "index_polls_on_title"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.string "text", null: false
    t.string "question_type", default: "single_choice", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_questions_on_poll_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "voter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "new_email"
    t.string "email_confirmation_token"
    t.datetime "email_confirmation_sent_at"
    t.integer "role_integer", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_confirmation_token"], name: "index_users_on_email_confirmation_token", unique: true
    t.index ["role_integer"], name: "index_users_on_role_integer"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "option_id", null: false
    t.integer "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_votes_on_option_id"
    t.index ["question_id"], name: "index_votes_on_question_id"
    t.index ["user_id", "option_id"], name: "index_votes_on_user_id_and_option_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

end
