---
layout: post
title: "JRuby 10, Part 1: What's New"
date: "2025-04-09"
author: Charles Oliver Nutter
published: true
---

I am very excited to introduce you to JRuby 10, our biggest leap forward since "JRuby 9000" was released almost a decade ago.

With up-to-date Ruby compatibility, support for modern JVM features, and a big cleanup of internal code and external APIs, we believe this is our most important release ever. This article will provide a first look at these improvements and help you get started on your JRuby 10 journey.

Moving Forward
==============

With such a long time since our last major release, we decided JRuby 10 had to make some big moves. As a result, this is the most up-to-date and powerful JRuby release we've ever put together. Here's a few of the major upgrades you'll see when you move to JRuby 10.

### Compatibility jump to Ruby 3.4

It's been over three years since we released [JRuby 9.4](https://www.jruby.org/2022/11/23/jruby-9-4-0-0.html) with Ruby 3.1 compatibility, so naturally a version update was in order. Last year we decided it made the most sense for us to target Ruby 3.4, since it would be released late in 2024 around the time we hoped to wrap up JRuby 10.

That meant implementing [Ruby 3.2](https://github.com/jruby/jruby/issues/7517), [3.3](https://github.com/jruby/jruby/issues/8029), _and_ [3.4](https://github.com/jruby/jruby/issues/8395) features, and getting literally thousands of new tests and specs passing.

_CRuby core class test results_
```text
JRuby 9.4 running Ruby 3.1 tests:

4888 tests, 1859373 assertions, 0 failures, 0 errors, 22 skips

JRuby 10 running Ruby 3.4 tests:

5461 tests, 1903359 assertions, 0 failures, 0 errors, 43 skips
```

Over the past month, we merged our JRuby 10 development branch back to main, and just this week we finally went ["green" in CI](https://github.com/jruby/jruby/actions) after hundreds of hours of work. We're confident this is the most compatible a JRuby "dot zero" release has ever been, and being current on Ruby compatibility means we've got more time to work on aggressive optimization plans.

### Java up to 21

Like many projects in the Java world, we chose to maintain support for Java 8 for over a decade after it was released, due to challenging issues involving Java 9+ and the new restrictions of the Java Platform Module System. Even though we made sure JRuby supported the latest Java releases, we could only depend upon Java 8-level features. Meanwhile the JDK added powerful enhancements like native function calls ([Project Panama](https://openjdk.org/projects/panama/)) and lightweight threads ([Project Loom](https://openjdk.org/projects/loom/)).

For JRuby 10, we're finally updating our minimum Java version... to the most recent "long term support" version 21. Many of the JRuby features described in this post are possible because of that move.

We've already started to integrate the features that [Java 21](https://openjdk.org/projects/jdk/21/) provides, and we're looking forward to bringing ten years of JVM enhancements to Ruby users.

### Full optimization by default

Starting with Java 7, JRuby has supported optimizing Ruby code using a feature called "[invokedynamic](https://wiki.openjdk.org/display/HotSpot/Method+handles+and+invokedynamic)", which allows us to teach the JVM how Ruby code works. "Indy" is absolutely critical for Ruby performance on JRuby, but it has also taken time to evolve at the JVM level. Because of the extra startup and warmup time required to use indy on older JVMs, JRuby ran by default in a "middle tier" of optimization, using indy only for simple Ruby operations and using slower inline caching techniques for heavier ones. Users had to enable indy with the JRuby flag `-Xcompile.invokedyamic`.

But no longer!

JRuby 10 runs with [full invokedynamic optimization](https://github.com/jruby/jruby/pull/8450) by default. That means you'll get the best available performance for your JRuby scripts and applications without passing any additional flags.

_JRuby default red/black performance, 9.4 vs 10_
```text
$ jruby9.4 -v bench/bench_red_black.rb 5
jruby 9.4.12.0 (3.1.4) 2025-02-11 f4ab75096a OpenJDK 64-Bit Server VM 21.0.5+11-LTS on 21.0.5+11-LTS +jit [arm64-darwin]
1.0899240000000001
0.632956
0.604672
0.612468
0.5976049999999999
$ jruby -v bench/bench_red_black.rb 5
jruby 10.0.0.0-SNAPSHOT (3.4.2) 2025-04-09 e2909f9baf OpenJDK 64-Bit Server VM 21.0.5+11-LTS on 21.0.5+11-LTS +indy +jit [arm64-darwin]
1.651375
0.46118200000000004
0.363622
0.23990799999999998
0.177958
```

For development and testing environments, where aggressive optimizations are usually not helpful and just slow down command-line use, we provide other options...

### Startup time improvements

The number one complaint from JRuby users has always been startup time (and to a lesser extent, warmup time of large apps). With the leap to Java 21, we've started to leverage a few new JVM features to get JRuby apps starting up more quickly:

* OpenJDK's "[Application Class Data Store](https://openjdk.org/jeps/310)" (AppCDS) allows pre-caching code and metadata during startup to reduce the cost of future commands. JRuby's [main executable](https://github.com/jruby/jruby/blob/master/bin/jruby.sh) will automatically use the right AppCDS flags on Java 21+ to optimize and cache as much as possible. This has halved the startup time of a typical JRuby command, and there's a lot more we can do to utilize this feature.
* [Project CRaC](https://openjdk.org/projects/crac/) (Coordinated Restore at Checkpoint) is an experimental JVM feature that allows users to "checkpoint" a running process and launch multiple future processes by restoring that checkpoint. There's limitations, such as only being able to restore a single process at a time, but when CRaC works for you it can reduce startup time of even large apps to just a few milliseconds. The JRuby launcher supports CRaC with a few flags described in my first "[JRuby on CRaC](https://blog.headius.com/2024/09/jruby-on-crac-part-1-lets-get-cracking.html)" blog post.
* [Project Leyden](https://openjdk.org/projects/leyden/) is the next-generation "AppCDS", also storing data like JIT-compiled native code and optimization profiles from previous runs. The goal of Leyden is to eventually save off everything needed to start right up with optimized code, skipping the slow early stages of execution. The JRuby Team will incorporate Leyden flags into our launcher as they become available (with preview support already in Java 24)... and JRuby users will just have to upgrade their JDK to take advantage.

These features combined with our reduced-overhead `--dev` flag mean JRuby starts up faster than ever before... fast enough to take most of the pain out of command-line development.

_JRuby "hello world" startup time, 9.4 vs 10_
```text
[] jruby $ time jruby9.4 --dev -e 'puts "Hello, world!"'
Hello, world!
        0.99 real         1.13 user         0.10 sys
[] jruby $ time jruby --dev -e 'puts "Hello, world!"'
Hello, world!
        0.81 real         0.91 user         0.08 sys
```

Getting Started
===============

Trying JRuby has never been easier! Here's a quick walkthrough on getting JRuby into your development toolbox.

### Install a JDK

The only requirement for JRuby 10 is a Java 21 or higher JDK installation. I personally like the [OpenJDK "Zulu" builds from Azul](https://www.azul.com/downloads/?package=jdk#zulu), but there's excellent and well-supported free binaries from the [Eclipse project](https://adoptium.net/temurin/releases/), [Amazon](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html), [Microsoft](https://www.microsoft.com/openjdk), and [Oracle](https://www.oracle.com/java/technologies/downloads/).

Install the JDK in whatever way is most appropriate for your platform... usually that will mean a system-level package on Linux/BSD or an installer on MacOS and Windows. Then just point your `JAVA_HOME` environment variable at the JDK and JRuby's launcher will figure out the rest.

### Install JRuby

Most Rubyists will be familiar with Ruby managers and switchers like [rbenv](https://github.com/rbenv/rbenv), [rvm](https://rvm.io/), or [chruby](https://github.com/postmodern/chruby). JRuby 10 preview snapshots can be usually be installed as "jruby-head" or "jruby-dev", and after our release as "jruby-10" or just "jruby".

JRuby is also a JVM-based project ("write once, run anywhere", remember?), so [installing it yourself](https://www.jruby.org/) is as easy as unpacking a tarball or zip and putting the `bin` dir in your `PATH`. There's no build step and no build tools needed to start using JRuby today.

Users of `chruby` can unpack this tarball into `~/.rubies` since it does not support "head" installs.

### Try it out

JRuby supports the standard `irb` REPL, as well as other modern alternatives like `pry`. Once you have `jruby -v` working, you can `gem install` your favorite tools and test them out on JRuby. It's really that easy.

```text
$ irb
irb(main):001> JRUBY_VERSION
=> "10.0.0.0-SNAPSHOT"
irb(main):002> RUBY_VERSION
=> "3.4.2"
irb(main):003> java.lang.System.get_property("java.version")
=> "21.0.5"
```

Riding the Rails
================

Ruby without Rails would be like... well I guess it would still be Ruby, but there's no doubt Rails is still the most popular use case for Ruby. JRuby has supported Rails since the 1.x era, and we've worked with the Rails and JRuby community to keep up with new releases and features. JRuby represents the best way to achieve single-process multicore scaling of Rails applications, and thousands of Rails users around the world rely on it to better utilize precious computing resources.

We'll publish a post soon that describes how to get started with JRuby on Rails, all the way from generating an app to deploying on Puma or inside a Java application server.

### Rails compatibility

Keeping up with Rails is no small feat, and with only a handful of contributors we have tended to lag a bit behind. JRuby currently has database support for ActiveRecord up to 7.1, and work is ongoing to support Rails 8. If you have an interest in helping the JRuby team update our ActiveRecord adapter ([ActiveRecord-JDBC](https://github.com/jruby/activerecord-jdbc-adapter), which uses the pure-JVM Java DataBase Connectivity API), please let us know! We're hoping to have full support for Rails 8 by this summer.

### Generating an app

The typical Rails commands should all work on JRuby exactly the same as on standard CRuby, and with our startup time improvements and the --dev flag, we're able to run those commands faster than any past JRuby version.

### Config changes

Only minor configuration changes are required to run a Rails app on JRuby:

* Switch to the appropriate ActiveRecord-JDBC adapter for your database, in `database.yml` and in your `Gemfile`.
* Configure the Puma server for a number of threads based on the CPU cores available, using "2n+1" as a good rule of thumb.
* Make sure there's enough database connections in the pool for the number of Puma threads you configure.

Once you've generated a new app or made config changes to your existing app, just `bundle` and fire it up! JRuby is a true Ruby implementation, and we work very hard to ensure Ruby libraries and applications like Rails work the same as on CRuby.

Integrating with JVM Languages
==============================

Half the fun of JRuby comes from taking advantage of the Java platform. Here's just a few examples of things you can't do as easily or quickly on any other Ruby implementation.

### Ruby on the JVM

We've always had a goal of keeping JRuby a standard "JVM language", runnable on any Java build compatible with our minimum requirement. This means you can deploy JRuby on Linux, MacOS, and Windows, of course, but also unusual and exotic platforms like the BSDs, Solaris, and more. We also can run on any hardware supported by the JVM, which basically means any system with enough memory and at least 32 bit registers is fair game.

This also means JRuby can be deployed anywhere Java applications can be deployed, alongside enterprise Java apps using Spring or Jakarta EE. Ruby and Rails developers can expand their target market to any shop that hosts JVM-based apps... which dwarfs the number of shops that would be comfortable installing the libraries and development tools necessary to run CRuby. JRuby brings the Ruby world into the enterprise, and brings enterprise opportunities to every Rubyist.

_JRuby versus Ruby running threaded "tarai" benchmark_
```text
$ jruby bench_ractors_tarai.rb 
                      user     system      total        real
serial           21.580000   0.070000  21.650000 ( 21.395228)
threaded         32.690000   0.100000  32.790000 (  4.260730)

$ ruby3.4 --yjit bench_ractors_tarai.rb
                      user     system      total        real
serial           25.037682   0.060370  25.098052 ( 25.257134)
threaded         24.998077   0.055508  25.053585 ( 25.058869)
```

### Calling into Java

Part of running on the JVM is being able to integrate other languages and their libraries into your JRuby apps. With JRuby, you can call Java, [Scala](https://www.scala-lang.org/), [Clojure](https://clojure.org/), [Kotlin](https://kotlinlang.org/), and any other JVM language from Ruby with ease. Imagine bring the entire world of JVM languages and libraries to your Ruby app... what could you do when that kind of power?

_Using Java's Swing GUI API from Ruby_
```ruby
java_import javax.swing.JFrame

frame = JFrame.new("Hello Swing")
button = javax.swing.JButton.new("Klick Me!")
button.add_action_listener do |evt|
  javax.swing.JOptionPane.showMessageDialog(nil, <<~EOS)
    <html>Hello from <b><u>JRuby</u></b>.<br>
    Button '#{evt.getActionCommand()}' clicked.
  EOS
end

# Add the button to the frame
frame.get_content_pane.add(button)

# Show frame
frame.set_default_close_operation(JFrame::EXIT_ON_CLOSE)
frame.pack
frame.visible = true
```

### Using JVM libraries

Of course in order to use more than just the standard JDK libraries, you need to be able to download and load them into your app. JRuby provides tools like [jar-dependencies](https://github.com/jruby/jar-dependencies) to let your JRuby gems use libraries published to Maven Central, [Warbler](https://github.com/jruby/warbler) to bundle your app and libraries into a single executable jar or war file ("Web ARchive"), and an enhanced `require` that loads Java JAR files right into your app. It's the easiest and most fun way to explore all that the JVM has to offer.

Want to build a cross-platform desktop UI? The JVM has a half-dozen different frameworks for building GUI applications, and with JRuby-supported libraries like [Glimmer](https://github.com/AndyObtiva/glimmer) and [JRubyFX](https://github.com/jruby/jrubyfx), you don't have to give up Ruby to get there.

_Hello World in Glimmer_
```ruby
include Glimmer

shell {
  text "Glimmer"

  label {
    text "Hello, World!"
  }
}.open
```
![Hello World in Glimmer](/images/glimmer-hello-world.png)

Interested in building Android apps for mobile or embedded applications? JRuby provides the [Ruboto](http://ruboto.org/) framework for building Android apps in Ruby without having to write a single line of Java or Kotlin.

This also puts you on the leading edge of emerging technologies. As the JVM platform evolves and new features like Leyden, CRaC, [SIMD vector operations](https://openjdk.org/jeps/448), [GPU integration](https://openjdk.org/projects/babylon/) and native function support in Panama move from experimental to standard, your apps can start using them with a simple JDK upgrade.

You've even got a leg up on adding AI capabilities to your app; Ruby APIs for ChatGPT, Claude, Copilot and others are just starting to appear, but there's dozens of existing JVM libraries for these LLMs and other bleeding edge AI technologies. You can start using AI in your Ruby apps today with JRuby!

What's Next?
============

Over the coming weeks, I'll publish more detailed posts on each of these areas to help you get started as a new JRuby user or to upgrade your existing JRuby applications. We are very proud of the work we've done to bring JRuby 10 to life, and I guarantee every Ruby shop can be faster and more scalable by taking advantage of JRuby and the JVM.

Ruby's future depends on projects like JRuby and creative developers like you. Let's show them what we can do!

## [Join the discussion on Reddit!](https://www.reddit.com/r/ruby/comments/1jv91vy/jruby_10_part_1_whats_new/)

_JRuby Support and Sponsorship_
===============================

_This is a call to action!_

_JRuby development is funded entirely through your generous sponsorships and the sale of commercial support contracts for JRuby developers and enterprises around the world. If you find my work exciting or believe it is important your company or your projects, please consider partnering with me to keep JRuby strong and moving forward!_

[Sponsor Charles Oliver Nutter on GitHub!](https://github.com/sponsors/headius)

[Sign up for expert JRuby support from Headius Enterprises!](https://www.headius.com/jruby-support)
