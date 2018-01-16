class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if @id
      self.update
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog_to_check = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if !dog_to_check.empty?
      found_dog = dog_to_check.flatten
      self.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name).flatten
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
