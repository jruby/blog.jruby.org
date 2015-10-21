---
layout: post
title: Performance Improvements in JRuby 9.0.3.0
author: Charles Oliver Nutter
email: headius@headius.com
---

With the release of JRuby 9000, we promised you'd see our new runtime start to shine in update releases. Now, it's starting to happen.

JRuby 9.0.3.0 has been released with three key performance improvements we're very excited about.

Lightweight Postfix Rescues
---------------------------

One of the most convenient anti-patterns in Ruby is the ability to add a `rescue` to any expression, capturing all StandardError descendants
and instead returning another expression. You see this pattern a lot in code where any exception raised has a trivial fallback.

Unfortunately, exceptions can be very expensive on the JVM. For various reasons, when the JVM generates a stack trace, it has to do much
more work than a runtime like CRuby: combining interpreted calls and compiled calls, breaking apart inlined code, omitting or reformatting
internal calls. Generating a 1000-deep stack trace on the JVM can cost in the neighborhood of a few milliseconds.

This doesn't sound like a lot until you start raising thousands of exceptions every second.

Here's an example from csv.rb, Ruby's standard library for CSV parsing.

```ruby
  Converters  = { integer:   lambda { |f|
                    Integer(f.encode(ConverterEncoding)) rescue f
                  },
                  float:     lambda { |f|
                    Float(f.encode(ConverterEncoding)) rescue f
                  },
...
```

Ruby's CSV library can automatically convert values to Ruby types as they are read. It does this by cascading attempts from one converter
to the next using trivial rescues to capture any errors. Each converter executes in turn until one of them is able to convert the incoming
data successfully.

Unfortunately, before 9.0.3.0, this had a tremendous impact on performance. Every exception raised here had to generate a very expensive
stack trace...ultimately causing CSV value conversions to spend all their time in the guts of the JVM processing stack trace frames.

We received a [bug report](https://github.com/jruby/jruby/issues/3348) showing JRuby processing and converting CSV almost 30x slower than
CRuby, and we knew we had to do something.

Luckily, with our new runtime, it was easy for to make improvements. Credit goes to Tom Enebo for this [excellent work](https://github.com/jruby/jruby/issues/3348#issuecomment-145081388):

* Inspect the expression provided for a rescue to see if it is trivial (local variable, constant value, etc).
* If trivial, entering the rescued code sets a thread-local flag indicating no stack trace will be needed.
* When raising exceptions, we can now omit stack traces we know will never be used.

The result? Trivial rescues are now over [40x faster than before](https://github.com/jruby/jruby/commit/fb4dcb4ee17a2b6bff8f6c7be8a334cc8b1c6d78)
and JRuby handles CSV with conversions considerably faster than CRuby.

Note that this optimization only works when the lightweight rescue is directly upstream from the
exception it captures. If there are intevening heavyweight rescues, we can't optimize the stack
trace away.

Independently Jitting Blocks
----------------------------

You can see from the CSV code snippit above that the converters are held in a hash mapping symbols to lambda expressions. This was another case
that needed fixing.

JRuby's JIT has always occurred at method boundaries. If a method is called enough times, we compile it to JVM bytecode. However, there are
libraries like CSV where the hot code is not contained within a method...it is a free-standing lambda or proc defined in a script or class
body. Because of the limitations of our old JIT, this code would only run in the interpreter, which is generally many times slower than
compiled JVM bytecode.

This is frequently compounded by the metaprogramming method `Module#define_method`, which allows you to define a new method using only
a Ruby block. These definitions usually don't occur within a method (or at least not within a method we JIT), so they too would never JIT.

In JRuby 9.0.3.0, I finally fixed this by modifying blocks to have their own independent call counters and JIT cycle. If a block is called
enough times (currently the same 50-call threshold as methods), they will JIT into JVM bytecode even if the surrounding scope does not. We've
promised this for years, but it wasn't until our new runtime that we were able to make it possible.

This improvement makes formerly unjittable blocks anywhere from 5x to 20x faster than they were before.

And speaking of `define_method`...

define_method Methods
---------------------

For years we've wanted to be able to optimize `define_method` methods just like regular methods. The block JIT changes above certainly help
that, but it is well known that blocks still have a more overhead (lexical context, heap-based local variables) than regular method bodies.

Once again our new runtime comes to the rescue. Thanks to additional work by Tom, JRuby 9.0.3.0 will now optimize non-capturing `define_method`
methods (i.e. those that do not access variables from their lexical enclosure) as if they were normal methods. No extra context must be managed,
no variables need to go on the heap, and all optimizations that apply to methods work just fine.

For cases where this optimization applies, you'll see almost no difference in performance between a `define_method` method and one defined with
the `def` keyword.

We don't plan to stop here, either. For future releases, we plan to make capturing `define_method` methods also optimize like regular
methods, modulo any context we can't optimize away. Ideally, these methods should have only a small amount of overhead (or none at all)
compared to their regular non-metaprogrammed siblings.

More to Come
------------

We're very happy with how JRuby 9000 has been received (our most stable, most compatible, and fastest JRuby ever) and we'll continue to push
the limits of what Ruby can do on the JVM (and what Ruby can do in general).

We'd love to hear what you're doing with Ruby and JRuby and encourage you to [join our community](http://jruby.org/community)!

