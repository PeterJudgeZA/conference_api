/*------------------------------------------------------------------------
    File        : create_records.p
    Purpose     : Load initial records into the database tables
    Description : 
    Author(s)   : Dustin Grau
    Created     : Thu Apr 18 10:31:28 EDT 2019
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

/* ***************************  Main Block  *************************** */

current-value(seq_name_cnt) = 1. /* Reset Sequence */

/* Delete Old Records */

for each attendee exclusive-lock:
    delete attendee.
end.

for each rating exclusive-lock:
    delete rating.
end.

for each room exclusive-lock:
    delete room.
end.

for each speaker exclusive-lock:
    delete speaker.
end.

for each talk exclusive-lock:
    delete talk.
end.

for each timeslot exclusive-lock:
    delete timeslot.
end.

/* Create New Records */

define variable cRoomID as character no-undo.
define variable cSchdID as character no-undo.
define variable cSpkrID as character no-undo.
define variable cTalkID as character no-undo.
define variable cStream as character no-undo initial "ABL". /* Default category for all talks. */

do:
    create room.
    assign cRoomID = substitute("RM-&1", string(next-value(seq_name_cnt), "999")).
    assign
        room.id       = cRoomID
        room.name     = "Orlando"
        room.capacity = 100
        .
    release room.
end.

do:
    assign
        cSpkrID = substitute("SPKR-&1", string(next-value(seq_name_cnt), "999"))
        cTalkID = substitute("&1-&2", cStream, string(next-value(seq_name_cnt), "999"))
        cSchdID = substitute("SLOT-&1", string(next-value(seq_name_cnt), "999"))
        .

    create speaker.
    assign
        speaker.id    = cSpkrID
        speaker.name  = "Bob Loblaw"
        speaker.bio   = ""
        speaker.url   = ""
        speaker.photo = ?
        .

    create talk.
    assign
        talk.id          = cTalkID
        talk.speaker     = cSpkrID
        talk.name        = "Modern OO-ABL"
        talk.talk_status = "Scheduled"
        .

    create timeslot.
    assign
        timeslot.id       = cSchdID
        timeslot.talk     = cTalkID
        timeslot.room     = cRoomID
        timeslot.duration = 60
        timeslot.start_at = datetime-tz(5, 6, year(today), 10, 0, 0)
        .

    release speaker.
    release talk.
    release timeslot.
end.

do:
    assign
        cSpkrID = substitute("SPKR-&1", string(next-value(seq_name_cnt), "999"))
        cTalkID = substitute("&1-&2", cStream, string(next-value(seq_name_cnt), "999"))
        cSchdID = substitute("SLOT-&1", string(next-value(seq_name_cnt), "999"))
        .

    create speaker.
    assign
        speaker.id    = cSpkrID
        speaker.name  = "Manny Werds"
        speaker.bio   = ""
        speaker.url   = ""
        speaker.photo = ?
        .

    create talk.
    assign
        talk.id          = cTalkID
        talk.speaker     = cSpkrID
        talk.name        = "CI/CD Pipelines"
        talk.talk_status = "Scheduled"
        .

    create timeslot.
    assign
        timeslot.id       = cSchdID
        timeslot.talk     = cTalkID
        timeslot.room     = cRoomID
        timeslot.duration = 60
        timeslot.start_at = datetime-tz(5, 6, year(today), 12, 0, 0)
        .

    release speaker.
    release talk.
    release timeslot.
end.

do:
    assign
        cSpkrID = substitute("SPKR-&1", string(next-value(seq_name_cnt), "999"))
        cTalkID = substitute("&1-&2", cStream, string(next-value(seq_name_cnt), "999"))
        cSchdID = substitute("SLOT-&1", string(next-value(seq_name_cnt), "999"))
        .

    create speaker.
    assign
        speaker.id    = cSpkrID
        speaker.name  = "Chatty Khathie"
        speaker.bio   = ""
        speaker.url   = ""
        speaker.photo = ?
        .

    create talk.
    assign
        talk.id          = cTalkID
        talk.speaker     = cSpkrID
        talk.name        = "Cloud Monitoring"
        talk.talk_status = "Scheduled"
        .

    create timeslot.
    assign
        timeslot.id       = cSchdID
        timeslot.talk     = cTalkID
        timeslot.room     = cRoomID
        timeslot.duration = 60
        timeslot.start_at = datetime-tz(5, 6, year(today), 14, 0, 0)
        .

    release speaker.
    release talk.
    release timeslot.
end.
