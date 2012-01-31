---
layout: post
title: Rails 3.2 and Rubygems.org source
author: Nick Sieger
email: nick@nicksieger.com
---
We announced this on Twitter, but it's important enough to put here
for posterity.

<blockquote class="twitter-tweet"><p>FYI, since 3.2 <a href="https://t.co/Zxl4M5tA" title="https://rubygems.org">rubygems.org</a> is the default Gemfile source, this means you need to have jruby-openssl installed before "rails new".</p>&mdash; JRuby Dev Team (@jruby) <a href="https://twitter.com/jruby/status/164376150209069056" data-datetime="2012-01-31T15:55:02+00:00">January 31, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8">
</script>

To clarify, the following is put in `Gemfile` for new Rails 3.2 apps:

    source 'https://rubygems.org'

This means that the `jruby-openssl` gem *must be installed* before you
can generate a new Rails application.

An alternative is to run `rails new --skip-bundle`, ensure
`jruby-openssl` is installed, and then run `bundle install` inside
your new application.

We're looking at options for incorporating more of jruby-openssl into
JRuby proper without importing the export-controlled crypto bits
(which is the reason we don't currently ship `jruby-openssl` with
JRuby). If you're [interested, join us](https://github.com/jruby/jruby-ossl/).
