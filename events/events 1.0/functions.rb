def database()
    db = SQLite3::Database.new("database/db.db")
    db.results_as_hash = true
    db
end

def login(params) 
    db = database()
    if params['Uname'] != nil && params['Pword'] != nil
        password = db.execute('SELECT Password FROM users WHERE Username =?',params['Uname'].to_s)
        hashed_pass = BCrypt::Password.new(password[0]['Password'].to_s)
        if hashed_pass == params['Pword']
            return db.execute('SELECT Id FROM users WHERE Username =?', params['Uname'].to_s).first
        end
    else
        redirect('/')
    end
end

def signUp(params)
    db = database()
    if params['nUname'] != nil && params['nPword'] != nil
        hashed_pass = BCrypt::Password.create(params['nPword'].to_s)
        return db.execute('INSERT INTO users (Username, Password) VALUES (?, ?)',params['nUname'].to_s,hashed_pass)
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

def deleteEvent(params)
    db = database()
    db.execute("DELETE FROM coming WHERE EventId = ?",params['eventDelete'])
    return db.execute("DELETE FROM events WHERE EventId = ?",params['eventDelete'])
end

def redirectLoggedIn()
    if session[:id] != nil
        redirect("/loggedIn/#{session[:id]}")
    else
        redirect('/')
    end
end

def joinEvent(params)
    db = database()
    userId = db.execute("SELECT UserId FROM events WHERE EventId = ?",params['comingEvent']).first
    db.execute("INSERT INTO coming (EventId, UserId) VALUES (?, ?)",params['comingEvent'],userId['UserId'])
    return params['comingEvent']
end

def countingJoined(session)
    db = database()
    result = joinEvent(params)[0].to_i
    if session[result] == nil
        session[result] = 1
    else    
        session[result] += 1
    end
    return db.execute("UPDATE events SET coming = ? WHERE EventId = ?",session[result],result)
end

def getComingInfo(params)
    db = database()
    return db.execute("SELECT UserId FROM coming")
end

def getComments(session)
    db = database()
    return db.execute("SELECT * FROM comments WHERE EventId = ?", session['eventId'])
end

def writeComment(params, session)
    db = database()
    if params['commentContent'] != nil 
        db.execute("INSERT INTO comments (EventId, UserId, Comment) VALUES (?, ?, ?)",session['eventId'],session['id'],params['commentContent'])
    else
        db.execute("INSERT INTO comments (EventId, UserId, Comment) VALUES (?, ?, '')",session['eventId'],session['id'])
    end 
    userId = db.execute("SELECT Username FROM users WHERE Id = ?",session['id']).first
    return userId
end