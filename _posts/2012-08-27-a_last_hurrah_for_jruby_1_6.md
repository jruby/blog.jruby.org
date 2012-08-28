---
layout: post
title: A Last Hurrah For JRuby 1.6
author: Charles Oliver Nutter
email: headius@headius.com
---

Summer is wrapping up and the JRuby team is busy putting the finishing touches on
JRuby 1.7, our next major release. How major? It has taken us almost 1.5 years to
get to this point. That's major.

Of course, we weren't sitting on our hands that whole time. For about 8 months
after the release of JRuby 1.6 last year, we continued putting out point releases
to catch bugs, improve Ruby 1.9 support, and fix performance and concurrency
issues you faithful JRuby users reported. Even as late as the waning days of 2011,
we were putting out security-fix releases like [JRuby 1.6.7.2](http://jruby.org/2012/05/01/jruby-1-6-7-2).

But as of today, it has been eight months since a proper JRuby release. That's too
long.

JRuby 1.7 has had two preview releases, the most recent a couple weeks ago. And
JRuby 1.7 final is scheduled to come out toward the end of September. There are
already users with 1.7 in production, and we're confident it's going to be an
amazing release. But we also recognize that many users are still on JRuby 1.6
and may not be able to migrate for some time.

_So, by popular demand, we're going to release JRuby 1.6.8!_

This release will be a bit of an experiment in that the core JRuby team will not
directly contribute to it. We're looking to community members like you to
backport interesting fixes from JRuby 1.7 (or just come up with new fixes, where
the 1.7 versions require extensive work). We will run our usual slate of release
testing and actually do the legwork of putting out release artifacts, but this
version of JRuby is yours to make what you will!

We'd like to get JRuby 1.6.8 out soon...like the end of next week. Here's
how you can help:

* If you are running a patched version of JRuby 1.6.x right now, sort out the
patches you need and send us pull requests against the [jruby-1_6 branch on
Github](https://github.com/jruby/jruby/tree/jruby-1_6).

* If you know of fixes from 1.7 you need on your 1.6-based systems, do the
same thing, ideally by using git format-patch so the original committer is
associated with the pull request.

* Make sure your changes pass at least the following test runs: "ant
test-extended", "rake spec:ci_interpreted_18", and "rake spec:ci_interpreted_19".
If the patch affects the compiler, you might want to run the "compiled" version
of the "spec:ci" targets.

We will then have a look at your pull request, merge it in, and look at a full
JRuby 1.6.8 release in about two weeks.

If you'd like to try out early builds of JRuby 1.6.8, you can download dev
artifacts from [JRuby's CI server](http://ci.jruby.org/snapshots/1.6.x/).

JRuby 1.6.8 will really, truly be the last in the 1.6.x line, so this is your
chance to make it a good transition before JRuby 1.7. Now go forth and
backport patches!
