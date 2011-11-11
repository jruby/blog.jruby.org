---
layout: post
title: JRuby and ClojureScript Goodness
author: Chris White
email: cwprogram@live.com
---

While Java is a major language on the JVM, it's not the only one JRuby can interface with. JRuby can work with other JVM languages such as Scala, Groovy, and Clojure. JRuby committer Yoko Harada ([@yokolet](https://twitter.com/#!/yokolet)) has been doing some interesting work with [ClojureScript](https://github.com/clojure/clojurescript), a Clojure to JS compiler. This post will take a look at how JRuby was used to help bring ClojureScript to Tilt, and in doing so the Rails Asset Pipeline.

## ClojureScript and Tilt ##

The first experiment was getting ClojureScript to work with [Tilt](https://github.com/rtomayko/tilt), which is a "Generic interface to multiple Ruby template engines". Yoko's blog post [Tilt Template for ClojureScript](http://yokolet.blogspot.com/2011/11/tilt-template-for-clojurescript.html) describes the process of getting the two technologies to work together. JRuby's jar import functionality was used to interact with the ClojureScript related jars, which allowed Ruby to be used to bring everything together. For those interested in taking a look, there is a [git repository](https://github.com/yokolet/clementine) with the code available to check out.

## ClojureScript and The Rails Asset Pipeline ##

It doesn't stop there though! Since ClojureScript was available to Tilt, the next step was seeing if that could be used to interface with the [Rails Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html). The guide has a short snippet on registering gems with Tilt to get them recognized by Sprockets, which Yoko describes in the blog post [ClojureScript on Rails Asset Pipeline](http://yokolet.blogspot.com/2011/11/clojurescript-on-rails-asset-pipeline.html). A great example of how JRuby can be use to do cool things with cool JVM technologies! This is also another reason to keep your eyes on the [git repository](https://github.com/yokolet/clementine) to watch for new developments.

## You Can Do Closure Too! ##

ClojureScript uses the [Google Closure compiler](http://code.google.com/closure/) behind the scenes to make the JS compilation process happen. [Instella](http://www.instellaplatform.com/) CEO [Dylan Vaughn](https://twitter.com/#!/dylancvaughn) was inspired by a post on Closure Templates Discuss titled [Closure Templates in Ruby](https://groups.google.com/group/closure-templates-discuss/browse_thread/thread/50d977fcc121953b) to take a look on bringing JRuby and Closure together. Using some code for using [Closure's soy compiler with the Rails Asset Pipeline](https://github.com/igrigorik/closure-sprockets) by Googler [Ilya Grigorik](https://twitter.com/#!/igrigorik), he was able to interface the two together. The result of this is the [closure-templates gem](https://github.com/dylanvaughn/closure-templates), installable with `gem install closure-templates`. Be sure to check it out!