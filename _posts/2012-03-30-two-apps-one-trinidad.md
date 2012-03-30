---
layout: post
title: Using Trinidad to Run Multiple Apps
author: Joe Kutner
email: jpkutner@gmail.com
---

One of the advantages of running Ruby on the JVM is that we can deploy multiple applications to the same webserver.  Using one JRuby webserver means that there is only one process to manage, monitor, start and stop. Your sysadmins will thank you. 

Having mutliple applications on one virtual machine also means we can configure them to share resources, thus reducing the overhead required for a production server.  In this post, we'll walk through an example of deploying two applications to one Trinidad server. 

Trinidad is a light-weight JRuby web server that runs Rails and Rack applications in an embedded Apache Tomcat container.  Let's install it by running this command:

    $ gem install trinidad -v 1.3.4

Next, let's create a Trinidad home directory.  The examples in this post will use `/opt/trinidad`, but you can use whatever you'd like.

Under the `/opt/trinidad` directory, we'll create two more directories called `thing1` and `thing2`, which will contain the applications we're going to run on our single Trinidad server.  In the `thing1` directory, create a `config.ru` file and put this code in it:

<script src="https://gist.github.com/2254164.js?file=thing1_config.ru"></script>

In the `thing2` directory, create another `config.ru` file and put this code in it:

<script src="https://gist.github.com/2254164.js?file=thing2_config.ru"></script>

Next, we'll create a `/opt/trinidad/trinidad.yml` file, which will be used to configure our Trinidad server.  

<script src="https://gist.github.com/2254164.js?file=trinidad.yml"></script>

Our Trinidad home directory should look like this:

    /opt/trinidad/
    |-- trinidad.yml/
    |-- thing1/
        `-- config.ru/
    `-- thing2/
        `-- config.ru/

Before we start the server, let's make sure Sinatra is installed by running this command:

    $ gem install sinatra

Now we can run our Trinidad server by executing this command:

    $ trinidad --config /opt/trinidad/trinidad.yml
    Mar 29, 2012 11:46:52 PM org.apache.coyote.AbstractProtocol init
    INFO: Initializing ProtocolHandler ["http-bio-3000"]
    Mar 29, 2012 11:46:52 PM org.apache.catalina.core.StandardService startInternal
    INFO: Starting service Tomcat
    Mar 29, 2012 11:46:52 PM org.apache.catalina.core.StandardEngine startInternal
    INFO: Starting Servlet Engine: Apache Tomcat/7.0.23
    2012-03-30 04:46:52 INFO: No global web.xml found
    2012-03-30 04:46:53 INFO: jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (Java HotSpot(TM) 64-Bit Server VM 1.6.0_29) [darwin-x86_64-java]
    2012-03-30 04:46:56 INFO: The start() method was called on component [Realm[Simple]] after start() had already been called. The second call will be ignored.
    2012-03-30 04:46:56 INFO: jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (Java HotSpot(TM) 64-Bit Server VM 1.6.0_29) [darwin-x86_64-java]
    2012-03-30 04:46:58 INFO: Starting ProtocolHandler ["http-bio-3000"]

As the server starts up, we'll see that its instatiated two runtimes -- one for each of our applications.  We can see each of them by browsing to `http://localhost:3000` and `http://localhost:3000/thing2`.

The two applications are completely isolated.  That means if you monkey-patch the `String` class in one application, it won't affect the other application.  If you set a global variable to a constant value in one application, you can set it to a different value in the other application. 

Now let's move on and really take advantage of what we've created! 

Because these applications are running in the same JVM, they can share a Database Connection Pool.  To do this, we'll need to use the `trinidad_dbpool_extension`.  Trinidad provides an extension mechanism that allows us to plug-in many kinds of features.They are particularly useful when we need to hook into the embedded Tomcat container, as our database connection pool will.

To use the `trinidad_dbpool_extension`, we'll need to add an `extensions:` entry to our `trinidad.yml` file.  The new entry will contain the configuration for the Database Connection Pool.  The entire file should look like this now:

<script src="https://gist.github.com/2254164.js?file=trinidad2.yml"></script>

The extension creates the database connection pool inside the Tomcat container and gives it a JNDI name.  JNDI is a registry service for resources inside of a JVM.

You'll have to use a real database for this to work, but you don't have to use PostgreSQL.  The extension also supports MySQL, MSSQL, Oracle, and a generic adapter that covers most other JDBC implementations.  

Next, let's use the pool in our applications.  Change the `thing1/config.ru` file to look like this:

<script src="https://gist.github.com/2254164.js?file=config.ru"></script>

First, we've loaded the `active_record` Gem, which we'll use to interface with our database.  Next, we've added two statements to our `get` service.  The first statement establishes a connection from the pool by referencing the JNDI resource we definined earlier.  The second line executes a simple query against PostgreSQL's internal tables.  Finally, we're returning the result of the query as the service response.

Next, modify `thing2/config.ru` so it looks similar to the code above, but with "Thing two" in the response.

Before we can launch these applications, we'll need to install a few more gems by running these commands:

    $ gem install activerecord 
    $ gem install trinidad_postgresql_dbpool_extension 
    $ gem install activerecord-jdbcpostgresql-adapter

Now kill the Trinidad server if it's still running by pressing `Ctrl+C` from it's console, and start it up again by running this command once more:

    $ trinidad --config /opt/trinidad/trinidad.yml

When we point our browser to `http://localhost:3000` and `http://localhost:3000/thing2` we'll see something like this (depending on the number of tables in your database): 

    Thing one found: [{"count" => 0}]

Both applications are connecting to the database!

Sharing a database connection pool simplifies our production architecture by eliminating the need for additional layers like pg_pool. Trinidad makes it very easy to configure, but this same kind of setup can be achieved with any JRuby web server -- including TorqueBox and Warbler+Tomcat/Jetty/etc.

If you found this useful, I encourage you to pick up a copy of my book, [Deploying with JRuby](http://pragprog.com/book/jkdepj/deploying-with-jruby "Deploy with JRuby"), which has tons of other JRuby examples like this one.

The complete source for this example can be found on Github: https://github.com/jkutner/trinidad-dbpool-example