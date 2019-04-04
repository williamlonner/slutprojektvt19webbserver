require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require 'date'

enable :sessions

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/companylogin') do
    slim(:companylogin)
end

get('/register') do
    slim(:register)
end

get('/bosssite') do
    slim(:bosssite)
end

get('/costumersite') do
    slim(:costumersite)
end

get('/purschased') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    bought = db.execute('SELECT * FROM purschased')

    slim(:purschased, locals:{history: bought})
end

get('/products') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    prod_name1 = db.execute('SELECT name FROM products WHERE prodId = "product1"')
    prod_name2 = db.execute('SELECT name FROM products WHERE prodId = "product2"')

    slim(:products, locals:{product1: prod_name1, product2: prod_name2})
end

post('/product1') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    product = db.execute('SELECT * FROM products WHERE prodId = "product1"')
    amount = product[0]['amount']
    price = product[0]['price']
    boughtAmount = params['product1'].to_i
    total = 0

    if params['product1'] != nil
        amount = amount - (boughtAmount)
        db.execute('UPDATE products SET amount = ? WHERE prodId = "product1"',amount)
        total = price * boughtAmount
        db.execute('INSERT INTO purschased (prodId, amount, price, left, costumerId) VALUES ("product1", ?, ?, ?, ?)',boughtAmount,total,amount,session[:Id])
        redirect('/products')
    else
        redirect('/costumersite')
    end
    
    redirect('/products')
end

post('/new_user') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    hashed_pass = BCrypt::Password.create(params['newPassWord'])

    if BCrypt::Password.new(hashed_pass) == params['newPassWord2']
        db.execute('INSERT INTO users (username, password, category) VALUES (?, ?, ?)',params["newUserName"], hashed_pass, params['newUser'])
        redirect('/')
    else
        redirect('/register')
    end
end

post('/loggedin') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    user_pass = db.execute('SELECT password, id, category FROM users WHERE username = ?',params["userName"])
    hashed_pass = BCrypt::Password.new(user_pass[0]['password'])
    if hashed_pass == params['passWord']
        if user_pass[0]['category'] == "Boss"
            session[:Id] = user_pass[0]["id"].to_s
            redirect('/bosssite')
        else
            redirect('costumersite')
        end
    else
        redirect('/login')
    end
    
end

