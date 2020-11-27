'use strict';

const del = require('delete');
const gulp = require('gulp');
const bust = require('gulp-buster');
const cleanCss = require('gulp-clean-css');
const elm = require('gulp-elm');
const rename = require('gulp-rename');
const sass = require('gulp-dart-sass');
const uglify = require('gulp-uglify');

// Use Dart Sass, since it supports more features than Node Sass.
sass.compiler = require('sass');

const dev = {
  /**
   * Delete all the built output.
   */
  clean() {
    return del.promise(['dist/*']);
  },

  /**
   * Build any static HTML files, and put the output in the right place.
   */
  buildHtml() {
    return gulp.src('index.html').pipe(gulp.dest('dist/'));
  },

  /**
   * Compile the Sass to CSS, and put the output in the right place.
   */
  buildSass() {
    return gulp.src(['styles/*.sass', 'styles/*.scss'])
      .pipe(sass({includePaths: 'node_modules/'}).on('error', sass.logError))
      .pipe(gulp.dest('dist/styles/'));
  },

  /**
   * Compile the Elm to JavaScript, and put the output in the right place.
   */
  buildElm() {
    return gulp.src('src/Main.elm')
      .pipe(elm())
      .pipe(rename('elm.js'))
      .pipe(gulp.dest('dist/'));
  },

  /**
   * Fingerprint the built CSS and JavaScript files, so that the browser knows
   * when it can use a cached version and when it has to request a new verison
   * from the server.
   *
   * (This task generates the hashes of our build output, and stores them in
   * `buster.json`. It doesn't actually do anything with those hashes.)
   */
  takeFingerprints() {
    return gulp.src(['dist/*.js', 'dist/styles/*.css'])
      .pipe(bust({algo: 'sha256'}))
      .pipe(gulp.dest('.'))
  }
}

const prod = {
  ...dev,

  buildSass() {
    return gulp.src(['styles/*.sass', 'styles/*.scss'])
      .pipe(sass({includePaths: 'node_modules/'}).on('error', sass.logError))
      .pipe(cleanCss())
      .pipe(gulp.dest('dist/styles/'));
  },

  buildElm() {
    return gulp.src('src/Main.elm')
      .pipe(elm({optimize: true}))
      // This is the uglify setup recommended by Elm.
      // (see https://guide.elm-lang.org/optimization/asset_size.html)
      // In particular, note that we're allowed to turn on a lot of "unsafe"
      // options because of guarantees made by the elm compiler.
      .pipe(uglify({
        compress: {
          pure_funcs: [
            ...['F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9'],
            ...['A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9'],
          ],
          pure_getters: true,
          keep_fargs: false,
          unsafe_comps: true,
          unsafe: true,
        },
        mangle: false,
      }))
      .pipe(uglify({mangle: true}))
      .pipe(rename('elm.js'))
      .pipe(gulp.dest('dist/'));
  },
};

function build(environment) {
  return gulp.series(
    // These functions are named so that Gulp can print nicer logs.
    function clean() { return environment.clean() },
    gulp.parallel(
      function buildHtml() { return environment.buildHtml() },
      function buildSass() { return environment.buildSass() },
      function buildElm() { return environment.buildElm() },
    ),
    function takeFingerprints() { return environment.takeFingerprints() },
  );
}

function watchedBuild(environment) {
  // Curry, so that watchedBuild(dev) returns a task function, and then running
  // to run that task function you have to call watchedBuild(dev)().
  return function() {
    gulp.watch(
      ["index.html", "styles/**/*", "src/**/*"],
      {ignoreInitial: false},
      build(environment),
    );
  };
}

exports.clean = dev.clean;
exports.buildDevelopment = build(dev);
exports.buildProduction = build(prod);
exports.watchDevelopment = watchedBuild(dev);
