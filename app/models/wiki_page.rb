class WikiPage < ActiveRecord::Base
  acts_as_versioned
  validates_uniqueness_of :title
end