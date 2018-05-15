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

{logic/shared/talks_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure create_talk:
    define input  parameter pStream as character no-undo.
    define input  parameter pName as character no-undo.
    define output parameter pId as character no-undo.
    
    define buffer bTalk for talk. 
    
    Assert:NotNullOrEmpty(pStream, 'Talk stream').
    Assert:NotNullOrEmpty(pName, 'Talk name').
    
    // creates a talk, sets default values.
    create bTalk.
    assign pId               = substitute('&1-&2', pStream, string(next-value(seq_name_cnt), '999'))
           bTalk.id          = pId
           bTalk.name        = pName
           bTalk.talk_status = TalkStatusEnum:Submitted:ToString()
           .
    // If success, a new talk-id is returned. If failure, an error thrown
end procedure.
