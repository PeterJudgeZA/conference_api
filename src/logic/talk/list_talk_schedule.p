/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : new_talk.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

using Conference.BusinessLogic.TalkStatusEnum.
using OpenEdge.Core.Assert.
using Progress.Lang.AppError.
using OpenEdge.Core.String.

{logic/shared/talks_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure get_schedule:
    define input  parameter pId as character no-undo.
    define output parameter table for ttTimeslot.
    
    define buffer bSlot for timeslot.
    define buffer bTalk for talk. 
    
    Assert:NotNullOrEmpty(pId, 'Talk ID').
    
    if not can-find(bTalk where bTalk.id eq pId) then
        return error new AppError(substitute('Talk &1 not found1', pId), 0).
        
    empty temp-table ttTimeslot.
    
    for each bSlot where bSlot.talk eq pId:
        create ttTimeslot.
        buffer-copy bSlot to ttTimeslot.
    end.
end procedure.