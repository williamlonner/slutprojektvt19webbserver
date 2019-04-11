def database()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    db
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
        password = db.execute('SELECT password, cCostumerId FROM cCostumers WHERE username = ?', params['uName'])
        hashed_pass = BCrypt::Password.new(password[0][0])
        if hashed_pass == params['pWord']
            session[:id] = password[0]['cCostumerId']
            redirect('/cloggedin')
        else
            redirect('/clogin')
        end
    elsif params['uNameC'] && params['pWordC'] != nil
        password = db.execute('SELECT password, bCostumerId FROM bCostumers WHERE username = ?', params['uNameC'])
        hashed_pass = BCrypt::Password.new(password[0][0])
        if hashed_pass == params['pWordC']
            session[:id] = password[0]['bCostumerId']
            redirect('/')
        else
            redirect('/blogin')
        end
    end
end

def productlist(params)
    db = database()
    return db.execute('SELECT name, price FROM products')
end

def productinfo(params) 
    db = database()
    result = db.execute('SELECT * FROM products WHERE name=?',params['productName'])
    return result.first
end

def oneproduct(id) 
    db = database()
    result = db.execute('SELECT * FROM products WHERE productId=?',id)
    return result.first
end

def logout(params) 
    db = database()
    session.destroy
    redirect('/')
end

def addBasket(params)
    db = database()
    if params['amount'] != nil
        db.execute("INSERT INTO basket VALUES (?, ?, 0, ?)",session[:productId], params['amount'], session[:id])
        redirect('/basket')
    else
        redirect('/products')
    end
end