---
layout: post
title: "Monitoring Memory Allocation Per Thread"
author: Charles Oliver Nutter
email: headius@headius.com
---

Perhaps the largest benefit of JRuby being on the JVM is the excellent tool ecosystem.
There's an enormous collections of debuggers, profilers, and general monitoring tools
available for JVM that work great with JRuby. Even better, a surprising number of these
tools are built into each JVM.

One of these tool sets is the [```java.lang.management```](http://docs.oracle.com/javase/7/docs/api/java/lang/management/package-summary.html)
package. Here, you'll find a number of [JMX](http://www.oracle.com/technetwork/java/javase/tech/javamanagement-140525.html) beans for monitoring the status and health
of the JVM. Some of the information presented by these beans is standard, like [lists
of memory pools](http://docs.oracle.com/javase/7/docs/api/java/lang/management/ManagementFactory.html#getMemoryPoolMXBeans())
(heaps) or the [number of available processors](http://docs.oracle.com/javase/7/docs/api/java/lang/management/OperatingSystemMXBean.html#getAvailableProcessors())
on the current system. But each JVM may also expose additional information.

On OpenJDK, starting with 6u25, the built-in [```ThreadMXBean```](http://docs.oracle.com/javase/7/docs/api/java/lang/management/ThreadMXBean.html)
exposes an additional operation: ```getThreadAllocatedBytes```. How can JRubyists take
advantage of it?

Monitoring Thread Allocation
----------------------------

Of course, via JRuby's Java integration, we can easily call any of the management beans'
operations, and ```getThreadAllocatedBytes``` is no different.

We start by loading the 'java' and 'jruby' libraries, to access Java classes and some
normally-hidden JRuby features.

    require 'java'
    require 'jruby'

We get access to the ```ThreadMXBean``` via the [```ManagementFactory```](http://docs.oracle.com/javase/7/docs/api/java/lang/management/ManagementFactory.html) 
class.

    thread_bean = java.lang.management.ManagementFactory.thread_mx_bean

Now, we will create a thread that endlessly creates a new string, and get references
to that thread's and the main thread's native ```java.lang.Thread``` object.

    t1 = Thread.new do
      a = nil
      loop do
        a = 'foo'
      end
    end
    t1_thread = JRuby.reference(t1).native_thread
    
    main = Thread.current
    main_thread = JRuby.reference(main).native_thread

Now that we've got a thread busily allocating data, we set up a loop that prints out
both threads' allocated bytes once every second. The ```getThreadAllocatedBytes```
method takes an array of thread IDs and returns an array of byte counts, both as
long\[\].

    loop do
      sleep 1
      t1_alloc = thread_bean.get_thread_allocated_bytes([t1_thread.id].to_java(:long))[0]
      main_alloc = thread_bean.get_thread_allocated_bytes([main_thread.id].to_java(:long))[0]
      puts "main allocated: #{main_alloc}"
      puts "t1 allocated: #{t1_alloc}"
    end

(Note the bit of Java integration array-munging; par for the course going from Ruby's
heterogeneous Array to Java's homogeneous arrays.)

And that's it! Here's the output on my system for five iterations of the loop:

    main allocated: 11343752
    t1 allocated: 378806608
    main allocated: 11359632
    t1 allocated: 767226768
    main allocated: 11361624
    t1 allocated: 1156928944
    main allocated: 11363616
    t1 allocated: 1547160976
    main allocated: 11365608
    t1 allocated: 1930237360

I've gisted the full script here: [Monitoring Thread Allocation](https://gist.github.com/1533906).

Your Turn
---------

This is just one of many fun (and useful!) ways you can monitor the JVM using JRuby.
Poke around in [```ManagementFactory```](http://docs.oracle.com/javase/7/docs/api/java/lang/management/ManagementFactory.html)
and see what else you can find!