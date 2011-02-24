require 'digest/sha1'
require 'digest/md5'

class User < ActiveRecord::Base
  has_many :posts
  has_many :replies
  
  validates_uniqueness_of :name, :on => :create
  validates_presence_of :name
  
  # Please change the salt to something else, 
    # Every application should use a different one 
    @@salt = 'sub_forum_temp_salt'
    cattr_accessor :salt

    # Authenticate a user. 
    #
    # Example:
    #   @user = User.authenticate('bob', 'bobpass')
    #
    def self.authenticate(username, pass)
      find(:first, :conditions => ["name = ? AND password = ?", username, sha1(pass)])
    end

    def self.md5(value)
      Digest::MD5.hexdigest("#{value}")
    end
    
    def self.find_hashed(pass_hash)
      strings = pass_hash.split("--")
      if strings.length > 1
        find(:first, :conditions => ["id = ? AND password = ?", strings[0].to_i, strings[1]])
      else
        find(:first, :conditions => ["password = ?", pass_hash] )
      end
    end
    
    
    # Apply SHA1 encryption to the supplied password. 
    # We will additionally surround the password with a salt 
    # for additional security. 
    def self.sha1(pass)
      Digest::SHA1.hexdigest("#{salt}--#{pass}--")
    end

    before_create :new_password

    def new_password
      crypt_password
    end

    def self.hashed(str)
      return Digest::SHA1.hexdigest(str)[0..39]
    end

    # Before saving the record to database we will crypt the password 
    # using SHA1. 
    # We never store the actual password in the DB.
    def crypt_password
      write_attribute "password", self.class.sha1(password)
    end

    before_update :crypt_unless_empty

    # If the record is updated we will check if the password is empty.
    # If its empty we assume that the user didn't want to change his
    # password and just reset it to the old value.
    def crypt_unless_empty
      if password.empty?
        user = self.class.find(self.id)
        self.password = user.password
      else
        write_attribute "password", self.class.sha1(password)
      end
    end
  
end
