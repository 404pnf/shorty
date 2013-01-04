# Shorty - a simple url shortener, based on sinatra and redis

# Run locally
* Start redis
* Change the redis url in shorty.rb and install deps via bundler
* `ruby shorty.rb`

# Run on heroku
```
heroku create
heroku addons:add redistogo:nano
git push heroku master
```
