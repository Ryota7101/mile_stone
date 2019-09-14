# README

これはポートフォリオ用にRuby on Railsで開発したプロジェクト管理アプリケーションです。

Qiitaにアプリの詳細説明を記載しております。
https://qiita.com/Ryota7101/items/ddb6a85c28c71c1f79e3

![image](https://user-images.githubusercontent.com/35439050/63206924-b99ce380-c0f8-11e9-8288-ce2156f3bd05.png)

![image](https://user-images.githubusercontent.com/35439050/63206960-945ca500-c0f9-11e9-9f04-0429c11e3813.png)



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

# -----------------------------------




# -----------------------------------

user.rb add
has_one :member, :dependent => :destroy

# ------------------------------------
