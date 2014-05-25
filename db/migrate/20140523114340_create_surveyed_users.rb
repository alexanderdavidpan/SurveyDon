class CreateSurveyedUsers < ActiveRecord::Migration
  def change
    create_table :surveyed_users do |t|
      t.belongs_to :user
      t.belongs_to :survey

      t.timestamps
    end
  end
end
