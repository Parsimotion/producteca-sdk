"use strict"

require("coffee-script/register")
#[^] last version of coffee

module.exports = (grunt) ->
  #-------
  #Plugins
  #-------
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-mocha-test"

  #-----
  #Tasks
  #-----
  grunt.registerTask "default", "test" 
  grunt.registerTask "test", "mochaTest"
  grunt.registerTask "build", ["clean:build", "coffee", "clean:specs"]

  #------
  #Config
  #------
  grunt.initConfig
    #Clean build directory
    clean:
      build: src: "build"
      specs: src: "build/*.spec.js"

    #Compile coffee
    coffee:
      compile:
        expand: true
        cwd: "#{__dirname}/src"
        src: ["**/{,*/}*.coffee"]
        dest: "build/"
        rename: (dest, src) ->
          dest + "/" + src.replace(/\.coffee$/, ".js")

    # Run tests
    mochaTest:
      options:
        reporter: "spec"
      src: ["src/**/*.spec.coffee"]