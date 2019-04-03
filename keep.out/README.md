# Conference API Example
This repo contains examples of ABL REST services for "Conference API" that's used in some PUG sessions.


## Services

All the URI's here are relative to the instance and webapp. The root URI is something like `http://localhost:8830/api/'

### Talks
These URI's are handled by the `Conference.SI.TalksWebHandler` mapped in `openedge.properties`
    handler<n>=Conference.SI.TalksWebHandler: <uri> 
where
    <n> is a sequential, contiguous integer value
    <uri> is the URI from the table below, including any tokens.
The order of the handler definitions must be from most-specific to least, so `web/talks` would be the last (highest number) defined of all the URI's that begins with `web/talks`

URI | HTTP method | Query | Body | Business logic call 
---- | ---- | ---- | ---- |---- 
web/talks | GET | filter, top, skip  | n/a |  logic/talk/read_talks.p:get_filtered_talks 
web/talks| POST | n/a | {"stream": string, "name": string } |  logic/talk/new_talk.p:new_talk
web/talks| PUT | n/a | {"speaker": string, "name": string , "abstract": string, "contentUrl": string, "contentType": string } |  logic/talk/new_talk.p:create_talk
web/talks/{talk-id} | GET | n/a | n/a |  logic/talk/read_talks.p:get_single_talk 
web/talks/{talk-id} | DELETE | n/a | n/a |  logic/talk/schedule_talk.p:cancel_scheduled_talk_by_talk 
web/talks/{talk-id} | PUT | n/a | ttTalk | logic/talk/update_talk.p:update_talks 
web/talks/{talk-id}/{stream-id} | PUT | n/a | ttTalk | logic/talk/update_talk.p:switch_stream 
web/talks/streams | GET | n/a | n/a | logic/talk/streams.p:list_streams
web/talks/{talk-id}/schedule | GET | n/a | n/a| logic/talk/list_talk_schedule.p:get_schedule

### Speakers
These URI's are handled by the `Conference.SI.SpeakersWebHandler` mapped in `openedge.properties`
    handler<n>=Conference.SI.SpeakersWebHandler: <uri> 
where
    <n> is a sequential, contiguous integer value
    <uri> is the URI from the table below, including any tokens.
The order of the handler definitions must be from most-specific to least, so `web/speakers` would be the last (highest number) defined of all the URI's that begins with `web/speakers`.


URI | HTTP method | Query | Body | Business logic call 
---- | ---- | ---- |---- |---- 
web/speakers | GET | filter, top | n/a | logic/speakers/find_speaker.p:get_filtered_speakers 
web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/find_speaker.p:get_single_speaker 
web/schedule/{speaker-id}/pic | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_name 
web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_pic 
web/schedule/{speaker-id}/talks | GET | n/a | n/a | logic/speakers/list_speaker_talks.p:get_talks  
web/schedule/ |POST| n/a | n/a | logic/speakers/new_speaker.p:create_speaker 
web/schedule/{speaker-id} | DELETE | n/a | n/a | logic/speakers/remove_speaker.p:delete_speaker 
web/schedule/{speaker-id}/pic| PUT  | n/a | n/a | logic/speakers/update_speaker.p:update_pic 
web/schedule/{speaker-id} | PUT | n/a | n/a |logic/speakers/update_speaker.p:update_speaker
web/schedule/{timeslot-id} | GET | n/a | n/a |  logic/talk/schedule_talk.p:cancel_scheduled_talk_by_id 

### Schedule

URI | HTTP method | Query | Body | Business logic call 
---- | ---- | ---- |---- |---- 
web/schedule | GET | filter, top | n/a | no-code
web/schedule | POST | n/a | {"room": string, "startAt": iso-date, 
talk": string, "duration": integer} | logic/talk/schedule_talk.p:schedule_talk

web/schedule/{timeslot-id} | GET | filter, top | n/a | no-code
web/schedule/{timeslot-id} | DELETE | n/a | n/a | logic/talk/schedule_talk.p:cancel_scheduled_talk_by_id 
web/schedule/{timeslot-id} | POST | n/a | ttTimeslot | logic/talk/schedule_talk.p:udpate_schedule

web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/find_speaker.p:get_single_speaker 
web/schedule/{speaker-id}/pic | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_name 
web/schedule/{speaker-id} | GET | n/a | n/a | logic/speakers/get_name.p:get_speaker_pic 
web/schedule/{speaker-id}/talks | GET | n/a | n/a | logic/speakers/list_speaker_talks.p:get_talks  
web/schedule/ |POST| n/a | n/a | logic/speakers/new_speaker.p:create_speaker 
web/schedule/{speaker-id} | DELETE | n/a | n/a | logic/speakers/remove_speaker.p:delete_speaker 
web/schedule/{speaker-id}/pic| PUT  | n/a | n/a | logic/speakers/update_speaker.p:update_pic 
web/schedule/{speaker-id} | PUT | n/a | n/a |logic/speakers/update_speaker.p:update_speaker
