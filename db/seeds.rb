# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

CnpaUser.find_or_create_by!(email: 'tjgriffin2@earthlink.net') do |user|
  user.password = Rails.application.secrets.user_password
  user.password_confirmation = Rails.application.secrets.user_password

end

CnpaUser.find_or_create_by!(email: 'jeff.eichinger@gmail.com') do |user|
  user.password = Rails.application.secrets.user_password
  user.password_confirmation = Rails.application.secrets.user_password

end

CnpaUser.find_or_create_by!(email: 'paul@kristoffs.com') do |user|
  user.password = Rails.application.secrets.user_password
  user.password_confirmation = Rails.application.secrets.user_password

end