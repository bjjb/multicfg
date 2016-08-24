# Multicfg

A little helper library for Ruby programs that need to load configuration from
multiple sources.

You pass it a list of file names and keywords, and it will result in a Hash
which consists of options loaded from all those places. It can also load
environment variables and getopt\_long options.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multicfg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multicfg

## Usage

Here's how I use it all the time:

```ruby
cfg = Mulficfg.yaml('/etc/my-program.conf', '/usr/local/etc/my-program.conf',
                    '~/.my-program/config.yml', './.my-program.yml', :env)
```

...so frequently, in fact, that the shortcut `Multicfg.load('my-program')`
does exactly that.

That'll load hashes from those places (provided the files exist), merge them
(in order, so later entries supercede earlier ones), and override them with
environment variables (in this case orefixed with `MY_PROGRAM_`). The returned
Hash-like object has `#deep_merge` and `#deep_merge!` methods which do what
you would expect.

The example above loads YAML - there are corresponding `json` and `env`
methods which load JSON files and files consisting of lines of `KEY=value`
entries (for which the key is downcased/underscored in the resultant hash).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/movinga/multicfg. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

