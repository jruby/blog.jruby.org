---
layout: post
title: "Getting Started with JRuby and Java 7"
author: Charles Oliver Nutter
email: headius@headius.com
---

Unless you've been living under a rock, you've probably heard about the new hotness for JRuby:
Java 7's support for dynamic languages. You may also have heard about the huge perf gains
that JRuby's seeing when running on Java 7. How can you try it yourself?

Get Java 7
----------

The reference implementation for Java is [OpenJDK](http://openjdk.java.net/), and
[OpenJDK 7](http://openjdk.java.net/projects/jdk7/) has been out for almost six months now.
The current version is 7u2 ('u' stands for 'update'), and includes a
[number of improvements](http://www.oracle.com/technetwork/java/javase/2col/7u2bugfixes-1394661.html)
over the GA ('General Availability') release.

Most platforms have easy access to OpenJDK builds. I'll summarize the steps here.

### Windows, Linux, and Solaris

Oracle provides binary downloads for Windows, Linux, and Solaris on its site. The [JavaSE
Downloads](http://www.oracle.com/technetwork/java/javase/downloads/index.html) page links to
both JDK and JRE download pages. You'll probably want the JDK, since it includes other
JVM-related dev tools, but the JRE will work too. Download, install, and you're ready.

Additionally, package managers for Linux and Solaris will likely soon have OpenJDK 7u2
packages available, if they don't already.

### OS X

There are no official releases of OpenJDK for OS X just yet, but you can get the current builds
from the [openjdk-osx-build](http://code.google.com/p/openjdk-osx-build/) project. The build
you want is currently labeled "1.7-x86-u2", but any combination of "1.7" and "u2" in the
future will get what you need. The package will contain either a self-contained JDK for you
to drop onto your system or a .pkg installer that does it for you.

### \*BSD

The OS X work is based off the "bsd-port" branch of OpenJDK. There are links to Java 7 package
information for FreeBSD, NetBSD, DragonFly BSD, and OpenBSD on the
[BSD Port wiki](https://wikis.oracle.com/display/OpenJDK/BSDPort). These may not be updated to
7u2 yet.

Why Update 2?
-------------

The reason we haven't previously made a lot of noise about Java 7 and JRuby, nor assembled a
blog post/tutorial like this, is due to the fact that Java 7 GA was missing key optimizations
in the invokedynamic subsystem. JRuby 1.7 will make heavy use of invokedynamic, and if we had
released it before those optimizations were in place, it would have given people a bad
impression of the power of invokedynamic.

Update 2 now has a small set of optimizations that make a very large difference. If you intend
to start playing with JRuby 1.7 builds, we strongly recommend you use update 2.

Getting JRuby
-------------

Of course getting JRuby is always pretty easy.

### JRuby 1.6.x (current release)

The current release of JRuby is always available on the [JRuby homepage](http://jruby.org).
Here, you'll find tarballs, zipfiles, Windows installers, and JRuby in other forms. Download,
unpack, add bin/ to PATH, and you're ready.

If you want to get the leading edge of the JRuby 1.6 line, including fixes that have not yet
been released, you can download a nightly snapshot from JRuby's
[release snapshots page](http://ci.jruby.org/snapshots/release).

You can also install JRuby through RVM or rbenv, using ```rvm install jruby``` or
```rbenv install jruby-1.6.5```, respectively. This is our recommended procedure for folks
already using RVM or rbenv. It's also possible to build/install JRuby 1.6.x snapshots using
```rvm install --branch jruby-1\_6 jruby-head```.

There are also JRuby packages for most major Linux and BSD variants. They're not always
up-to-date, however.

Finally, you can clone JRuby from the [JRuby github repository](http://github.com/jruby/jruby)
and build the jruby-1\_6 branch.

### JRuby 1.7.x (in development)

JRuby 1.7 is not out yet, since we had been waiting for OpenJDK 7u2 to drop before starting
our finalization process. Until it's released, you can get it a few different ways.

Simplest is probably to grab a snapshot from the JRuby's
[master snapshots page](http://ci.jruby.org/snapshots/master). You'll find the usual complement
of packages and installers there.

RVM can install JRuby 1.7 (master) using ```rvm install jruby-head```.

And of course, you can clone from [Github](http://github.com/jruby/jruby) and build the master
branch.

Use the Right Java Version
--------------------------

Ironically, the most complicated part of this process is making sure your system is set up
correctly to use Java 7 instead of some other version. The simple answer is to hardcode the
Java 7 bin/ dir in your shell's PATH, but that's both inelegant and incompatible with some
systems' preferred mechanisms. Here's a short survey of more elegant ways to easily swap Java
versions.

### Linux

As with most things, Linux variants don't agree on how to manage multiple alternative versions
of a given package. Below I summarize the "blessed" way to do it on various Linux flavors.

Alternatively, you can rig up a trivial shell function or script that, when run, rewrites your
environment to point at the target Java installation. See the "pickjdk" script for OS X below.

#### Debian variants (Debian, Ubuntu, etc)

On Debian, your command of choice will be update-java-alternatives. This resets a set of
global symlinks to point at the Java installation you prefer. It's not the most elegant way,
since the change is made globally, but it is the blessed way.


#### RedHat variants

RedHat has a similar command called "alternatives", under which there's a "java" namespace.
the JBoss 5 docs have a nice page on
[setting the default JDK on RHEL](http://docs.redhat.com/docs/en-US/JBoss_Enterprise_Web_Platform/5/html/Installation_Guide/sect-use_alternatives_to_set_default_JDK.html)

#### Gentoo and other Linux variants

I have so far been unable to find a way to easily manage multiple installed Java versions on
Gentoo. Feel free to submit suggestions in the comments.

### Windows

On Windows, your best best is generally to put the preferred Java version's bin/ dir in PATH.
If you have other suggestions, feel free to comment.

### OS X

On OS X, you have a couple options.

Your best option will be to use the oft-tweaked "pickjdk" script, which scans installed JDK
versions and presents a menu. Selecting a version rewrites your environment to point at that
version. I prefer [my pickjdk variant](https://gist.github.com/1234935), since it allows specifying an install number directly
without going through the menu.

Second, you can open up the Java Preferences utility (search with QuickSilver or Spotlight)
and drag your preferred Java version to the top. This is a *global* change, and will affect
any programs that just run the OS X-default Java. Because the GUI parts of the OS X Java 7
preview are still in development, THIS IS NOT RECOMMENDED.

### Other OSes

I'm not sure of the proper mechanism for managing multiple Java installs on the other BSDs
or on Solaris. Feel free to comment.

Try It Out!
-----------

Once you've got JRuby installed and in PATH (via whatever mechanism) and Java 7 installed
and in PATH (via whatever mechanism), you're ready to test it out! Start up ```jirb```,
launch your favorite JRuby-based app, or just run some benchmarks.

What to Expect
--------------

Java 7 brings a lot of performance updates, even without invokedynamic. If you're using JRuby
1.6.x, you should see an immediate performance improvement moving from Java 6 to Java 7. I
have heard reports of anywhere from 10-30% faster applications.

If you're using JRuby 1.7, you should see even more significant improvements. JRuby 1.7's use
of invokedynamic means that Ruby code runs faster, optimizes better, and uses fewer resources.
In fact, if you *don't* see better performance with JRuby 1.7 versus JRuby 1.6 on Java 7,
please report an issue at [JRuby's bug tracker](http://bugs.jruby.org). You've probably found
a flaw in our compiler...a flaw we'll definitely want to fix before release.

Your Turn
---------

That's about it for this tutorial. Hopefully you'll be up and running on JRuby with Java 7
very quickly. If you have any trouble, please comment...we'll try update this article with
fixes and suggestions. And I repeat my call for feedback on JRuby 1.7 + Java 7...this is the
future of JRuby, and it could be the future of high-performance Ruby. Let's work together to
make it awesome!