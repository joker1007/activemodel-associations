if ActiveRecord.version >= Gem::Version.new("5.1.0")
  class CreateUsers < ActiveRecord::Migration[4.2]
    def change
      create_table :users do |t|
        t.string :name

        t.timestamps
      end
    end
  end
else
  class CreateUsers < ActiveRecord::Migration
    def change
      create_table :users do |t|
        t.string :name

        t.timestamps
      end
    end
  end
end
