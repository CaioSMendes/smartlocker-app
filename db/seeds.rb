# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# Crie um usuário administrador
admin = User.create!(
  email: 'admin@admin.com',
  password: 'admin123',
  password_confirmation: 'admin123',
  role: 'admin'
)

# Criar keylockers
Keylocker.create(
  owner: Faker::Name.name,
  nameDevice: Faker::Device.model_name,
  ipAddress: Faker::Internet.ip_v4_address,
  status: ['Ativo', 'Inativo'].sample
)

# Crie um usuário regular
user = User.create!(
  email: 'user@user.com',
  password: 'user123',
  password_confirmation: 'user123',
  role: 'user'
)


puts 'SEED finalizada'
