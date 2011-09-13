---
layout: post
title: activerecord-jdbc-adapter 1.2.0 Released!
author: Nick Sieger
email: nicksieger@gmail.com
---
With the advent of our new [jruby.org blog](http://blog.jruby.org)
comes a new software release. Our JDBC-based adapter for ActiveRecord
is now compatible with the [Rails 3.1 release][rails31].

Install it as usual with `gem install activerecord-jdbc-adapter`.

A new and notable feature of Rails 3.1 is that support for AR-JDBC is
built-in. So when you generate a new Rails application with JRuby,
your Gemfile will be set up automatically for use with JRuby and
AR-JDBC. The `rails new` command:

    rails new photoblog -d mysql

creates the following section of the `Gemfile`:

{% highlight ruby %}
gem 'activerecord-jdbcmysql-adapter'
{% endhighlight %}

So, no more `-m http://jruby.org`, no more `rails generate jdbc`,
nothing. JRuby on Rails works out of the box.

I also want to take a moment to welcome [Anthony Juckel][ajuckel],
[Arun Agrawal][arunagw], [Guillermo Iguaran][guilleiguaran], [Matt
Kirk][hexgnu], [Luca Simone][lukefx], and [Samuel
Kadolph][samuelkadolph] for stepping up to the plate to help maintain
AR-JDBC going forward. Thanks everyone!

[rails31]: http://weblog.rubyonrails.org/2011/8/31/rails-3-1-0-has-been-released
[ajuckel]: https://github.com/ajuckel
[arunagw]: https://github.com/arunagw
[guilleiguaran]: https://github.com/guilleiguaran
[hexgnu]: https://github.com/hexgnu
[lukefx]: https://github.com/lukefx
[samuelkadolph]: https://github.com/samuelkadolph
