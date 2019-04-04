def database()
    return SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
end

def signUp(params)
    db = database()
    if params['cPassPn1'] != nil
        if params['cPassPn1'] == params['cPassPn2']
            hashed_pass = BCrypt::Password.create(params['cPassPn1'])
            db.execute('INSERT INTO cCostumers (firstname, lastname, username, password, mail, phoneNr, adress, category) VALUES (?, ?, ?, ?, ?, ?, ?, "private")',params['cfNamePn'], params['clNamePn'], params["cUnamePn"], hashed_pass, params['cMailPn'], params['cPhoneNrPn'], params['cAdressPn'])
            redirect('/')
        else
            redirect('/csignup')
        end
    elsif params['cPassCn1'] != nil
        if params['cPassCn1'] == params['cPassCn2']
            hashed_pass = BCrypt::Password.create(params['cPassCn1'])
            db.execute('INSERT INTO bCostumers (name, username, password, mail, phoneNr, adress, category) VALUES (?, ?, ?, ?, ?, ?, "company")',params['cNameCn'], params["cUnameCn"], hashed_pass, params['cMailCn'], params['cPhoneNrCn'], params['cAdressCn'])
            redirect('/')
        else
            redirect('/csignup')
        end
    end      
end

def login(params)
    db = database()
    if (params['uName'] && params['pWord']) != nil
        password = db.execute('SELECT password FROM cCostumers WHERE username = ?', params['uName'])
        hashed_pass = BCrypt::Password.new(password[0][0])
        if hashed_pass == params['pWord']
            redirect('/')
        else
            redirect('/clogin')
        end
    elsif params['uNameC'] && params['pWordC'] != nil
        password = db.execute('SELECT password FROM bCostumers WHERE username = ?', params['uNameC'])
        hashed_pass = BCrypt::Password.new(password[0][0])
        if hashed_pass == params['pWordC']
            redirect('/')
        else
            redirect('/blogin')
        end
    end
end