module Model 

    # Creates a variable for the database that is being used
    #
    def database()
        db = SQLite3::Database.new("database/db.db")
        db.results_as_hash = true
        db
    end

    # Compare the data the user put in when trying to login with the existing data
    #
    # @param [Hash] params from data
    # @option [String] Uname, The users username
    # @option [String] Pword, The users password
    # 
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    #   * :user_id [Integer] the logged in users ID
    def login(params) 
        db = database()
        if params['Uname'] != "" && params['Pword'] != ""
            info = db.execute('SELECT Id, Password FROM users WHERE Username =?',params['Uname'].to_s)
            if info[0]['Password'] != [] && info != nil
                hashed_pass = BCrypt::Password.new(info[0]['Password'].to_s)
            else
                return {
                    error: true,
                    message: "Something wrong happend with your login, please try again:)"
                }
            end
            if hashed_pass == params['Pword']
                return {
                    error: false,
                    user_id: info[0]['Id']
                }
            else
                return {
                    error: true,
                    message: "Something wrong happend with your login, please try again:)"
                }
            end
        else
            return {
                error: true,
                message: "Something wrong happend with your login, please try again:)"
            }
        end
    end

    # Creates an account for a new user
    #
    # @param [Hash] params from data
    # @option [String] nPword, The new users password
    # @option [String] nUname, The new users username
    #
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    def signUp(params)
        db = database()
        if params['nUname'] != nil && params['nPword'] != nil
            if params['nUname'] != "" && params['nPword'] != ""
                hashed_pass = BCrypt::Password.create(params['nPword'].to_s)
                db.execute('INSERT INTO users (Username, Password) VALUES (?, ?)',params['nUname'].to_s,hashed_pass)
                return {
                    error: false
                }
            else
                return {
                    error: true,
                    message: "Something wrong happend with you signing up, try again"
                }
            end
        else
            return {
                error: true,
                message: "Something wrong happend with you signing up, try again"
            }
        end
    end

    # Gets the information from a specific user
    # 
    # @param [Hash] params from data
    # @option [Integer] id, the users ID
    #
    # @return [Array] containing all information from a specific user
    def getUserInfo(params)
        db = database()
        result = db.execute('SELECT * FROM users WHERE Id =?',params['id'])
        return result.first
    end

    # Adds a new event to the site
    #
    # @param [Integer] userid, the users specific ID
    # @param [Hash] params from data
    # @option [String] nEname, The name of the event
    # @option [String] nWhere, The name of where the event take place
    # @option [String] nDay, The day when the event is
    # @option [String] nMonth, The month the event take place
    # @option [String] maxAmount, The max amount of people that can come
    # @option [String] nComment, Extra information about the event
    #
    # @return SQLite3 action inserting data into database
    def addEvent(params, userid)
        db = database()
        date = (params['nDay'] + " " + params['nMonth'])
        if params['nComment'] != nil
            return db.execute("INSERT INTO events (UserId, Header, Place, EventDate, Comment, MaxAmount) VALUES (?, ?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date,params['nComment'], params['maxAmount'])
        else
            return db.execute("INSERT INTO events (UserId, Header, Place, EventDate, MaxAmount) VALUES (?, ?, ?, ?, ?)",userid,params['nEname'],params['nWhere'],date, params['maxAmount'])
        end
    end

    # Get the information about an event
    #
    # @param [Hash] params from data
    #
    # @return [Hash] all the data about a event
    def getEvent(params)
        db = database()
        return db.execute("SELECT * FROM events ORDER BY EventId DESC")
    end

    # Gets all the information about an event that the id matches
    #
    # @param [Integer] id, The users specific ID
    #
    # @return [Hash] all the data about a event
    def getUserEvent(id)
        db = database()
        return db.execute("SELECT * FROM events WHERE UserId = ? ORDER BY EventId DESC",id)
    end

    # Deletes a specific event made by a user
    #
    # @param [Hash] sessions
    # @param [Hash] params from data
    # @option [String] eventDelete, The ID of the event that is being deleted
    # 
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    def deleteEvent(params, session)
        db = database()
        if session['id'] != nil
            db.execute("DELETE FROM coming WHERE EventId = ? AND UserId = ?",params['eventDelete'],session['id'])
            db.execute("DELETE FROM events WHERE EventId = ?",params['eventDelete'])
            return {
                error: false
            }
        else
            return {
                error: true,
                message: "Some trouble occured while trying to delete this"
            }
        end
    end

    # Sees if a user is logged in or not
    #
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    def redirectLoggedIn()
        if session['id'] != nil
            return {
                error: false
            } 
        else
            return {
                error: true,
                message: "You haven't logged in"
            }
        end
    end

    # Count and add a users as coming to a specific event
    #
    # @param [Hash] sessions
    # @param [Hash] params from data
    # @option [String] comingEvent, The specific events ID
    #
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    def joinEvent(params, session)
        db = database()
        if session['id'] != nil
            if params['comingEvent'] != nil 
                db.execute("INSERT INTO coming (EventId, UserId) VALUES (?, ?)",params['comingEvent'],session['id'])
                count = db.execute("SELECT Coming FROM events WHERE EventId = ?",params['comingEvent']).first
            else
                return {
                    error: true,
                    message: "You were unable to join due to an error"
                }
            end
        else
            return {
                error: true,
                message: "You were unable to join due to an error"
            }
        end

        if count['Coming'] == nil
            new_count = 1
        else
            new_count = count['Coming'] + 1
        end
        db.execute("UPDATE events SET coming = ? WHERE EventId = ?",new_count,params['comingEvent'])
        user_id = db.execute("SELECT UserId FROM coming WHERE EventId = ?",params['comingEvent'])
        return {
            error: false,
            user_id: user_id
        }
    end

    # Sees if a person have joined to a specific event or not
    # 
    # @param [Hash] params from data
    # @option [Integer] id, The specific users ID
    #
    # @return [boolean] wheter the user have joined or not
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

    # Removes a user from coming to a specific event
    #
    # @param [Hash] sessions
    # @param [Hash] params from data
    # @option [String] notComingEvent, The ID of the event
    #
    # @return SQLite3 action updating or selecting data
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

    # Get all the comments linked to a specific event
    #
    # @param [Hash] sessions
    #
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    #   * :user_name [String] the logged in users name
    #   * :comments [Hash] all information about the comments
    def getComments(session)
        db = database()
        getComment = db.execute("SELECT comment FROM comments WHERE EventId = ?",session['eventId'])
        if session['eventId'] != nil
            if getComment == []
                userId = db.execute("SELECT UserId FROM events WHERE EventId = ?",session['eventId']).first
                username = db.execute("SELECT Username FROM users WHERE Id = ?",userId['UserId'])
                return {
                    error: false,
                    user_name: username
                }
            else
                comments = db.execute("SELECT * FROM comments INNER JOIN users ON users.Id = comments.UserId WHERE EventId = ? ORDER BY CommentId DESC",session['eventId'])
                userId = db.execute("SELECT UserId FROM events WHERE EventId = ?",session['eventId']).first
                userName = db.execute("SELECT Username FROM users WHERE Id = ?",userId['UserId'])
                return {
                    error: false,
                    comments: comments
                    user_name: userName
                }
            end
        else
            return {
                error: true,
                message: "An error occured while trying to load comments"
            }
        end
    end

    # Makes a new comment on a specific event
    #
    # @param [Hash] sessions
    # @param [Hash] params from data
    # @option [String] commentContent, The newly written comment
    #
    # @return [Hash] 
    #   * :error [Boolean] wheter an error occured
    #   * :message [String] the error message
    def writeComment(params, session)
        db = database()
        if params['commentContent'] != nil && params['commentContent'] != ""
            if session['id'] != nil || session['eventId'] != nil
                db.execute("INSERT INTO comments (EventId, UserId, Comment) VALUES (?, ?, ?)",session['eventId'],session['id'],params['commentContent'])
                return {
                    error: false
                }
            else
                return {
                    error: true,
                    message: "An error occured while trying to write comment"
                }
            end
        else
            return {
                error: true,
                message: "An error occured while trying to write comment"
            }
        end 
    end

end