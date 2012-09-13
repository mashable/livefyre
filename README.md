# Livefyre

Interface library for Livefyre's API. Currently a mishmash of the v2 and v3 APIs.

## Installation

Add this line to your application's Gemfile:

    gem 'livefyre'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install livefyre

## Usage

You can set a default configuration object for Livefyre, which will prevent you from having to pass a client to
all your object proxies manually.

    Livefyre.config = {:network => "foo.fyre.co", :network_key => "blorgons", :system_token => "your_long_lived_system_token"}

If you're using this gem from Rails, we recommend doing this from an initializer.

Once that's set, you're ready to start talking to Livefyre.

    domain = Livefyre::Domain.new
    domain.set_pull_url "http://foo.bar/users/{id}/pull/"

    user = Livefyre::User.new("some_user_id")
    user.refresh # Invoke ping-to-pull

You can generate full documentation yourself from the source tree. Requires the yard-tomdoc plugin. Online documentation forthcoming.

    yard --plugin yard-tomdoc -o doc

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
