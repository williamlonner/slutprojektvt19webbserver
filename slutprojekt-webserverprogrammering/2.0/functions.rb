def sqlite3(db) do
    db = SQLite3::Database.new(db)
    db.results_as_hash = true
end

def who(params) do
    params = params

    if params['cWho'] == "Yourself"
        redirect('/cRegisterPrivate')
    else
        redirect('/cRegisterCompany')
    end
end