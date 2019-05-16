def database()
    db = SQLite3::Database.new("database/db.db")
    db.results_as_hash = true
    db
end

def login(params) 
    db = database()
    if params['Uname'] != nil && params['Pword'] != nil
        password = db.execute('SELECT Password FROM users WHERE Username =?',params['Uname'].to_s)
        if password != [] && password != nil
            hashed_pass = BCrypt::Password.new(password[0]['Password'].to_s)
        else
           return false
        end
        if hashed_pass == params['Pword']
            return db.execute('SELECT Id FROM users WHERE Username =?', params['Uname'].to_s).first
        end
    else
        return false
    end
end

def signUp(params)
    db = database()
    if params['nUname'] != nil && params['nPword'] != nil
        hashed_pass = BCrypt::Password.create(params['nPword'].to_s)
        return db.execute('INSERT INTO users (Username, Password) VALUES (?, ?)',params['nUname'].to_s,hashed_pass)
    else
        return false
    end
end

def getUserInfo(params)
    db = database()
    result = db.execute('SELECT * FROM users WHERE Id =?',params['id'])
    return result.first
end

def addEvent(params, userid)
    db = database()
    date = (params['nDay'] + " " + params['nMonth'])
    if params['nComment'] != nil
        return db.execute("INSERT INTO events (UserId, Header, Place, EventDate, Comment, MaxAmount) VALUES (?, ?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date,params['nComment'], params['maxAmount'])
    else
        return db.execute("INSERT INTO events (UserId, Header, Place, EventDate, MaxAmount) VALUES (?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date, params['maxAmount'])
    end
end

def getEvent(params)
    db = database()
    return db.execute("SELECT * FROM events ORDER BY EventId DESC")
end

def getUserEvent(id)
    db = database()
    return db.execute("SELECT * FROM events WHERE UserId = ? ORDER BY EventId DESC",id)
end

def deleteEvent(params, session)
    db = database()
    if session['id'] != nil
        db.execute("DELETE FROM coming WHERE EventId = ? AND UserId = ?",params['eventDelete'],session['id'])
        return db.execute("DELETE FROM events WHERE EventId = ?",params['eventDelete'])
    else
        return false
    end
end

def redirectLoggedIn()
    if session['id'] != nil
        return true 
    else
        return false 
    end
end

def joinEvent(params, session)
    db = database()
    if params['comingEvent'] != nil
        db.execute("INSERT INTO coming (EventId, UserId) VALUES (?, ?)",params['comingEvent'],session['id'])
        count = db.execute("SELECT Coming FROM events WHERE EventId = ?",params['comingEvent']).first
    else
        return false
    end

    if count['Coming'] == nil
        new_count = 1
    else
        new_count = count['Coming'] + 1
    end
    db.execute("UPDATE events SET coming = ? WHERE EventId = ?",new_count,params['comingEvent'])
    return db.execute("SELECT UserId FROM coming WHERE EventId = ?",params['comingEvent'])
end

def joinedOrNot(params)
    db = database()
    joined = false
    comingInfo = db.execute("SELECT UserId FROM coming")
    comingInfo.each do |id|
        if id['UserId'] == params['id'].to_i
            joined = true
            break
        end
    end
    return joined
end

def unJoinEvent(params, session)
    db = database()
    db.execute("DELETE FROM coming WHERE UserId = ? AND EventId = ?",session['id'],params['notComingEvent'])
    count = db.execute("SELECT Coming FROM events WHERE EventId = ?",params['notComingEvent']).first
    if count['Coming'] == nil
        new_count = count['Coming'] - 1
    end
    return db.execute("UPDATE events SET coming = ? WHERE EventId = ?",new_count,params['notComingEvent'])
end

def getComingInfo(params)
    db = database()
    return db.execute("SELECT * FROM coming")
end

def getComments(session)
    db = database()
    getComment = db.execute("SELECT comment FROM comments WHERE EventId = ?",session['eventId'])
    if session['eventId'] != nil
        if getComment == []
            userId = db.execute("SELECT UserId FROM events WHERE EventId = ?",session['eventId']).first
            return db.execute("SELECT Username FROM users WHERE Id = ?",userId['UserId'])
        else
            comments = db.execute("SELECT * FROM comments INNER JOIN users ON users.Id = comments.UserId WHERE EventId = ? ORDER BY CommentId DESC",session['eventId'])
            userId = db.execute("SELECT UserId FROM events WHERE EventId = ?",session['eventId']).first
            userName = db.execute("SELECT Username FROM users WHERE Id = ?",userId['UserId'])
            return comments, userName
        end
    else
        return false
    end
end

def writeComment(params, session)
    db = database()
    if params['commentContent'] != nil && params['commentContent'] != ""
        if session['id'] != nil || session['eventId'] != nil
            return db.execute("INSERT INTO comments (EventId, UserId, Comment) VALUES (?, ?, ?)",session['eventId'],session['id'],params['commentContent'])
        else
            return false
        end
    else
        return false
    end 
end

# def error(function)
#     db = database()
#     if function == nil
#         return false
#     else
#         return true
#     end
# end

# def errorRoute(error, route)
#     db = database()
#     if error == false
#         return redirect('/error')
#     else
#         return redirect("#{route}")
#     end
# end