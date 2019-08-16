class Task < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :task_categories
  has_many :categories, through: :task_categories
end
