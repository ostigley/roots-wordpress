API       = require './api'
W         = require 'when'
RootsUtil = require 'roots-util'
_         = require 'lodash'
path      = require 'path'
request   = require 'request'
results_obj = {}



module.exports = (opts) ->
  RootsWordpress = undefined
  if opts == null
    opts = {}
  if !opts.site
    throw new Error('You must supply a site url or id')
  if !opts.post_types
    opts.post_types = post: {}
  RootsWordpress = do ->
    `var RootsWordpress`

    RootsWordpress = (roots) ->
      @roots = roots
      @util = new RootsUtil(@roots)
      opts.site = opts.site.replace(/http:\/\//, '')
      return

    RootsWordpress::setup = ->
      all = undefined
      config = undefined
      type = undefined
      _base = undefined
      if (_base = @roots.config).locals == null
        _base.locals = {}
      @roots.config.locals.wordpress = {}
      all = (->
        `var type`
        _ref = undefined
        _results = undefined
        _ref = opts.post_types
        _results = []
        posts = undefined
        tag_tree = undefined
        render_tags = render_tag_views.bind(this)
        for type of _ref
          config = _ref[type]
          _results.push request(opts.site, type, config).then(((res) ->
            posts = res.entity.posts
            tag_tree = create_tag_tree(posts)
            W(tag_tree).then(render_single_views.bind(this, config, type, res)).then(add_urls_to_posts).then(add_posts_to_locals.bind(this, type)).then(render_tags.bind(this, config.tag_tree, tag_tree)).then add_posts_to_locals.bind(this, 'tag_tree', tag_tree)
            return
          ).bind(this))
        _results
      ).call(this)
      W.all all

    RootsWordpress

request = (site, type, config) ->
  params = undefined
  params = _.merge(config, type: type)
  API
    path: '' + site + '/posts'
    params: params

render_single_views = (config, type, res) ->
  posts = undefined
  posts = res.entity.posts
  if !config.template
    return {
      urls: []
      posts: posts
    }
  W.map(posts, ((_this) ->
    (p) ->
      compiler = undefined
      locals = undefined
      output = undefined
      tpl = undefined
      tpl = path.join(_this.roots.root, config.template)
      locals = _.merge(_this.roots.config.locals, post: p)
      output = '' + type + '/' + p.slug + '.html'
      compiler = _.find(_this.roots.config.compilers, (c) ->
        _.contains c.extensions, path.extname(tpl).substring(1)
      )
      compiler.renderFile(tpl, _.cloneDeep(locals)).then((res) ->
        _this.util.write output, res.result
      )['yield'] output
  )(this)).then (urls) ->
    results_obj =
      urls: urls
      posts: posts
    results_obj

add_urls_to_posts = (obj) ->
  obj.posts.map (post, i) ->
    post._url = obj.urls[i]
    post

add_posts_to_locals = (type, posts) ->
  @roots.config.locals.wordpress[type] = posts

render_tag_views = (config, tag_tree, obj) ->
  tags = Object.keys(tag_tree)
  W.map(tags, ((_this) ->
    (p) ->
      compiler = undefined
      locals = undefined
      output = undefined
      tpl = undefined
      tpl = path.join(_this.roots.root, config.template)
      locals = _this.roots.config.locals
      locals.tag = tag_tree[p]
      output = 'tags/' + p + '.html'
      compiler = _.find(_this.roots.config.compilers, (c) ->
        _.contains c.extensions, path.extname(tpl).substring(1)
      )
      compiler.renderFile(tpl, _.cloneDeep(locals)).then((res) ->
        _this.util.write output, res.result
      )['yield'] output
  )(this)).then (urls) ->
    urls.map (url) ->
      results_obj.urls.push url
    results_obj

create_tag_tree = (posts) ->
  tag_tree = {}
  posts.map (post) ->
    Object.keys(post.tags).map (tag) ->
      slug = post.tags[tag].slug
      if !tag_tree[slug]
        tag_tree[slug] =
          posts: [ post ]
          slug: slug
      else
        tag_tree[slug].posts.push post
      return
    return
  tag_tree

