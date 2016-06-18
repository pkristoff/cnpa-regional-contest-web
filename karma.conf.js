// Karma configuration
// Generated on Thu Jun 16 2016 10:56:49 GMT-0400 (EDT)

// http://www.yearofmoo.com/2013/01/full-spectrum-testing-with-angularjs-and-karma.html#two-types-of-tests-in-angularjs

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],


    // list of files / patterns to load in the browser
    files: [
        //3rd Party Code
        'bower_components/jquery/dist/jquery.js',
        'bower_components/angular/angular.js',
        'bower_components/angular-mocks/angular-mocks.js',
        'bower_components/angular-route/angular-route.js',
        'bower_components/angular-touch/angular-touch.js',
        'bower_components/angular-bootstrap/ui-bootstrap-tpls.js',
        'bower_components/bootstrap/dist/js/bootstrap.js',
        // 'app/scripts/lib/router.js',

        //App-specific Code
        // 'app/assets/javascripts/config/config.js',
        'app/assets/javascripts/app.js',
        'app/assets/javascripts/services/**/*.js',
        'app/assets/javascripts/directives/**/*.js',
        'app/assets/javascripts/controllers/**/*.js',
        // 'app/assets/javascripts/filters/**/*.js',
        // 'app/assets/javascripts/config/routes.js',
        // 'app/assets/javascripts/app.coffee',

        //Test-Specific Code
      // 'test-main.js'
        'spec/angular/**/*-spec.js'
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity
  });
};
