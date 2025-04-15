# MatchTable

Adds a `match_table` matcher for your Capybara system specs.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add match_table
```

## Usage

In your system specs:

```ruby
# Matches rows but doesn't care about the order or extra rows
expect(page).to match_table(:foo_table).with_rows(
  {
    "Name" => "John Smith",
    "Status" => "Active",
  }
)

# Matches rows in the order they are defined and fails if there are extra rows
expect(page).to match_table(:foo_table).with_exact_rows(
  {
    "Name" => "John Smith",
    "Status" => "Active",
  }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/detaso/match_table>.
