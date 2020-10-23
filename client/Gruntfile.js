module.exports = function(grunt) {
  const config = {};

  config.clean = [
    'dist/',
  ];

  config.copy = {};
  config.copy.development = config.copy.production = {
    files: {
      'dist/index.html': 'index.html',
    },
  };

  config.elm = {};
  config.elm.development = {
    files: {
      'dist/elm.js': 'src/Main.elm',
    },
    options: {
      // --yes doesn't work on new versions of Elm.
      yes: false,
    }
  };
  config.elm.production = {
    ...config.elm.development,
    options: {
      optimize: true,
      yes: false,
    },
  }

  config.sass = {};
  config.sass.development = config.sass.production = {
    files: [{
      expand: true,
      cwd: 'styles',
      src: ['*.sass', '*.scss'],
      dest: 'dist/styles',
      ext: '.css',
    }],
    options: {
      loadPath: 'node_modules',
    },
  };

  // TODO: add minification for production.

  grunt.initConfig(config);

  grunt.registerTask('build', environment => {
    environment = environment || 'development';
    switch (environment) {
      case 'development':
      case 'dev':
        environment = 'development';
        break;
      case 'production':
      case 'prod':
        environment = 'production';
        break;
      default:
        throw new Error(
          `${this.name}: Unrecognized environment: ${environment}`,
        );
    }
    grunt.task.run('clean');
    grunt.file.mkdir('dist');
    grunt.task.run(`copy:${environment}`);
    grunt.task.run(`sass:${environment}`);
    grunt.task.run(`elm:${environment}`);
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-elm');
}
