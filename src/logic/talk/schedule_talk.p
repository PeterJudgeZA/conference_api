/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : schedule_talk.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
{Conference/Shared/talks_dataset.i }


/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure schedule_talk:
    define input  parameter pTalk as character no-undo.
    define input  parameter pSpeaker as character no-undo.
    define input  parameter pRoom as character no-undo.
    define input  parameter pStartAt as datetime-tz no-undo.
    define input  parameter pDuration as integer no-undo.
    define output parameter pId as character no-undo.
end procedure.

procedure update_schedule:
    define input-output parameter table for ttTimeslot.
    
end procedure.