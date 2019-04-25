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

get('/signUp') do
    slim(:signUp)
end

get('/loggedIn/') do
    redirect('/')
end

get('/loggedIn/:id') do
    info = getUserInfo(params)
    events = getEvent(params)
    coming = getComingInfo(params)
    slim(:loggedIn, locals:{user: info, events: events, coming: coming, session: session})
end

get('/loggedIn/editevents/:id') do
    slim(:editevents)
end

get('/loggedIn/editEvent/:id') do
    events = getUserEvent(session[:id])
    slim(:editevents, locals:{events: events})
end

get('/loggedIn') do
    redirectLoggedIn()
end

get('/loggedIn/comments/:eventId') do
    comments = getComments(session)
    writer = session[:commentWriter]
    slim(:comments, locals:{comments: comments, writer: writer})
end

post('/loggingIn') do
    session[:id] = login(params)['Id']
    redirect("/loggedIn/#{session[:id]}")
end

post('/signingUp') do
    signUp(params)
    redirect('/')
end

post('/loggedIn/loggingOut') do
    session[:id] = nil
    redirect('/')
end

post('/loggedIn/createEvent') do
    addEvent(params, session[:id])
    redirect("/loggedIn/#{session[:id]}")
end

post('/loggedIn/editEvent') do
    redirect("/loggedIn/editEvent/#{session[:id]}")
end

post('/loggedIn/editEvent/deleteEvent') do
    deleteEvent(params)
    redirect("/loggedIn/editEvent/#{session[:id]}")
end

post('/loggedIn/joiningEvent') do
    joinEvent(params)
    countingJoined(session)
    redirect("/loggedIn/#{session[:id]}")
end

post('/loggedIn/comments') do
    session[:eventId] = params['readComments']
    redirect("/loggedIn/comments/#{session[:eventId]}")
end

post('/loggedIn/comments/writeComment') do
    session[:commentWriter] = writeComment(params, session)
    redirect("/loggedIn/comments/#{session[:eventId]}")
end