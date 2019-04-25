def database()
    db = SQLite3::Database.new("database/db.db")
    db.results_as_hash = true
    db
end

def login(params) 
    db = database()
    if params['Uname'] != nil && params['Pword'] != nil
        password = db.execute('SELECT password FROM users WHERE username =?',params['Uname'].to_s)
        hashed_pass = BCrypt::Password.new(password[0]['password'].to_s)
        if hashed_pass == params['Pword']
            return db.execute('SELECT Id FROM users WHERE username =?', params['Uname'].to_s).first
        end
    else
        redirect('/')
    end
end

def signUp(params)
    db = database()
    if params['nUname'] != nil && params['nPword'] != nil
        hashed_pass = BCrypt::Password.create(params['nPword'].to_s)
        return db.execute('INSERT INTO users (username, password) VALUES (?, ?)',params['nUname'].to_s,hashed_pass)
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
        return db.execute("INSERT INTO events (userId, header, place, date, comment, maxAmount) VALUES (?, ?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date,params['nComment'], params['maxAmount'])
    else
        return db.execute("INSERT INTO events (userId, header, place, date, maxAmount) VALUES (?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date, params['maxAmount'])
    end
end

def getEvent(params)
    db = database()
    return db.execute("SELECT * FROM events ORDER BY postId DESC")
end

def getUserEvent(id)
    db = database()
    return db.execute("SELECT * FROM events WHERE userId = ? ORDER BY postId DESC",id)
end

def deleteEvent(params)
    db = database()
    db.execute("DELETE FROM comming WHERE postId = ?",params['eventDelete'])
    return db.execute("DELETE FROM events WHERE postId = ?",params['eventDelete'])
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
    userId = db.execute("SELECT userId FROM events WHERE postId = ?",params['commingEvent']).first
    db.execute("INSERT INTO comming (postId, userId) VALUES (?, ?)",params['commingEvent'],userId['userId'])
    return params['commingEvent']
end

def countingJoined(session)
    db = database()
    result = joinEvent(params)[0].to_i
    if session[result] == nil
        session[result] = 1
    else    
        session[result] += 1
    end
    return db.execute("UPDATE events SET comming = ? WHERE postId = ?",session[result],result)
end

def getCommingInfo(params)
    db = database()
    return db.execute("SELECT userId FROM comming")
end