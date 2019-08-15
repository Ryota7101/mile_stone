class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.references :user, foreign_key: true
      t.datetime :limit

      t.timestamps
    end
  end
end
