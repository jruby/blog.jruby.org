---
layout: post
title: "JRuby CI: Keeping it Real"
author: Charles Oliver Nutter
email: headius@headius.com
---

Building a Ruby implementation is a long and challenging project. There's thousands of
tests you need to pass, tens of thousands of libraries you need to run, and lots of
edge cases you need to discover and fix over time. Perhaps even more challenging is
keeping your Ruby implementation working from release to release, commit to commit.
Continuous integration is an absolute necessity.

JRuby has had a CI server for at least the past five years, running hand-rolled
options at first, and later to [Jenkins](http://jenkins-ci.org/) (nee Hudson) where we will stay for the
foreseeable future. This post will help you understand how much effort we put into
remaining compatible and stable over time, and how you can track JRuby's dev process
from a CI perspective.

The Server
----------

As mentioned above, we run Jenkins for our CI server. The [ci.jruby.org](http://ci.jruby.org)
machine runs on EC2 on a modest-sized instance funded by [Engine Yard](http://engineyard.com). There are dozens
of builds running on that machine, and it's busy almost 24 hours a day.

There are several dimensions across which we test JRuby:

* "master" versus "release" - Currently 1.7 dev versus 1.6.x, the master branch and jruby-1\_6 branch.
* basic versus extended versus "all" tests - The "test" builds are doing our normal "test" target,
which runs quickly and includes a smaller subset of the full suite. These take about 3-5 minutes.
The "test-all" builds run an extended suite of tests across many combinations of JRuby
settings, and take anywhere from 30 to 60 minutes (run nightly).
* JVM vendor and version - We run our basic suite across several JVMs and try to keep them
green...but it's a challenge.
* RubySpecs - We run the full RubySpec suite across several combinations of JRuby settings.
* Domain-specific tests - We ensure the jruby-complete.jar works properly, jruby libraries like
jruby-rack and jruby-openssl pass their tests, and various rails releases pass their tests as
well. These aren't always kept green, since they depend on external repos and changes, but we
try to periodically tidy them up.
* Platform-specific tests - We also run our test suite on Windows, and have several test runs
for Ruboto, the JRuby-on-Android framework.

It's probably safe to say JRuby runs more tests in more combinations than any other Ruby
implementation, including MRI itself. What do the tests include?

The Suite
---------

JRuby's test suite obviously includes our own JRuby-specific tests, but over time it has grown
to include several other suites.

* JRuby's tests and specs - These are largely testing JRuby-specific features like Java
integration or our Java-facing embedding APIs. We also have some tests for JRuby-specific
enhancements to core Ruby functionality, like URL support in File and Dir methods.
* Legacy runit and minirunit tests - Inherited from older suites in MRI, this suite has slowly
been shrinking over time.
* MRI's test suite - In order to keep up with MRI's feature changes, we also run MRI's suite
in various forms. Most recently, we started running MRI 1.9.3's test suite unmodified, using
the new "excludes" feature in minitest.
* Rubicon - Rubicon was a suite of tests written originally to support the "Programming Ruby"
book from PragProg. We have always run it, and over time tidied it up and just use our local
copy. This too has shrunk over time, as we move more tests into RubySpec.
* The ruby\_test suite - This is a suite of tests created by Daniel Berger to support his
"facets" project. We run them just because.
* Our "main" Java-based suite - A set of JUnit test for JRuby's Java APIs.
* [RubySpec](http://rubyspec.org) - And of course, we run RubySpec for both 1.8 and 1.9 modes. If we encounter bugs
or missing tests, we almost always add to RubySpec, rather than to any of the other suites.

All six of these test groups are run as part of the "test-extended" and "test-all" targets,
adding up to literally millions of assertions.

The Snapshots
-------------

In order to aid people testing JRuby, and to give people easier access to the latest features
on master and fixes on our release branches, we publish nightly snapshots to [ci.jruby.org/snapshots](http://ci.jruby.org/snapshots).

Here you will find [1.7.x](http://ci.jruby.org/snapshots/1.7.x) and [1.6.x](http://ci.jruby.org/snapshots/1.6.x) builds, or if you
prefer to use our rolling development aliases,
[master](http://ci.jruby.org/snapshots/master) and [release](http://ci.jruby.org/snapshots/release) builds.

Your Turn
---------

There's a lot to track on our CI server, and we'd love your help in keeping builds green or
fixing builds that are red. We're also looking to add other key libraries to our CI server,
to help ensure we're maintaining a high level of compatibility. If you think you can help,
post a message to the JRuby dev list, or ping [@jruby](http://twitter.com/jruby) on Twitter!