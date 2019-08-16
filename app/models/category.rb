class Category < ApplicationRecord
  has_many :task_categories
  has_many :tasks, through: :task_categories
  validates :name, presence: true, length: { minimum: 3, maximum: 25 }
  validates_uniqueness_of :name
end