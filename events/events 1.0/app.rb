require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require 'date'
require_relative './model.rb'

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
    if getUserInfo(params) != nil
        info = getUserInfo(params)
    else
        info = " "
    end
    events = getEvent(params)
    coming = getComingInfo(params)
    joined = joinedOrNot(params)
    slim(:loggedIn, locals:{user: info, events: events, coming: coming, session: session, joined: joined})
end

get('/loggedIn/editevents/:id') do
    slim(:editevents)
end

get('/loggedIn/editEvent/:id') do
    events = getUserEvent(session[:id])
    slim(:editevents, locals:{events: events})
end

get('/loggedIn') do
    if redirectLoggedIn() == true
        redirect("/loggedIn/#{session[:id]}")
    else
        redirect('/')
    end
end

get('/loggedIn/comments/:eventId') do
    comments = getComments(session)
    if comments != false
        slim(:comments, locals:{comments: comments})
    else
        redirect("/loggedIn/#{session[:id]}")
    end
end

get('/error') do
    slim(:error)
end

post('/loggingIn') do
    if login(params) != nil
        session[:id] = login(params)['Id']
        redirect("/loggedIn/#{session[:id]}")
    else
        redirect('/error')
    end

    if login(params) != false
        redirect("/loggedIn/#{session[:id]}")
    else
        redirect('/error')
    end
end

post('/signingUp') do
    signUp = signUp(params)
    ifSignUp(signUp)
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
    if deleteEvent(params, session) != false
        redirect("/loggedIn/editEvent/#{session[:id]}")
    else
        redirect('/error')
    end
end

post('/loggedIn/joiningEvent') do
    if joinEvent(params, session) == false
        redirect('/error')
    else
        redirect("/loggedIn/#{session[:id]}")
    end
end

post('/loggedIn/comments') do
    session[:eventId] = params['readComments']
    redirect("/loggedIn/comments/#{session[:eventId]}")
end

post('/loggedIn/comments/writeComment') do
    newComment = writeComment(params, session)
    if newComment != false
        redirect("/loggedIn/comments/#{session[:eventId]}")
    else
        redirect('/error')
    end
end

post('/loggedIn/unJoiningEvent') do
    unJoinEvent(params, session)
    redirect("/loggedIn/#{session[:id]}")
end

post('/loggedIn/doneEvents') do
    redirect("/loggedIn/#{session[:id]}")
end