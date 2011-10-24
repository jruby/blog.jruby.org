---
layout: post
title: Why Isn't JRuby Implemented in Ruby?
author: Charles Oliver Nutter
email: headius@headius.com
---

As Ruby implementations mature and Ruby code runs faster and faster,
the question starts to come up again and again: why not implement
more in Ruby? There's many good reasons to do it: easier for Rubyists
to maintain and contribute; no native library dependencies; better
visibility for debuggers and profilers; consistency all the way into
the core... the list goes on. As you'd expect, we often get this
question about JRuby itself, given that JRuby now runs Ruby code very
fast and most Rubyists would rather not read or write Java code. So
why isn't JRuby implemented in Ruby?

The answer: it's complicated.

Ruby is Not the Best Language for Everything
--------------------------------------------

The simplest answer is perhaps the most obvious: Ruby isn't always
the best tool. There's many cases where Ruby's dispatch overhead,
coercion protocols, arbitrary-precision integers, or mutable types
get in the way of expressivity or performance. What makes Ruby
"beautiful" sometimes obscures intent from either the programmer or
the underlying platform.

Performance is obviously a key issue. Sometimes, you really need raw
native maths or byte arrays and Fixnum, Float, and Array introduce too
much overhead. Using Java gives us a "known quantity" when it comes
to performance.

Now of course I'm not saying Ruby won't continue to get faster and
faster. JRuby on Java 7 has started to approach Java performance for
many algorithms, and as JRuby and the JVM improve, the gap will
continue to narrow. But optimizing a dynamic language is challenging
even on the best VMs, so it's nice to have that "known quantity"
when performance is critical.

JRuby's a Ruby Implementation *and* a JVM Language
--------------------------------------------------

Then there's also the matter of interfacing with statically-typed JVM
libraries. JRuby makes heavy use of JVM libraries for much of its
internals. That has meant we don't have to implement our own
collections, IO subsystem, JVM bytecode generator, YAML 1.1, and
much more. Of course some of these could be called via our Java
integration layer, but there's always a bit more overhead down that
road than by having Java calling Java.

Almost as important is the fact that nearly all of JRuby's core
classes can be called as normal Java classes from any piece of JVM
code. Java integration is a two-way street, and having Ruby-only
implementations would make one direction more challenging to
support.

Don't Throw Out the Baby
------------------------

Moving to Ruby for new code is easy enough, but moving existing
code to Ruby would mean throwing out known-working, battle-tested,
optimized Java implementations for something completely new. Any
good developer knows that a "big rewrite" seldom ends well, so
we'd be doing a great disservice to the thousands of JRuby users
out there by making a wholesale move to Ruby. There's no measure
of benefit (from rewriting in Ruby) that would outweigh losing
years of maturity in our codebase.

Inertia
-------

Inertia may be the biggest motivator here. The JRuby committers
are very familiar with Java and with the current implementation.
They also may know Ruby very well, but change is always
accompanied by some measure of confusion.

Most of the JRuby core team manages a subset of JRuby; Tom Enebo
works on parser, interpreter, and the new IR compiler. Nick Sieger
works on libraries like activerecord-jdbc and jruby-rack. Wayne
Meissner works on our native library integration layers like FFI.
I work on compilation, optimization, and Java integration. Do we
force everyone to start writing in Ruby when they may prefer to use
Java?

Developer Pool
--------------

As much as Ruby has grown in recent years, there are still far
more Java developers in the world. They may not *love* the
language, but they represent a tremendous potential pool of
contributors to JRuby. Yes, it's true that a Java developer is
probably less likely to contribute to JRuby than a Rubyist...
but there's still a hell of a lot of them out there.

There's also a very large portion of JRuby users (perhaps even
a majority) that are either primarily or originally Java folks.
Having a mostly-Java codebase means they can more easily
investigate bugs, integrate JRuby into their JVM-based
applications, and generally reason about how JRuby *actually*
works. That's very powerful.

But We Still Want to Do It!
---------------------------

Even though I list a bunch of reasons for having a mostly
Java codebase, we do recognize that Ruby is an excellent tool
for both writing apps and for implementing Ruby's core. And
we have always intended to make it possible for JRuby to use
more Ruby code as part of the core implementation, even if
we never do a wholesale rewrite.

To that end, I've started restructing the (admittedly small)
Ruby-based "kernel" of JRuby into a structure that's more
approachable to Rubyists that want to contribute to JRuby. The
restructured Ruby kernel is under [src/jruby](https://github.com/jruby/jruby/tree/master/src/jruby),
and while there's not much there right now we're willing to
accept new code in either Ruby *or* Java. If it becomes a
performance or integration problem, we may rewrite that code
in Java...but having a working implementation in Ruby is far
better than having nothing at all.

Whither Rubinius?
-----------------

You might be asking yourself "why not just use [Rubinius](https://github.com/rubinius/rubinius)'s
kernel?" We've always hoped (maybe intended) to use as much
as possible of Rubinius's mostly-Ruby kernel in JRuby, if
at some point that seemed feasible. With recent performance
improvements in JRuby, that day may be approaching. We would
need to patch away anything that's Rubinius-specific, but I
have toyed with how to start using Rubinius's kernel in JRuby
several times in the past few years. If we can borrow their
code for missing or poorly-implemented parts of JRuby, it
would be stupid for us not to do so.

It's also worth pointing out that Rubinius has very few of the
challenges JRuby does when it comes to integrating with an
existing platform. Rubinius was designed as a Ruby VM alone,
so there's no equivalent to Java integration. When Rubinius
wants to utilize native libraries, they do what we do: write
wrapper logic in C/++ (equivalent to JRuby's Java code) or bind
those libraries with FFI (similar to but more basic than our Java
integration). And Rubinius exposes no native, statically-typed
API to its implementation classes.

How Can You Help?
-----------------

Right now we're looking to use Ruby mostly for missing features.
Since we're still in the midst of filling out Ruby 1.9.2 and
1.9.3 features, that's a good place to start.

We use and contribute to RubySpec, just like Rubinius does,
so you can easily find missing or broken features by looking under
[spec/tags](https://github.com/jruby/jruby/tree/master/spec/tags)
in our codebase.

(RubySpec supports the concept of "tagging", where known-failing
specs can be "tagged" until they pass. This allows implementations
to maintain a "watermark" of passing specs over time, and allows
contributors to easily see and fill in implementation gaps.)

You'll want to fetch the revision of RubySpec we currently test
against by running _rake spec:fetch\_stable\_specs_ (or _ant
fetch-stable-specs_; git must be installed in both cases), but
after that you can run specs using [spec/mspec/bin/mspec](https://github.com/rubyspec/mspec)
in the usual way.

And of course if there are Ruby 1.8 or 1.9 features that are
weakly specified by available tests, we strongly encourage
you to contribute specs directly to the [RubySpec](http://rubyspec.org/)
project, so that all implementations can benefit.

We hope that making it easier to implement JRuby using Ruby
code will make it more approachable to Rubyists, and we're
looking forward to helping you craft your first pull request! Stop
by #jruby on Freenode IRC this week and we'll help you out!