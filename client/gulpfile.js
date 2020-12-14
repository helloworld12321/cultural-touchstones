'use strict';

let fs = require('fs');
let path = require('path');

const bach = require('bach');
const chalk = require('chalk');
let del = require('delete');
const log = require('fancy-log');
const gulp = require('gulp');
const cleanCss = require('gulp-clean-css');
const sass = require('gulp-dart-sass');
const elm = require('gulp-elm');
const fingerprint = require('gulp-fingerprint');
const rename = require('gulp-rename');
const rev = require('gulp-rev');
const uglify = require('gulp-uglify');

fs = fs.promises;
path = path.posix;
del = del.promise;

/**
 * Set the 'last accessed' and 'last modified' times of a file to right now.
 */
async function touch(filePath) {
  const now = new Date();
  await fs.utimes(filePath, now, now);
}


const dev = {
  name: 'development',
  buildOutput: ['dist/*', 'build/*'],

  /**
   * Delete all the built output.
   */
  async clean() {
    await del(this.buildOutput);
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

  async fingerprintFiles() {
    log.info(
      chalk`In dev mode; {bgYellow skipping} step {cyan fingerprintFiles}`
    );
  },
}

const prod = {
  ...dev,

  name: 'production',
  fingerprintsJsonFile: 'fingerprints.json',

  get buildOutput() {
    return ['dist/*', 'build/*', this.fingerprintsJsonFile];
  },

  /**
   * Build any static HTML files, and put the output in the right place.
   */
  buildHtml() {
    return gulp.src('index.html').pipe(gulp.dest('build/'));
  },


  buildSass() {
    return gulp.src(['styles/*.sass', 'styles/*.scss'])
      .pipe(sass({includePaths: 'node_modules/'}).on('error', sass.logError))
      .pipe(cleanCss())
      .pipe(gulp.dest('build/styles/'));
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
      .pipe(gulp.dest('build/'));
  },

  fingerprintFiles(done) {
    // Use () => {} functions, so that we have access to `this`.
    const takeHashes = () => {
      return gulp.src(['build/*.js', 'build/styles/*.css'], {base: 'build'})
        .pipe(rev())
        .pipe(gulp.dest('dist/'))
        .pipe(rev.manifest(this.fingerprintsJsonFile))
        .pipe(gulp.dest('.'));
    }

    const editLinks = () => {
      return gulp.src(['build/*.html'])
        .pipe(fingerprint(this.fingerprintsJsonFile, {verbose: true}))
        .pipe(gulp.dest('dist/'))
    };

    // gulp-fingerprint doesn't actually set the 'last accessed' and 'last
    // modified' dates of the files it outputs, so we have to do that
    // ourselves.
    const touchFiles = async () => {
      // Get all the 'build/*.html' files, just like we did before.
      const fileNames = (await fs.readdir('build'))
        .filter(name => name.match(/\.html$/));

      // Then, touch the corresponding files in the 'dist' directory.
      await Promise.all(
        fileNames.map(name => touch(path.join('dist', name)))
      );
    }

    bach.series(takeHashes, editLinks, touchFiles)(done);
  },
};

/**
 * Build all of the files in the project.
 *
 * This function returns a task function.
 *
 * @param env An object, either `dev` or `prod`, which describes how to perform
 *   tasks.
 */
function build(env) {
  const buildHtml = env.buildHtml.bind(env);
  const buildSass = env.buildSass.bind(env);
  const buildElm = env.buildElm.bind(env);
  const fingerprintFiles = env.fingerprintFiles.bind(env);

  return async function() {
    log.info(chalk`Building in {green ${env.name}} mode`);
    gulp.series(
      gulp.parallel(buildHtml, buildSass, buildElm),
      fingerprintFiles,
    )();
  };
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

exports.cleanDevelopment = dev.clean.bind(dev);
exports.cleanProduction = prod.clean.bind(prod);
exports.buildDevelopment = build(dev);
exports.buildProduction = build(prod);
exports.watchDevelopment = watchedBuild(dev);
