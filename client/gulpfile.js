'use strict';

const del = require('delete');
const gulp = require('gulp');
const cleanCss = require('gulp-clean-css');
const elm = require('gulp-elm');
const rename = require('gulp-rename');
const sass = require('gulp-dart-sass');
const uglify = require('gulp-uglify');

// Use Dart Sass, since it supports more features than Node Sass.
sass.compiler = require('sass');

function clean() {
  return del.promise(['dist/*']);
}

const dev = {
  buildHtml() {
    return gulp.src('index.html').pipe(gulp.dest('dist/'));
  },

  buildSass() {
    return gulp.src(['styles/*.sass', 'styles/*.scss'])
      .pipe(sass({includePaths: 'node_modules/'}).on('error', sass.logError))
      .pipe(gulp.dest('dist/styles/'));
  },

  buildElm() {
    return gulp.src('src/Main.elm')
      .pipe(elm())
      .pipe(rename('elm.js'))
      .pipe(gulp.dest('dist/'));
  },
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
    clean,
    gulp.parallel(
      // These functions are named so that Gulp can print nicer logs.
      function buildHtml() { return environment.buildHtml() },
      function buildSass() { return environment.buildSass() },
      function buildElm() { return environment.buildElm() },
    ),
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

exports.clean = clean;
exports.buildDevelopment = build(dev);
exports.buildProduction = build(prod);
exports.watchDevelopment = watchedBuild(dev);