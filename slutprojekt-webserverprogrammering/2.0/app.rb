require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require 'date'
# require_relative './functions.rb'

enable :sessions

get('/') do
    slim(:index)
end

get('/products') do
    slim(:products)
end

get('/cLogin') do
    slim(:cLogin)
end

get('/cRegister') do
    slim(:cRegister)
end

get('/cRegisterPrivate') do
    slim(:cRegisterPrivate)
end

get('/cRegisterCompany') do
    slim(:cRegisterCompany)
end

post('/cWho?') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true

    if params['cYourself'] == "Yourself"
        redirect('/cRegisterPrivate')
    else
        redirect('/cRegisterCompany')
    end
end