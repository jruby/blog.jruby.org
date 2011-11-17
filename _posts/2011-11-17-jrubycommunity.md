---
layout: post
title: JRuby Community Improvements
author: Chris White
email: cwprogram@live.com
---

JRuby community guy Chris White ([@cwgem](https://twitter.com/#!/cwgem)) here. First off as I'll be offering topics you can contact me about, here's the best ways to do so:

* IRC: cwgem  @ freenode
* Mail: cwprogram at live dot com
* Twitter: [@cwgem](https://twitter.com/#!/cwgem)

As of late I've been getting more involved in helping with the JRuby community, and finding out the best ways to reach out to new and existing users. Knowing who your community is helps to understand what needs should be filled, and what possible pain points are. That's why I've made a few changes that I'd like to talk about to hopefully get you, the community, involved with JRuby better.

## Twitter Accounts

Previously JRuby related tweets were getting spread across multiple accounts, and the JRuby official account was somewhat dry with content. Twitter is a great information aggregator, and those using the service often want a centralized place to check on related content. If someone asks "Where's the best place to get JRuby related information?", the answer should always have an official account with regularly updated content. So with this in mind I'm working with other JRuby team members to keep the account fresh. So please be sure to follow [@JRuby](https://twitter.com/#!/jruby/) on Twitter to stay up to date on happenings!

Now another interesting issue I've run into is that there are a few JRuby job postings that trickle through on twitter. At first my main thought was to talk about them on the main @JRuby account. However the problem with that is it has the potential to make @JRuby perceived as a "spammy" account. Also the point of the account is to get job openings pushed out to people that actually care about them. This means they need to be focused to such users. @JRuby can't achieve this well because the expectation isn't setup to keep your eyes on the account for updates. To help alleviate these issues, the [@JRubyJobs](https://twitter.com/#!/JRubyJobs/) account has been created. If you're an employer looking for JRuby developers, or a JRuby developer who wants to use their skills in the workplace, be sure to check the account out! Those wanting to have JRuby job opportunities posted to the account please cc @JRubyJobs on the listing, DM the account, or send me an email.

## JRuby Map

An interesting question that comes up regarding open source communities is where everyone is from. In the internet age open source users are often spread across the globe, sometimes in unexpected places. To attempt to get an idea of where our JRuby users are, I created the [JRuby User Map](http://preview.tinyurl.com/jrubyusers). My hope is to have a more populated map, so that I can see where our biggest user communities lie, but also make sure the smaller communities are recognized as well. Smaller communities are often put off as not worthwhile. However my belief is that these smaller communities are much more crucial. These are users who are working with JRuby in an environment where there is less support, which shows a tremendous amount of dedication. If you're part of such a community and need help growing please contact me through Twitter or email.

For those of you who haven't added themselves to the map, be sure to check out the [blog post showing how the process works](http://blog.jruby.org/2011/11/communitymap). It's only a few steps and helps us get to know our community better!

## Surveys

The best way to get to know users is to ask them questions. With this in mind I created a two surveys and casually posed a JRuby OS/App Server question on twitter. Some results simply confirmed my suspicions, others were quite interesting.

### Java Version Survey

First was the [Java Version Survey](http://www.surveybuilder.com/s/KQrnk-yKwAA?source_id=3&source_type=web). The purpose of this survey was to understand which Java version people were running JRuby with. There were a total of 83 respondents to this survey. As the answer was multiple choice, the number of selections, 104, was greater than the number of respondents. As for how the data ended up:

* Java 8 - 1 user (1%)
* Java 7 - 28 users (27%)
* Java 6 - 72 users (69%)
* Java 5 - 3 users (3%)

This was more a confirmation of my assumptions. For the most part people are on Java 6, which makes sense as Java 7 came out recently. It also matches the JRuby 1.7 dev (trunk) usage. If you're using trunk then upgrading to Java 7 is recommended to utilize the invokedynamic enhancements! There's one brave Java 8 user, and a few Java 5 users still remaining.

### JRuby Version Survey

Next was to figure out what JRuby version was being used, and what the ratio of 1.8 and 1.9 mode usage was. This particular survey was split into four questions, two development environment questions and two production environment questions (optional of course). There were a total of 59 respondents. The allocation of responses were as follows:

* JRuby Development Version - 79 answers
* JRuby Development Ruby Mode - 59 answers
* JRuby Production Version - 66 answers
* JRuby Production Ruby Mode - 54 answers

There weren't too many respondents who use JRuby only for development. The gap between JRuby dev respondents and answers is most likely due to people running multiple versions for testing. Personally I run 1.6.5 and trunk at the same time! Now for the results:

#### JRuby Development Version

* 1.7 dev (git master) - 9 users (11%)
* 1.6.5 - 46 users (58%)
* 1.6.4 - 12 users (15%)
* 1.6.3 - 5 users (6%)
* 1.6.2 - 2 user (3%)
* 1.6.1 - 1 user (1%)
* 1.5 - 3 users (4%)
* 1.4 and lower - 1 user (1%)

Most users are around 1.6.4 and 1.6.5, with a good number using trunk. This is expected for development use. 

#### JRuby Development 1.8/1.9 Mode

* 1.8 Mode - 19 users (32%)
* 1.9 Mode - 28 users (47%)
* Both - 12 users (12%)

This was not too surprising. A majority of development users are on 1.9 mode, with the rest between 1.8 mode or both 1.8 and 1.9 mode. 

#### JRuby Production Version

* 1.7 dev (git master) - 2 users (3%)
* 1.6.5 - 37 users (56%)
* 1.6.4 - 9 users (14%)
* 1.6.3 - 8 users (12%)
* 1.6.2 - 1 users (2%)
* 1.6.1 - 1 user (2%)
* 1.5 - 6 users (9%)
* 1.4 and lower - 1 user (3%)

The 2 users of 1.7 dev was a bit of a surprise. If you're out there and reading this please shoot me an email on how you're using it and how it's working for you! There are a lot of 1.6.5 users, which means a majority of users are good about keeping up to date (since 1.6.5 was very recently released). There are noticeable number of 1.5 users, which is understandable given that some business are very conservative about technology related changes. If however there's a bug or other reason which is blocking you from upgrading to the 1.6 please let us know! Having everyone on the same page is what we'd like to achieve. 

#### JRuby 1.8/1.9 Mode

* 1.8 mode - 26 users (48%)
* 1.9 mode - 17 users (31%)
* Both - 11 users (20%)

The results here were a bit intriguing, as I was expecting a far larger gap between 1.8 and 1.9 mode usage. It will be interesting to revisit this question again when JRuby 1.7 becomes officially released. For those using both 1.8 and 1.9 mode, let us know how the Ruby mode usage is split up for your particular case.

### JRuby and Rails Deployment Survey

The question was posed as to what OS and what app server was used for JRuby and Rails deployment. Most users mentioned that they were doing development work on Mac OSX, which is normal for the Ruby community in general. The server operating systems were a mix of RedHat and Debian based (RedHat, CentOS, Fedora, Debian, Ubuntu). There were a few Windows users (Windows 2008 Server), and a Solaris and AIX user. As for the app servers, Tomcat had the lead with Jetty, Trinidad and Torquebox also getting mentions.  A few users also mentioned WebSphere and Glassfish.

This leads me to the conclusion that:

* We need to ensure the install guide for these app servers is up to date, especially the widely used Tomcat server.
* On that note finding links to the official pages of specific distributions on installing JRuby would be helpful
* A lot of users were noting that Mac OSX is their main development box, so revisiting the installer and ensuring it meets its needs would be a good idea