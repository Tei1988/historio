# Historio

**Historio** is the gem for recording attribute change histories by terms.

For example, there is a parking space and you want to manage the histories whether it is empty or not.

You can records histories like below:
- The parking space `A` was `empty` from `2018-02-20 12:14:30` to `2018-02-20 18:30:00`.
- The parking space `A` was `full` from `2018-02-20 18:30:00` to `2018-02-21 18:30:00`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'historio'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install historio

## Usage

### Model

### the most simple case
```ruby
class ParkingSpace < ActiveRecord::Base
  include Historio::Historizable

  historize
end
```

In this case, `historize` creates `ParkingSpaceHistory` model automatically for recording histories of `ParkingSpace`.

`ParkingSpaceHistory` checks the `status` column by default.
So, it is able to record the histories about `status` changing.

### defining the history model manually

If you want to add some columns to record its changing, you can describe it like below:

```ruby
class User < ActiveRecord::Base; end

class ParkingSpace < ActiveRecord::Base
  include Historio::Historizable

  historize history_model: ParkingSpaceHistory
end

class ParkingSpaceHistory < ActiveRecord::Bsae
  include Historio::HistoryModel

  watches :status
  watches :user_id
end
```

In this case, `ParkingSpace` uses existed `ParkingSpaceHistory`.

### Database
You need to prepare the table on DB for recording history before use.

For example, you can write a migration file on `ParkSpaceHistories` like below:

```ruby
class CreateParkSpeceHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :park_space_histories, id: :bigint, unsigned: true do |t|
      t.datetime :first_watched_at, null: false
      t.datetime :last_watched_at, null: false
      t.datetime :last_touched_at, null: false
      t.boolean :latest, null: true

      t.bigint :park_space_id, null: false, unsigned: true
      t.integer :status, null: false, unsigned: true

      t.timestamps
    end
    add_foreign_key :park_space_histories, :park_spaces
    add_index :park_space_histories,
              %i(park_space_id latest),
              unique: true, name: 'index_on_park_space_id_and_latest'
  end
end
```

There are 2 important parts.
1. defining these columns:
  - `first_watched_at`
  - `last_watched_at`
  - `last_touched_at`
  - `latest`
  - primary key on parent model (In this case, `park_space_id`)
1. adding index on primary key on parent model and `latest`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
