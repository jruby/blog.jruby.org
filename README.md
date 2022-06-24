# This is the site and data for blog.jruby.org

It is powered by [Jekyll](http://github.com/mojombo/jekyll) on GitHub Pages.

## HOW TO CONTRIBUTE

**It's super easy.**

The *easiest* way is to write a post in [Markdown](http://daringfireball.net/projects/markdown/syntax "Daring Fireball: Markdown Syntax Documentation") and email it to us at [team@jruby.org](mailto:team@jruby.org).

The more self-lead way is to follow these few steps:

* Fork the repo on Github
* Clone that repo on to your computer

    `git clone git@github.com:YOUR-USER-NAME/blog.jruby.org.git`

* Create a file in `/_posts`
* Name that file using the format of `YYYY-MM-DD-Your-Post-Slug.md`
* At top top of that file include a bit of meta data in YAML.

Like this:

    ---
    layout: post
    title: Why I Love JRuby
    subtitle: And Why You Will Too
    canonical: http://example.com/2011/09/01/jruby-love
    author: Shane Becker
    email: veganstraightedge@gmail.com
    ---

* **REQUIRED FIELDS**: layout, title (if it's different from your file name slug), email, name
* **OPTIONAL FIELDS**: subtitle, canonical (this is the URL of the article on your site if you're reposting an article of yours)

* Write your awesome post!
* Add and commit that file in your local repo `git commit -a "New Blog Post"`
* Push to Github `git push origin gh-pages`
* Send a pull request to us
* That's it!

After your first contribution, you'll get added to the blog.jruby.org repo as a committer at which point you won't have to do the fork / pull request nonsense.

**Or...** if you're totally awesome and have the site to prove it, send me an email with a link to your previous writing on the subject and I'll just add you as a contributor.

*Let's do this thing!*

# License

The following directories and their contents are Copyright their original author. If no author is specified, Copyright the JRuby team :

* _posts/
* images/

All content in _posts and _images is licensed for use under CC

All other directories and files are PUBLIC DOMAIN. Your heart is as free as the air you breathe. The ground you stand on is liberated territory.
