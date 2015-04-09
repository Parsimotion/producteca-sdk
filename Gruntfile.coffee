"use strict"

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
  grunt.registerTask "build", ["clean", "coffee"]

  #------
  #Config
  #------
  grunt.initConfig
    #Clean build directory
    clean: ["build"]

    #Compile coffee
    coffee:
      compile:
        expand: true
        cwd: "#{__dirname}/src"
        src: ["**/*.coffee"]
        dest: "build/"
        ext: ".js"

    # Run tests
    mochaTest:
      options:
        reporter: "spec"
      src: ["src/**/*.spec.coffee"]