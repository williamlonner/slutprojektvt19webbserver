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
    productlist = productlist(params)
    slim(:products, locals:{products: productlist})
end

get('/products/:productId') do
    productinfo = oneproduct(session[:productId])
    slim(:oneproduct, locals:{info: productinfo})
end

get('/cloggedin') do
    slim(:cloggedin)
end

post('/cPrivateN') do
    signUp(params)
end

get('/basket') do
    slim(:basket)
end

post('/cCompanyN') do
    signUp(params)
end

post('/loggingIn') do
    login(params)
end

post('/logout') do
    logout(params)
end

post('/products/destroyName') do
    redirect('/products')
end

post('/productName') do
    session[:productId] = productinfo(params)['productId']
    redirect("/products/#{session[:productId]}")
end

post('/products/addToBasket') do
    addBasket(params)
end