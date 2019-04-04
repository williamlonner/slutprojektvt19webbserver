def register(params) do
    db = SQLite3::Database.new("database/users.db")
    db.results_as_hash = true
    
    hashed_pass = BCrypt::Password.create(params['newPassWord'])
    db.execute('INSERT INTO users (username, password, category) VALUES (?, ?, ?)',params["newUserName"], hashed_pass, params['newUser'])

    redirect('/')
end