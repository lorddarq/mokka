class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :login, :null => false
      t.string :email, :null => false
      t.string :first_name
      t.string :last_name
      t.string :userpic
      t.text :profile
      t.timestamps
    end
    
    add_index :users, :login
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
