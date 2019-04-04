require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require 'date'
require_relative './functions.rb'

enable :sessions

get('/') do
    slim(:index)
end

get('/clogin') do
    slim(:clogin)
end

get('/blogin') do
    slim(:blogin)
end

get('/csignup') do
    slim(:csignup)
end

get('/bsignup') do
    slim(:bsignup)
end

get('/products') do
    slim(:products)
end

post('/cPrivateN') do
    signUp(params)
end

post('/cCompanyN') do
    signUp(params)
end

post('/loggingIn') do
    login(params)
end