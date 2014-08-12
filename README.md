# ChangeLogRb  
[![Build Status](https://travis-ci.org/fishnix/changelogrb.svg?branch=master)](https://travis-ci.org/fishnix/changelogrb)
  
A very simple app to act as a frontend to logstash for my group's Changelogs.

This was inspired by the [changelog](https://github.com/prezi/changelog) app by [prezi.com](http://prezi.com)

### Requirements
  
- bundler 
- redis-server 
- logstash infrastructure

### Why?
  
  - prezi's app was missing the ability to add large message fields (ie. copypasta of terminal output)
  - we wanted to leverage existing logstash knowledge and infrastructure
  
### How?  

- git clone
- edit config.yml with your data, modify the JSON schema if necessary
- `bundle install`
- `rackup -p 4567` (or for dev `shotgun config.ru`)
- `bundle exec unicorn -c config/unicorn.rb`
 
### What?

 - A webform will be available at /add
 - This webform will POST JSON to /api/add
 - You can also POST without using the webform
 - The POST will drop the message into a redis "queue"
 - You should configure logstash to pull from that queue
 
### Testing

 - `bundle exec guard`
 
### Client

 - Sample API POST using curl

 ```
 curl http://localhost:4567/api/add -X POST -H 'Content-Type: application/json' \
 -d '{"user": "snarky", "hostname": "herp.derp.edu", "criticality": 3, "description": "Added snarky comment", "body": "--Some diff--"}'
 ```
 
 - Using the shell client (will open editor so you can paste the body of your change)
 
 ```
 $ ./client/changelog.sh -u snarky -h herp.derp.edu -c 3 -d "Added snarky comment"
 {"status":200,"message":"Success"}
 ```
 
### Docker

Use docker to quickly spin up a complete POC environment for ChangeLogRb.
You will end up with a redis, logstash/es/kibana, and a changelogrb instance:
 - `docker pull redis`
 - `docker pull pblittle/docker-logstash`
 - `docker build -t changelogrb .`
 - `docker run -d --name changelogrb_redis redis`
 - `docker run -d --name changelogrb -p 8080:8080 --link changelogrb_redis:queue changelogrb`
 - `docker run -d --name changelogrb_logstash -p 9200:9200 -p 9292:9292 -e LOGSTASH_CONFIG_URL=https://raw.githubusercontent.com/fishnix/changelogrb/master/docker/logstash.conf --link changelogrb_redis:queue pblittle/docker-logstash`

The app should be accessible at http://localhost:8080
Kibana web interface at http://localhost:9292
 
### TODO
 - rest api key
 - api-key regeneration via cas'd user
 - ruby cli client

