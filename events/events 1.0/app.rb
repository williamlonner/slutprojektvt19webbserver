require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require 'date'
require_relative './model.rb'

enable :sessions

# Display Landing Page
#
get('/') do
    slim(:index)
end

# Display Sign Up Page
#
get('/signUp') do
    slim(:signUp)
end

# Redirects to Landing Page
#
get('/loggedIn/') do
    redirect('/')
end

# Display Logged In Page
#
# @param [Integer] :id, The ID of the signed in user
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

# Display Edit Events page
#
# @param [Integer] :id, The ID of the signed in user
get('/loggedIn/editEvent/:id') do
    events = getUserEvent(session[:id])
    slim(:editevents, locals:{events: events})
end

# Redirects to Logged In Page or Landing Page
#
get('/loggedIn') do
    if redirectLoggedIn() == true
        redirect("/loggedIn/#{session[:id]}")
    else
        redirect('/')
    end
end

# Display Comments Page for specific Event or Redirects to Logged In Page
# 
get('/loggedIn/comments/:eventId') do
    comments = getComments(session)
    if comments != false
        slim(:comments, locals:{comments: comments})
    else
        redirect("/loggedIn/#{session[:id]}")
    end
end

# Display Error Page
#
get('/error') do
    slim(:error)
end

# Redirects to Logged In Page if the login parameters are correct
#
# @param [String] Uname, The username of the user trying to log in
# @param [String] Pword, The password of the user trying to log in
#
# @see Model#login
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

# Redirects to Landing Page after Signing Up
#
# @param [String] nUname, The new username of the new user signing up
# @param [String] nPword, The new password of the new user signing up
#
# @see Model#signUp
post('/signingUp') do
    signUp = signUp(params)
    redirect('/')
end

# Redirects to Landing Page after making session of the logged in user to nil
#
post('/loggedIn/loggingOut') do
    session[:id] = nil
    redirect('/')
end

# Adds new events to the site and redirects to logged in page
#
# @param [String] nEname, The event header
# @param [String] nWhere, Where the event takes place
# @param [String] nDay, The date of the day it takes place
# @param [Integer] maxAmount, The max amount of people that can come
# @param [String] nComment, The extra info about the event
# 
# @see Model#addEvent
post('/loggedIn/createEvent') do
    addEvent(params, session[:id])
    redirect("/loggedIn/#{session[:id]}")
end

# Redirects to the event page refered to the users ID
#
post('/loggedIn/editEvent') do
    redirect("/loggedIn/editEvent/#{session[:id]}")
end

# Deletes a specific event owned by a specific user
#
# @param [Integer] EventId, The ID of a specific event
#
# @see Model#deleteEvent
post('/loggedIn/editEvent/deleteEvent') do
    if deleteEvent(params, session) != false
        redirect("/loggedIn/editEvent/#{session[:id]}")
    else
        redirect('/error')
    end
end

# Count the people who join different events
#
# @param [Integer] EventId, The ID of a specific event
#
# @see Model#joinEvent
post('/loggedIn/joiningEvent') do
    if joinEvent(params, session) == false
        redirect('/error')
    else
        redirect("/loggedIn/#{session[:id]}")
    end
end

# Redirects to the specific events commentsection
#
# @param [Integer] EventId, The ID of a specific event
post('/loggedIn/comments') do
    session[:eventId] = params['readComments']
    redirect("/loggedIn/comments/#{session[:eventId]}")
end

# Makes a new comment when the comment meet the requirements
#
# @param [String] commentContent, The commentmessage
#
# @see Model#writeComment
post('/loggedIn/comments/writeComment') do
    newComment = writeComment(params, session)
    if newComment != false
        redirect("/loggedIn/comments/#{session[:eventId]}")
    else
        redirect('/error')
    end
end

# Deletes the specific user wanting to leave a event
#
# @param [Integer] EventId, The ID of a specific event
#
# @see Model#unJoinEvent
post('/loggedIn/unJoiningEvent') do
    unJoinEvent(params, session)
    redirect("/loggedIn/#{session[:id]}")
end

# Redirects to the logged in page
#
post('/loggedIn/doneEvents?') do
    redirect("/loggedIn/#{session[:id]}")
end