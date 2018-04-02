# AwesomeTracer

OK, wow, it's been about four years since the last commit so I'm having more trouble than I'm willing to admit getting this code back in working condition. Anyways here's a short description of what I'm trying to achieve with this library.

AwesomeTracer is one part of an open source project called Spectocular. Spec as in RSpec, Ocular as in 'of the eye' and Spectocular as in SPECTACULAR! In short, Spectocular gives the user a beautiful browser frontend for their specs. As the specs run the browser shows exactly where we are in the Red-Green-Refactor cycle. Failing example groups and individual tests are highlighted as they run. Code coverage reports are shown *live*. In **deep-scan** mode, the tracer keeps track of every variable as the code is executing so debugging becomes super simple.

Once all tests are green, Spectocular fetches the code complexity report (rubocop or whatever) and then guides the developer through the refactoring again using the test status as a guide. Once the tests are green again, one is ready to commit!

This is even better than tools like CodeClimate because the analysis and evaluation happens before committing to github, when it's really useful.

If I can just get this running I can make a screencast to show what it looks like, but alas!

In terms of the frontend, I'd used Angular 1 but am open to throwing it all away and starting over with React, Reason or Elm (or anything really)

# Get started

After `bundle install` etc, start the Faye server
```
 bundle exec rackup config.ru -E production -p 9292 -s thin
 ```

Start Sinatra
```bundle exec ruby server.rb```

Run some specs

```
bundle exec rspec --require rspec/legacy_formatters --require ./lib/awesome_tracer/faye_formatter.rb --format FayeFormatter spec/lib/awesome_tracer_spec.rb```
