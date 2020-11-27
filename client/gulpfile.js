'use strict';

const del = require('delete');
const gulp = require('gulp');
const bust = require('gulp-buster');
const cleanCss = require('gulp-clean-css');
const elm = require('gulp-elm');
const rename = require('gulp-rename');
const sass = require('gulp-dart-sass');
const uglify = require('gulp-uglify');

/**
 * Given a file path, return a fingerprinted version
 * of that file path.
 */
function fingerprint(filePath) {
  // TODO
}

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

  getFingerprints() {
    return gulp.src(['dist/*.js', 'dist/styles/*.css'])
      .pipe(bust({algo: 'sha256'}))
      .pipe(gulp.dest('.'))
  },

  addFingerprintsToFileNames() {
    // TODO
    return Promise.resolve();
  },

  addFingerprintsToLinks() {
    // TODO
    return Promise.resolve();
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

/**
 * Fingerprint the built CSS and JavaScript files, so that the browser knows
 * when it can use a cached version and when it has to request a new verison
 * from the server.
 *
 * Specifically, given a set of files to fingerprint, this task
 *
 * 1) For each file, calculate that file's hash.
 * 2) For each file, append that file's hash to its file name.
 * 3) For each file, change any links to that file in index.html.
 *
 * This function returns a task function.
 *
 * @param env An object, either `dev` or `prod`, which describes how to perform
 *   tasks.
 */
function fingerprintFiles(env) {
  // Make sure to bind methods to their enclosing object before we pass them
  // to gulp.series(). Otherwise, the methods won't keep a reference to their
  // enclosing object. (They won't have a value for `this`.)
  const getFingerprints = env.getFingerprints.bind(env);
  const addFingerprintsToFileNames = env.addFingerprintsToFileNames.bind(env);
  const addFingerprintsToLinks = env.addFingerprintsToLinks.bind(env);

  return gulp.series(
    getFingerprints,
    gulp.parallel(addFingerprintsToFileNames, addFingerprintsToLinks),
  );
}


/**
 * Build all of the files in the project.
 *
 * This function returns a task function.
 *
 * @param env An object, either `dev` or `prod`, which describes how to perform
 *   tasks.
 */
function build(env) {
  const clean = env.clean.bind(env);
  const buildHtml = env.buildHtml.bind(env);
  const buildSass = env.buildSass.bind(env);
  const buildElm = env.buildElm.bind(env);

  return gulp.series(
    clean,
    gulp.parallel(buildHtml, buildSass, buildElm),
    fingerprintFiles(env),
  );
}

/**
 * Listen to the filesystem, and every time one of the source files changes,
 * re-build all of the files in the project.
 *
 * This function returns a task function.
 *
 * @param env An object, either `dev` or `prod`, which describes how to perform
 *   tasks.
 */
function watchedBuild(env) {
  // Curry, so that watchedBuild(dev) returns a task function, and then running
  // to run that task function you have to call watchedBuild(dev)().
  return function() {
    gulp.watch(
      ["index.html", "styles/**/*", "src/**/*"],
      {ignoreInitial: false},
      build(env),
    );
  };
}

exports.clean = dev.clean.bind(dev);
exports.buildDevelopment = build(dev);
exports.buildProduction = build(prod);
exports.watchDevelopment = watchedBuild(dev);
