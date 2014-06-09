# ChangeLogRb  
  
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
- copy config.yml.template to config.yml, update with your data
- `bundle install`
- `rackup -p 4567` (or for dev `shotgun config.ru`)
### What?

 - A webform will be available at /add
 - This webform will POST JSON to /add
 - You can also POST without using the webform
 - The POST will drop the message into a redis "queue"
 - You should configure logstash to pull from that queue
 
### TODO
 - webform
 - rest api key
 - cli client
 - cas-ification
 - api-key regeneration via cas'd user
