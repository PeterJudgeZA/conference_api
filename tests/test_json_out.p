/*------------------------------------------------------------------------
    File        : test_json_out.p
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonObject.

define temp-table ttTalk no-undo 
    field id as character
    field name as character
    field speaker_id as character
    field abstract as character
    field talk_status as character 
    field content_url as character
    field content_type as character
    index idx1 as primary unique id
    index idx2 speaker_id
    index idx3 talk_status
    .

define temp-table ttSpeaker no-undo before-table btSpeaker
    field id as character
    field name as character
    field bio as character
    field photo as blob serialize-hidden
    field url as character
    index idx1 as primary unique id
    index idx2 name.
    

define dataset dsSpkrTlk for ttTalk, ttSpeaker
        data-relation for ttTalk, ttSpeaker relation-fields (speaker_id, id) nested.
        
        
for each Talk:
    create ttTalk.
    buffer-copy talk 
            to ttTalk
                assign ttTalk.speaker_id = talk.speaker
                       ttTalk.abstract   = substring(talk.abstract, 1, 50)
                       .
end.

for each speaker:
    create ttspeaker.
    buffer-copy speaker to ttspeaker.
end.

/* ***************************  Main Block  *************************** */
dataset dsSpkrTlk:Write-json('file', session:temp-dir + 'dsSpkrTlk.json', yes).


define variable talks as JsonObject no-undo.
define variable rowData as JsonObject no-undo.
define variable childData as JsonObject no-undo.

assign talks = new JsonObject().

for each ttTalk:
    buffer ttTalk:buffer-field('id'):serialize-hidden = true.
    
    assign rowData   = new JsonObject()
           childData = new JsonObject()
           .
    buffer ttTalk:serialize-row('JSON', 'JsonObject', rowData, true, ?, ?, yes).
    
    find first ttSpeaker where ttSpeaker.id eq ttTalk.speaker_id.
    buffer ttSpeaker:serialize-row('JSON', 'JsonObject', childData, true, ?, ?, yes).
    
    rowData:Set('speaker_id', childData).
    
    talks:Add(ttTalk.id, rowData).
end.

talks:writeFile(session:temp-dir + 'talks.json', yes).
