sync = require 'browser-sync'
notify = require 'gulp-notify'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
watchify = require 'watchify'
gulpif = require 'gulp-if'
gulp = require 'gulp'

# production = false
# or you can get it with yargs or another the simular thing
args = require('yargs').argv
production = args.p or args.production

paths =
  browserify: './src/js/app.coffee'
  output: 'app.js'
  dest: './dest/'

gulp.task "watch", ["browser-sync", "watchjs"]

gulp.task "default", ["browserify"]

buildScript = (files, watch) ->
  rebundle = (callback) ->
    stream = bundler.bundle()
    stream
      .on "error", notify.onError         # optional (for gulp-notify)
        title: "Compile Error"            #
        message: "<%= error.message %>"   #
      .pipe source paths.output
      .pipe gulp.dest paths.dest
      .pipe sync.reload stream: true      # optional (for browser-sync)

    stream.on 'end', ->
      do callback if typeof callback == "function"

  props = watchify.args
  props.entries = files
  props.debug = not production

  bundler = if watch then watchify(browserify props) else browserify props
  bundler.transform "coffee-reactify" # "coffeeify" or whatever or comment it
  bundler.on "update", ->
    now = new Date().toTimeString()[..7]
    console.log "[#{now}] Starting #{"'browserify'"}..."
    startTime = new Date().getTime()
    rebundle ->
      time = (new Date().getTime() - startTime) / 1000
      now = new Date().toTimeString()[..7]
      console.log "[#{now}] Finished #{"'browserify'"} after #{(time + 's')}"

  rebundle()

gulp.task "browserify", ->                 # compile (slow)
  buildScript paths.browserify, false

gulp.task "watchjs", ->                    # watch and compile (first time slow, after fast)
  buildScript paths.browserify, true

gulp.task "browser-sync", ->
  sync
    notify: false
    open: false
    server:
      baseDir: "./dest"
    snippetOptions: rule:
      match: /<\/body>/i
      fn: (snippet, match) ->
        snippet + match

