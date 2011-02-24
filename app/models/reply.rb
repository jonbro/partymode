class Reply < ActiveRecord::Base
  validates_presence_of :body
  belongs_to :post
  belongs_to :user
  
end
