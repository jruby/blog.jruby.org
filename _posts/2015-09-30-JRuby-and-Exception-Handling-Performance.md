---
layout: post
title: "JRuby and Exception Handling Performance"
author: Chuck Remes
twitter: chuckremes
---
 
Recently I wrote a blog post called [A Small Case Study in Threading](http://rubini.us/2015/09/29/a-small-case-study-in-threading/) over at the Rubinius blog. In that article I mentioned some issues with JRuby. This post will expand on the problems I faced and their ultimate solutions.

As a quick recap, a recent project required me to process hundreds of CSV (comma-delimited) files and import them into a database. The multi-threaded import code ran no faster on MRI than a single threaded version which would have put the import times at about 15 days. Under Rubinius the real threads allowed the same job to complete in about 5 days. The JRuby version, after some patches and command line switches, would have probably been faster.

Let's look at a multi-threaded benchmark to measure the CSV parsing of a small file under MRI, Rubinius, and JRuby. The results are below.

```
GuestOSX:options_database cremes$ ruby -v
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
GuestOSX:options_database cremes$ ruby benchmarks_multi.rb 
Rehearsal -------------------------------------------------------------
parse CSV - multithreaded   7.870000   0.100000   7.970000 (  7.962155)
---------------------------------------------------- total: 7.970000sec

                                user     system      total        real
parse CSV - multithreaded   7.930000   0.090000   8.020000 (  8.012822)

GuestOSX:options_database cremes$ chruby rbx
GuestOSX:options_database cremes$ ruby -v
rubinius 2.5.8 (2.1.0 bef51ae3 2015-09-24 3.5.1 JI) [x86_64-darwin14.5.0]
GuestOSX:options_database cremes$ ruby benchmarks_multi.rb 
Rehearsal -------------------------------------------------------------
parse CSV - multithreaded  20.991651   0.720063  21.711714 (  4.663789)
--------------------------------------------------- total: 21.711714sec

                                user     system      total        real
parse CSV - multithreaded  14.130549   0.136832  14.267381 (  2.984456)

GuestOSX:options_database cremes$ chruby jruby
GuestOSX:options_database cremes$ ruby -v
jruby 9.0.1.0 (2.2.2) 2015-09-02 583f336 Java HotSpot(TM) 64-Bit Server VM 25.60-b23 on 1.8.0_60-b27 +jit [darwin-x86_64]
GuestOSX:options_database cremes$ ruby benchmarks_multi.rb 
Rehearsal -------------------------------------------------------------
parse CSV - multithreaded 156.330000   1.260000 157.590000 ( 38.703243)
-------------------------------------------------- total: 157.590000sec

                                user     system      total        real
parse CSV - multithreaded 152.060000   0.680000 152.740000 ( 39.110063)
```
MRI ran the 4-thread benchmark in the same 8 seconds as the single-threaded code! We are often reminded that MRI maps its threads to native threads, but there is still a global interpreter lock (GIL) that prevents MRI from truly unlocking its performance. Rubinius eliminated its GIL years ago, so all threads can run in parallel and produce a finishing time of just over 3 seconds. Likewise, JRuby has no GIL limiting its threaded performance yet it came in far behind the pack. I complained about the performance in JRuby's IRC and got a few folks to look at it.

Originally, the JRuby team didn't see the same slowdown as I did. It turns out they were testing `CSV.parse('some CSV string')` instead of `CSV.parse('some CSV string', :converters => :all)` like I was doing in my code. I [opened a bug in the JRuby bug tracker](https://github.com/jruby/jruby/issues/3348) with a code reproduction so the JRuby team could officially get involved.

They almost immediately recognized the problem as being related to exception handling. Apparently the stdlib CSV code uses exceptions for flow control in the case where the parsing step needs to convert all fields to the appropriate data type (i.e. integer, float, string, date, etc). In the worst case scenario, there would be four (4!) exceptions raised to convert a *single field* of input.

Headius suggested using a few command line switches to disable generation of deep stack traces so that these exceptions were cheaper to process. The switches are `-J-XX:MaxJavaStackTraceDepth=0 -J-XX:-StackTraceInThrowable` which reduce the stack trace depth to zero and eliminate stack traces in thrown exceptions. This sped up the benchmark by a huge margin.
```
GuestOSX:options_database cremes$ ruby -J-XX:MaxJavaStackTraceDepth=0 -J-XX:-StackTraceInThrowable benchmarks_multi.rb 
Rehearsal -------------------------------------------------------------
parse CSV - multithreaded  17.360000   0.530000  17.890000 (  3.502499)
--------------------------------------------------- total: 17.890000sec

                                user     system      total        real
parse CSV - multithreaded  11.970000   0.170000  12.140000 (  2.872075)
```
But the JRuby team wasn't satisfied yet. Headius then produced a patch (which is part of that bug ticket) to move the converter logic from lambdas to methods. This change allows the JRuby runtime to optimize the code paths. There is additional work planned to allow for the just-in-time (JIT) compiler to handle blocks, procs, and lambdas in the near future.

With this patch and the command line switches, the performance improved again.
```
GuestOSX:options_database cremes$ ruby -J-XX:MaxJavaStackTraceDepth=0 -J-XX:-StackTraceInThrowable benchmarks_multi.rb 
Rehearsal -------------------------------------------------------------
parse CSV - multithreaded  13.840000   0.540000  14.380000 (  2.669253)
--------------------------------------------------- total: 14.380000sec

                                user     system      total        real
parse CSV - multithreaded   8.170000   0.130000   8.300000 (  2.012788)
```
At this point, most teams would commit the changes for the next release and close the ticket. Team member enebo picked up the ticket and began work on improving the performance of exception handling. After a day's work, he had improved exception handling performance by nearly 50 times. I haven't been able to test his code yet, but apparently those command line switches will no longer be necessary to see these fast times. That's a necessary change because many semi-complex projects need stack traces to work properly.

The code improvements made to the stdlib CSV library will eventually make it upstream to MRI. So this bug also presents an opportunity to highlight the power of community. The JRuby team is expending its time and effort to improve a basic library and send the improvements upstream so that all runtimes can eventually benefit from the improvements. This shows that the Ruby community can still impress me with its generosity and kindness of spirit. 

To reproduce the benchmarks listed above on your own systems, you can [download the benchmarks and test data from this link](https://www.dropbox.com/s/6nv7j9n2r9ro771/csv-benchmarks.tgz?dl=0) and the patch to stdlib CSV is [available in the bug report](https://github.com/jruby/jruby/issues/3348).
