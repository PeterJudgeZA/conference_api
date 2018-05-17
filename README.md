# Conference API Example
This repo contains examples of ABL REST services for "Conference API" that's used in some PUG sessions.

This repository contains the business logic and service interfaces of an example "Conference API". The ABL business

## Project structure
The main folders are
`/db`
Contains the `conf` database and schema

`/src/logic/**`
`/src/BusinessLogic/**`
Contains ABL business logic, mainly in .P form. This code represents an existing AppServer-enabled OpenEdge application

`/src/Conference/SI/**`
Contains service interfaces, such as WebHandlers and JSON mapping files.

`/tlr/**`
Contains property and other files to tailor the install. The included `openedge.merge` file contains handler mappings and can be added to a PASOE instance using the `oeprop -f path/to/openedge.merge` command.

## Services

All the URI's here are relative to the instance and webapp. The root URI is something like `http://localhost:8830/api/`

The suggested handler configuration is in the `tlr/openedge.merge` file. This contains mappings for a hand-coded WebHandler-based approach , as well as a DataObjectHandler approach that uses the `Conference\SI\conf.map` file for mapping the individual requests. The URI's are almost identical between those approaches; the primary difference being that the DOH uses a `/web/conf/talks` prefix, and the hand-coded WebHandler uses `/web/talks`. This is so that we can have both styles in the same webapp.

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


## Testing
Once the PASOE Instance is running, you can use any client/tool capable of making GET, PUT, POST and DELETE HTTP requests that support JSON payloads.

The table above contains the URI's that are exposed and the associated business logic that's run.

The [Insomnia REST client](http://insomnia.rest/) was used to develop and test these APIs. Included in the repo is an importable set of test cases. These are in `conf/Conference_API_insomnia.json` and can be imported. [Help](https://support.insomnia.rest/article/52-importing-and-exporting-data) for this is available online.

The tests use tokens (environment variables) for the base URL (`base_url`) and webapp (`web_app`). The values for these should be changed to match your PASOE instance and webapp, and is done via the Insomnia client. [Help](https://support.insomnia.rest/article/18-environment-variables) is available online. The environment to change is the `Conference_Instance` sub-environment.
