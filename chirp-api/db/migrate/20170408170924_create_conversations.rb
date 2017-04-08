class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
        t.string :uuid
        t.string :fbid
        t.string :starling_access
        t.string :starling_refresh
        t.text :context
      t.timestamps null: false
    end
  end
end
