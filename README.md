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
 
### What?

 - A webform will be available at /add
 - This webform will POST JSON to /api/add
 - You can also POST without using the webform
 - The POST will drop the message into a redis "queue"
 - You should configure logstash to pull from that queue
 
### Testing

 - `bundle exec guard`
 
### Client

 - Sample API POST using curl:

      `curl http://localhost:4567/api/add -X POST -H 'Content-Type: application/json' \
      -d '{"user": "snarky", "hostname": "herp.derp.edu", "criticality": 3, "description": "Added snarky comment", "body": "--Some diff--"}'`

#### Docker
You will end up with a redis instance and a changelogrb instance:
 - `docker pull redis`
 - `docker build -t changelogrb .`
 - `docker run -d --name changelogrb_redis redis`
 - `docker run -d -p 8080:8080 --name changelogrb --link changelogrb_redis:queue changelogrb`
 
### TODO
 - webform
 - rest api key
 - cli client
 - cas-ification
 - api-key regeneration via cas'd user
 - add logstash pieces to docker for demo/poc
