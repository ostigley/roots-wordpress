Roots Wordpress With Tag Views
================
This is an npm module that is an alternative to roots-wordpress.  This module will render single page views for posts, AND tags.  After the post data is recieved from wordpress, a tag_tree is generated.  This tree is used to create each tag single view, which is passed a tag object containing each post that has that tag.  You can use Jade display the tag object as you wish.  

This code mostly belongs to [Carrot](https://github.com/carrot/roots-wordpress).  I forked the repo and bent it round a bit. 

Thanks to [Carrot](https://github.com/carrot/roots-wordpress) for making a handy extension in the first place! 

### Installation

- make sure you are in your roots project directory
- `npm install roots-wordpress-tags --save`
- modify your `app.coffee` file to include the extension, as such

  ```coffee
  wordpress = require('roots-wordpress')

  module.exports =
    extensions: [
      wordpress
        site: 'my-wordpress-site.com'
        post_types:
          post: {template: 'views/_single_post.jade', tag_tree: {template: 'views/_single_tag.jade'}}
    ]
  ```


