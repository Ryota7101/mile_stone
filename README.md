# README

I had the same issue and resolved it by adding 
before_action: authenticate_tenant! in application_controller.rb. 
Then I changed the method from before_filter to 
before_action in /config/initializers/devise_permitted_parameters.rb 
and it worked just fine!

# -----------------------------------

add 'bootstrap', '~> 4.1.3' to Gemfile and save
gem install sprockets-rails in command line of project. Version at least 2.3.2, now 3.2.1 is available
bundle install in command line of project
rename file application.css to application.scss under /app/assets/stylesheets
The only line for bootstrap is @import "bootstrap"; at file application.scss
start rails again by rails s in command line of project