class Post < ActiveRecord::Base
  validates_presence_of :body
  belongs_to  :user
  has_many  :replies
  cattr_reader :per_page
  @@per_page = 10
end
