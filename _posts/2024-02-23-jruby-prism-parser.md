---
layout: post
title: JRuby Prism - A new parser for a new era
author: Thomas E. Enebo
email: tom.enebo@gmail.com
---

# Introduction

JRuby has added support for the new backend parser [Prism](https://github.com/ruby/prism/) via the 
gem: [jruby-prism-parser](https://rubygems.org/gems/jruby-prism-parser).  Installing this
gem will give you access to enable Prism (`export JRUBY_OPTS="-Xparser.prism"`).  At this stage
jruby-prism-parser is at the technology preview stage but capable of running pretty much everything: Rake, RSpec,
RubyGems, Bundler, etc...  We plan on this being the default parser when we release our next major JRuby release (9.5)
which will be targeting Ruby 3.3 support.

We encourage all JRuby users to give it a try and help us work out any kinks.  Both in our integration with Prism and
for Prism itself as it is still under heavy development.

For those who do not want to read this whole article:

  1. `gem install jruby-prism-parser` and `export JRUBY_OPTS=-Xparser.prism`
  2. All implementations of Ruby will be sharing the same parser
  3. Prism is faster than JRuby's current parser
  4. Prism gives us some cool future improvements

The rest of this post will explain the background and why you should care.  For those who want more details about
Prism specifically then I recommend reading: https://kddnewton.com/2024/01/23/prism.html.  This mentions a lot
of additional information not covered here like the syntax tooling/APIs it enables.

# Why another parser?

## Community Effort

As a compatibility project JRuby is always chasing what is happening with C Ruby.  When a new release of C Ruby
comes out it includes a big set of changes to the parser.  JRuby must translate those changes to our fork of the
parser and it is not trivial work.  This is extra work that was just an accepted cost of developing JRuby.

Prism changes this.  It allows one set of developers to change the language and all implementations can use
that without any parser porting activity.  This is obviously less work but it also separates parsing into a more
focused repository.  Syntactic changes and fixes are easier to see and it gives the alternate implementations
more access to the evolution of Ruby.

One fascinating development I did not expect to see is so many different projects buying into Prism.  Besides the
more obvious ones like JRuby and TruffleRuby there has been support for Sorbet, js/webasm(Garnet), Rust, parser gem
emulation, ripper emulation, and so much more (https://github.com/ruby/prism?tab=readme-ov-file#examples).  I firmly
believe this is because the parser has been externalized to its own project.

## Speed

JRuby's existing parser can *eventually* parse quickly but it is subject to the JVM warming up and optimizing the Java
code in the parser.  So if you parse enough files then JRuby parses as fast or faster than C Ruby.  You will not ever
see this in practice however. This is because by the time you parse the code of a typical application you will not have
reached that warmup point where the JVM shines.  This is a conundrum.  We have tried different things and we still have
unfinished ideas but this has been one of JRuby's bigger unsolved problems.

Prism mitigates this warmup issue because it is implemented in C.  It has no warmup.  JRuby will load a shared library
and through a single foreign function call pass source code to be parsed.  Prism will then parse, generate a syntax tree,
and finally serialize that tree into a stream of bytes.  JRuby will deserialize those bytes into a Java version of the
syntax tree and then build that into JRuby's own internal virtual machine instructions (referred to
as IR from this point forward).

Why serialize? There are some neat features possible because of serialization that I will mention in the Futures section
of this post, but from a performance perspective the less foreign calls the better performance is.  If this API had been
performing potentially multiple foreign calls into C per syntax node the performance would slow down to a crawl.

Let's look at some current numbers.  Here is JRuby loading all the bootstrapped files of Ruby and loading internal
default gems (like rubygems) using our default parser (and with --dev to help improve startup time even more):

```text
time JRUBY_OPTS='--dev -Xparser.summary' jruby -e 1
----------------------------------------------------------------------
Parser Statistics:
  Generic:
    parser type: Legacy
    bytes processed: 490245
    files parsed: 71
    evals parsed: 69
    time spent parsing(s): 0.115545746
    time spend parsing + building: 0.174647871
  IRBuild:
    build time: 0.059102125

real	0m0.785s
user	0m1.379s
sys	0m0.150s
```

We parsed 140 files/evals and we spent 0.115s parsing.  Now let's look at Prism:

```text
time JRUBY_OPTS='--dev -Xparser.summary -Xparser.prism' jruby -e 1
----------------------------------------------------------------------
Parser Statistics:
  Generic:
    parser type: Prism(C)
    bytes processed: 681698
    files parsed: 71
    evals parsed: 69
    time spent parsing(s): 0.036817425
    time spend parsing + building: 0.093962833
  Prism:
    time C parse+serialize: 0.013102905
    time deserializing: 0.020535794
    serialized bytes: 381808
    serialized to source ratio: x0.5600838
  IRBuild:
    build time: 0.057145408

real	0m0.700s
user	0m1.224s
sys	0m0.131s
```

Same 140 files/evals but we did that parsing in 0.037s.  So Prism is a little over 3x faster.

Let's try something larger like entering into a Rails console in a single model scaffolded app.

Again using current parser:

```text
time echo exit | JRUBY_OPTS='--dev -Xparser.summary' jruby -S rails c
Loading development environment (Rails 7.1.3.1)
Switch to inspect mode.
exit
----------------------------------------------------------------------
Parser Statistics:
  Generic:
    parser type: Legacy
    bytes processed: 11250799
    files parsed: 1742
    evals parsed: 1672
    time spent parsing(s): 0.645997881
    time spend parsing + building: 0.9063163169999999
  IRBuild:
    build time: 0.260318436
```

Now with Prism:

```text
time echo exit | JRUBY_OPTS='--dev -Xparser.summary -Xparser.prism' jruby -S rails c
Loading development environment (Rails 7.1.3.1)
Switch to inspect mode.
exit
----------------------------------------------------------------------
Parser Statistics:
  Generic:
    parser type: Prism(C)
    bytes processed: 11941034
    files parsed: 1742
    evals parsed: 1672
    time spent parsing(s): 0.36850959
    time spend parsing + building: 0.612780287
  Prism:
    time C parse+serialize: 0.211684276
    time deserializing: 0.145067202
    serialized bytes: 8044568
    serialized to source ratio: x0.6736911
  IRBuild:
    build time: 0.244270697
```

Parsing goes from 0.645s to 0.369s.  We can see that we have greatly reduced our parser overhead.  I have not talked about our building of IR (see IRBuild time above) but we are doing some extra work to re-scan some text in Prism which will be going away (working around a bug).  It will not make a huge difference but it will speed up even more.

Speaking of bugs...

# Current State of JRuby and Prism

I mentioned above that we can run many things out of the gate with where JRuby and Prism stand today.  There are still
unresolved issues.  The only significant one is that some regular expressions with multiple byte characters are not
properly decoding to be valid regexps.  For example, in the Rails console example in the previous section I had to
comment out part of a single regexp in reline to run to completion.  This will be fixed very soon but it shows both how
far Prism is (only a single thing commented out) and also that is not quite done yet.

Two sanity CI Rake tasks we run are spec:ruby:fast and test:mri:core.  These two suites hit enough tests to give us
confidence that language and Ruby core libraries are working.  Here are the results using Prism (with our current
parser both of these would be 0F/0E):

```text
% rake spec:ruby:fast:prism

# output removed

3394 files, 29743 examples, 138683 expectations, 5 failures, 3 errors, 1109 tagged
```

Not bad.  Almost all of the errors are relatively unimportant things:

 - Mismatched error strings


```text
The rescue keyword raises SyntaxError when else is used without rescue and ensure ERROR
Expected SyntaxError ((?-mix:else without rescue is useless))
but got: SyntaxError ((eval):3: unexpected `else` in `begin` block; a `rescue` clause must precede `else`)
```

 - Missing warnings


```text
The defined? keyword when called with a method name in a void context warns about the void context when parsing it FAILED
Expected warning to match: /warning: possibly useless use of defined\? in void context/
but got: ""
```

 - Invalid syntax not getting marked as invalid


```text
The next statement in a method is invalid and raises a SyntaxError FAILED
Expected SyntaxError but no exception was raised (:m was returned)
```

In all three cases these are unlikely to break working code.

Here is running subset of C Ruby's test suite:

```text
% rake test:mri:core:int:prism

# output removed

4632 tests, 1863532 assertions, 41 failures, 3 errors, 18 skips
```

The failing tests here are more of the same but mostly syntax which should fail but doesn't.  On JRuby's side, there
is still a single failing test involving keyword arguments but otherwise we are looking really good.

I cannot underscore how quickly Prism is being developed.  The problems shown here will probably be
gone in another couple of weeks.  Since JRuby is bundling Prism support as a gem you will be
able to quickly update to a version of jruby-prism-parser as Prism updates come out.


# Futures

## Lazy method improvements

JRuby will only build IR (JRuby's internal representation) for methods if the method is actually called.  For larger
frameworks and libraries a majority methods will never be called.  Using Prism, JRuby support laziness already but there
are some larger potential for savings.

In the current parsers, both will generate an entire syntax tree and only generate IR for the method portions if they
are called.  This means from a memory perspective we have a live sub-tree for the method sitting around in case we
need to build it.  From a time perspective it means generating sub-trees we may not use.

Prism support also currently requires us to keep a copy of the original source to decode numbers (which has just gotten
fixed in the last day but not released yet).  Besides requiring us to keep more in memory this is holding back from
"ultimate laziness (tm)".

So what is "ultimate laziness (tm)"?  Remember I said when we call prism we get back a serialized representation of
the syntax tree?  The design of prism allows us to skip method sections of the serialized blob.  That in turn means we
can eliminate building up a syntax tree for the method unless it is ever called.  We will instead just keep a reference
to that section of the serialized blob.

In this new scheme the serialized section is much smaller than the live tree presentation AND we eliminate the time
spent to build that tree.  This will shave off even more time from parsing and building.

## Serialization as pre-compilation format

The serialized blob has had extra thought put into for saving it to disk.  It is versioned.  It saves all potential
warnings in case you are running with warnings enabled.  So we can just pre-compile all the base distribution files
as serialized files and skip parsing altogether.  We would only deserialize.

We could also provide a tool for people to precompile their projects for faster loading.  This could even be expanded
to an endorsed format so that all Ruby implementations could ship serialized code to make everyone save parsing
time.

## Web Assembly (Chicory)

I mentioned how many projects have contributed to Prism and one cool option which happened as a result is that
Prism is compiled to web assembly (wasm).  The Java world has a project called Chicory which can run wasm in Pure-Java.
JRuby and Chicory have worked together to demonstrate us being able to run using a wasm build of Prism.  That
works today (albeit as a WIP on a branch).

Chicory is still only running as a simple interpreter and is ~6-7x slower than C (or if you look at the previous examples 
above ~3x slower than our current parser) but once they can JIT/AOT compile wasm then I expect this will be much closer to
the C speed.

This will give us an escape from maintaining a second parser so platforms which cannot call into a C library (or
compile Prism) will continue to work.  Luckily, for JRuby users, JRuby 9.5 will still ship with our old parser
and Prism.

Soon we will add this integration in so you can `-Xjruby.parser.prism.wasm` in our next major release of JRuby.

## Precompiled libraries

For the common platforms we would like to precompile the shared library to reduce the need for people to
have compilers in order to install the gem.  Windows will likely be the first shipped binary as compilation
on Windows is not as simple as MacOS or Linux (hint: install Mingw if you are a windows user).  For now, 
compiler is a requirement to install the gem.

# Conclusion

Prism is a big step forward for the Ruby community.  It has been a lot of work to initially support this
new parser in JRuby but it will make development going forward much simpler.  The performance gains and other
potential (like pre-compilation) will give us some new tricks to improve startup time even more.

There have been many contributions to Prism and everyone who has worked on the project needs to be thanked.
As I said earlier the broad range of interest is fascinating and a good indication that this was a project
filling needs.  Kevin Newton gets a special call-out because he has been so focused and positive in welcoming
contributions that without him this project would not be so far along and moving at a break-neck speed.

