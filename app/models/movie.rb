class Movie < ActiveRecord::Base

  has_many :comments, dependent: :destroy

  validates :title, :description, presence: true, length: { minimum: 5 }

end
