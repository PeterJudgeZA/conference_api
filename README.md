# Conference API Example
This repo contains examples of ABL REST services for "Conference API" that's used in some PUG sessions.


## Services

All the URI's here are relative to the instance and webapp. The root URI is something like `http://localhost:8830/api/'

###Talks

URI | HTTP method | Query | Body | Business logic call 
---- | ---- | ---- | ---- |---- 
web/talks | GET | filter, top | n/a |  logic/talks/read_talks.p:get_filtered_talks 
web/talks | GET | filter, top | n/a |  logic/talks/read_talks.p:get_single_talk 
web/talks| GET  | filter, top | n/a |  logic/talks/read_talks.p:read_param_filter 
web/talks | GET | filter, top | n/a |  logic/talks/read_talks.p:read_param_filter_response 
web/talks | GET | n/a | n/a |  logic/talks/schedule_talk.p:cancel_scheduled_talk_by_id 
web/talks | GET | n/a | n/a |  logic/talks/schedule_talk.p:cancel_scheduled_talk_by_talk 
web/talks | GET | n/a | n/a |  logic/talks/schedule_talk.p:schedule_talk 
web/talks | GET | n/a | n/a |  logic/talks/schedule_talk.p:update_schedule 
web/talks/{talk-id} | DELETE | n/a | n/a | logic/talks/update_talk.p:cancel_talk 
web/talks/{talk-id} | GET | n/a | n/a | logic/talks/update_talk.p:set_talk_status 
web/talks/{talk-id} | GET | n/a | n/a | logic/talks/update_talk.p:update_talks 
web/talks/streams | GET | n/a | n/a | logic/talk/streams.p:list_streams 

###Speakers

URI | HTTP method | Query | Body | Business logic call 
---- | ---- | ---- |---- |---- 
web/schedule | GET | filter, top | n/a | logic/speakers/find_speaker.p:get_filtered_speakers 
web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/find_speaker.p:get_single_speaker 
web/schedule/{speaker-id}/pic | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_name 
web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_pic 
web/schedule/{speaker-id}/talks | GET | n/a | n/a | logic/speakers/list_speaker_talks.p:get_talks  
web/schedule/ |POST| n/a | n/a | logic/speakers/new_speaker.p:create_speaker 
web/schedule/{speaker-id} | DELETE | n/a | n/a | logic/speakers/remove_speaker.p:delete_speaker 
web/schedule/{speaker-id}/pic| PUT  | n/a | n/a | logic/speakers/update_speaker.p:update_pic 
web/schedule/{speaker-id} | PUT | n/a | n/a |logic/speakers/update_speaker.p:update_speaker
