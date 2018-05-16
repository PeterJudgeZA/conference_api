&if false &then
/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : logic/shared/talks_dataset.i
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
&endif
define {&ACCESS-LEVEL} temp-table ttTalk no-undo before-table btTalk
    field id as character
    field name as character
    field speaker as character
    field abstract as character
    field talk_status as character 
    field content_url as character
    field content_type as character                 // mime-type (PDF, Powerpoint etc)
    index idx1 as primary unique id
    index idx2 speaker
    index idx3 talk_status
    .

define {&ACCESS-LEVEL} temp-table ttTimeslot no-undo before-table btTimeslot
    field id as character
    field talk as character
    field room as character
    field start_at as datetime-tz
    field duration as integer
    index idx1 as primary unique id
    index idx2 as unique room start_at
    index idx3 talk
    .

define {&ACCESS-LEVEL} dataset dsTalk for ttTalk, ttTimeslot
    data-relation for ttTalk, ttTimeslot relation-fields (id, talk)    nested
    .
    