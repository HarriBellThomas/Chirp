class CreateAuthSessions < ActiveRecord::Migration
  def change
    create_table :auth_sessions do |t|
      t.string :uuid
      t.datetime :expires

      t.timestamps null: false
    end
  end
end
