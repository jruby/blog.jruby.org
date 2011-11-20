---
layout: post
title: Gracious Eloise Interview
author: Chris White
email: cwgem@jruby.org
---

It's always interesting to see how JRuby is being utilized by our users. Sometimes it's ways we expect, other times the results are unexpected. Rebecca Miller-Webster ([@rmillerwebster](https://twitter.com/#!/rmillerwebster)), Head of Technology at [Gracious Eloise](http://www.graciouseloise.com/) ([@graciouseloise](https://twitter.com/#!/graciouseloise)), posted a blog entry titled [The Power of JRuby](http://www.rebeccamiller-webster.com/2011/11/the-power-of-jruby/) showing a rather interesting use of JRuby. Wanting to know more about how JRuby fit into Gracious Eloise's architecture, I conducted an interview so that users could see what kind of exciting things people are doing with JRuby!

## To start off, what is Gracious Eloise and what problem does it look to solve?

Gracious Eloise is making handwriting digital and handwritten notes as easy as email. We are creating a platform that allows business and individuals to write handwritten notes from their computer -- the notes are either printed, stamped, and mailed or emailed (coming soon!)

Our founder, Eloise Bune, came up with the idea when she had to write 300 thank you notes after her wedding.  In the process of building the algorithm and talking with investors, she realized that companies in many sectors, such as retail, non-profits, car dealerships, elected officials, and PR, currently have handwritten note programs that they are unable to scale or ensure quality and corporate standards.  That's where Gracious Eloise comes in.

## When did you first find out about JRuby?

I had heard rumblings of JRuby for a while -- a friend who is a Ruby and Java/Hadoop guy kept suggesting it to me for Gracious Eloise.  Our handwriting replication algorithm is written in Mathematica, and I was struggling to build a Java web service that would allow our web app to connect to it.

## At what point did you decide to use JRuby, and was it a tough decision?

After struggling to get a Spring MVC web service to just return JSON without a view, I gave myself 2 hours to try to do it in JRuby.  It was done and working in 30 minutes.  Not a tough decision at all! 

## How does JRuby fit in to your current architecture?

JRuby is the glue that connects everything together.  It connects our handwriting replication code (with a light Java wrapper around it) to our MRI Ruby on Rails web app via Resque jobs.  Ultimately, we will get rid of the Java code altogether and move that into JRuby as well as rewriting some or all of the handwriting replication algorithm using JRuby.  Because we can use Java's image and graphics libraries, JRuby is a huge win for us in terms of the algorithm itself. 

## What is the architecture like that keeps everything running?

We have Mathematica, Java, and JRuby running together in EC2 to do algorithm related processing. Our web app is Rails 3 with Backbone.js running on Heroku.  Pusher allows us to send messages about the status of processing to the web app.  Handwriting data is stored in MySQL (RDS), while customer and other web app related data is in Postgres.  

## What do you consider to be JRuby's strengths and weaknesses?

As I said in a recent blog post, I think the biggest strength of JRuby is that it opens you up to using any Java library out there.  Used in conjunction with Resque and MRI or REE Ruby, you can also use any C library out there.  Basically, JRuby hands you most of the world of code on a platter. 
 
As for weaknesses, I think it's biggest weaknesses are Java's biggest weaknesses.   And I'm mostly talking about Java's insane love of memory. :)  Obviously, using the JVM and having access to Java libraries have huge advantages, so as with all technology choices, it's a trade off.  But, again, you could always have code that is a memory-suck in Java moved to C and connect with other JRuby code in Resque.  JRuby allows you to choose the best tool for each job at hand and that, to me, is huge.  

## You mentioned that you were looking for a JRuby developer. What kind of work would be involved?

The main project our [JRuby Developer](http://careers.stackoverflow.com/jobs/14749/ruby-jruby-developer-gracious-eloise) would tackle would be creating an app for processing handwriting samples, likely a combination desktop and web app.  Currently, the process of getting someone's handwriting is a huge pain and requires a review process that is terrible to do in Mathematica.  We have some code for this here and there, but it would really be building something from scratch.  Beyond that, the job would involve keeping the glue between the algorithm and the web app working and improving the speed and efficiency.  Also, helping our algorithm engineers move code out of Mathematica.  

We are super small (i.e. I'm the only full-time developer), so if someone wanted to work on the web app side or the algorithm side as well that is on the table.  There's also work to do with printer and email provider integration as well as CRM integration.
 

## Thank you for taking the time for this interview! Do you have any closing words for our readers?

JRuby rocks my world! 