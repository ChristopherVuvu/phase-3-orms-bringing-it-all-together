class Dog
    ## set do attributes using attr_accessor
    attr_accessor :id, :name, :breed

    ## initialize all the attributes
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    ## create table if it doesn't exist
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    ##Drop table if it exists
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    ## Create new table for database
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end
    
    def self.new_from_db(row)
        id, name, breed = row
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.all
        sql = <<-SQL
          SELECT * FROM dogs
        SQL
        rows = DB[:conn].execute(sql)
        rows.map { |row| new_from_db(row) }
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name).first
        new_from_db(row) if row
    end
    
    def self.find(id)
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).first
        new_from_db(row) if row
    end

    ## the save  method
    def save
        if id.nil?
            insert_sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(insert_sql, name, breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        else
            update_sql = <<-SQL
                UPDATE dogs SET name = ?, breed = ? WHERE id = ?
            SQL
            DB[:conn].execute(update_sql, name, breed, id)
        end
        self
    end
end
