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
  name:"Caio",
  lastname:"Mendes",
  phone: "453526-3939",
  cnpj:"26.958.914/0001-53",
  nameCompany:"Lex Coporate",
  street: "Foz do Iguaçu",
  city: "Foz do Iguaçu",
  state: "Paraná",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'admin',
  complement: "Casa 27",
  password: 'admin123',
  password_confirmation: 'admin123'
)

# Crie um usuário regular
user = User.create!(
  email: 'user@user.com',
  name:"Caio",
  lastname:"Mendes",
  phone: "453526-3939",
  cnpj:"26.958.914/0001-53",
  nameCompany:"Lex Coporate",
  street: "Foz do Iguaçu",
  city: "Foz do Iguaçu",
  state: "Paraná",
  zip_code: "85859-490",
  neighborhood: "Brazil",
  finance: "adimplente",
  role: 'admin',
  complement: "Casa 27",
  password: 'user123',
  password_confirmation: 'user123'
)


puts 'SEED finalizada'