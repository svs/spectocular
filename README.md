# AwesomeTracer

## The vision
AwesomeTracer is one part of an open source project called Spectocular. Spec as in RSpec, Ocular as in 'of the eye' and Spectocular as in SPECTACULAR! 

In short, Spectocular gives the user a beautiful browser frontend for their specs. As the specs run the browser shows exactly where we are in the Red-Green-Refactor cycle. Failing example groups and individual tests are highlighted as they run. Code coverage reports are shown *live*. In **deep-scan** mode, the tracer keeps track of every variable as the code is executing so debugging becomes super simple.

Once all tests are green, Spectocular fetches the code complexity report (rubocop or whatever) and then guides the developer through the refactoring again using the test status as a guide. Once the tests are green again, one is ready to commit!

This is even better than tools like CodeClimate because the analysis and evaluation happens before committing to github, when it's really useful.

# The condition
The frontend is a *really basic* Angular 1 app (it was hot back then!). The essential problem of piping RSpec output to a browser has been solved by AwesomeTracer. Now the frontend is free to do whatever it wants with this information. AwesomeTracer sends the following data to the browser

* RSpec test output
* Files touched by the spec
* Lines of the file touched by the spec

This is enough to show test status and coverage. See the totally basic screenshot below

![spectocular](https://cdn.pbrd.co/images/Hf5J6mi.png)

In terms of the frontend, I'd used Angular 1 but am open to throwing it all away and starting over with React, Reason or Elm (or anything really)

# The mission

To build an amazing guide and helper to help developers of all levels to write the best, test-driven code possible.

# Instructions

After `bundle install` etc, start the Faye server
```
 bundle exec rackup config.ru -E production -p 9292 -s thin
 ```

Start Sinatra
```bundle exec ruby server.rb```

Run some specs

```
bundle exec rspec --require ./lib/awesome_tracer/fay3_formatter.rb --format Fay3Formatter spec/lib/awesome_tracer_spec.rb```
