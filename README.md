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

    Livefyre.config = {
      :network      => "foo.fyre.co",
      :network_key  => "blorgons",
      :site_id      => 1234,
      :site_key     => "minerva",
      :system_token => "your_long_lived_system_token",
      :domain       => "zor.t123.livefyre.com"
    }

If you're using this gem from Rails, we recommend doing this from an initializer.

Once that's set, you're ready to start talking to Livefyre.

    domain = Livefyre::Domain.new
    domain.set_pull_url "http://foo.bar/users/{id}/pull/"

    user = Livefyre::User.new("some_user_id")
    user.refresh # Invoke ping-to-pull

You can generate full documentation yourself from the source tree. Requires the yard-tomdoc plugin. Online documentation forthcoming.

    yard --plugin yard-tomdoc -o doc

## Using with Rails

Integration with Rails is straightforward, but does require some setup.

### Controller integration

You need to add a route to your routes file to handle profile pull requests from Livefyre. That'll look something like:

    get "/livefyre/:id/pull", :to => "users#pull"

Of course, you need a matching controller action

    def pull
      # Checks the validity of the JWT that Livefyre sends with pull requests. Throws an exception if it's no good.
      validate_livefyre_request!

      # livefile_profile will attempt to generate valid Livefire profile dump from the passed user record by guessing at field names.
      # You can pass overides in a hash as the second option, or you can always generate your own data structure.
      render :json => livefire_profile(current_user, :image => current_user.profile_image_url).to_json
    end

Finally, you'll need to set up a pull URL. Since this is done via the API, you are expected to do it manually. From a Rails console is fine, though
you may do it any other way you please, too. Livefyre will substitute the string "{id}" for the user ID it wants data for.

    Livefyre::Domain.new.set_pull_url "http://your.domain.com/livefyre/{id}/pull"

### View integration


In the location that you want to use your comment form, include something like the following:

    <%= livefyre_comments post.id, post.title, post_url(post), post.tags %>

You'll also need to boot Livefyre with Javascript. In your application.js, you'll want to include the Livefyre loader in your manifest:

    //=require livefyre.js

And then somewhere in your application.js, you'll want to actually boot:

    window.initLivefyre({
      login: function() {
          // Things to do when the user clicks the "sign in" link. You probably want to
          // take your user through a login cycle in a popup window, which includes calling
          // the livefyre_login(user_id, user_name) method.
          window.location = "/login";
        },
      logout: function() {
          // things to do when the user clicks the "sign out" link. You probably want to take
          // your user through the logout cycle, including a call to livefyre_logout.
          window.location = "/logout";
        },
      viewProfile: function(handlers, author) {
          // Handler for when a user's name is clicked in a comment
          window.location = "/" + author;
        },
      editProfile: function(handlers, author) {
          // Handler for when a user wants to edit their profile from the Livefyre user dropdown.
          window.location = "/" + author + "/edit";
        }
    });

That's it!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
