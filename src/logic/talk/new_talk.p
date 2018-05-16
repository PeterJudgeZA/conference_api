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
procedure new_talk:
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

procedure create_talk:
    define input  parameter pName as character no-undo.
    define input  parameter pSpeaker as character no-undo.
    define input  parameter pAbstract as character no-undo.
    define input  parameter pContentUrl as character no-undo.
    define input  parameter pContentType as character no-undo.
    define output parameter pId as character no-undo.
    
    define buffer bTalk for talk.
    define buffer bSpeaker for speaker.
    
    // Validate Speaker exists
    if     not String:IsNullOrEmpty(pSpeaker)
       and not can-find(bSpeaker where bSpeaker.id eq pSpeaker)
    then
        return error new AppError(substitute('Speaker &1 does not exist', pSpeaker), 0).
    
    run new_talk ('NON', pName, output pId).
    
    find bTalk where bTalk.id eq pId exclusive-lock no-error.
    assign bTalk.speaker      = pSpeaker
           bTalk.abstract     = pAbstract
           bTalk.content_type = pContentType 
           bTalk.content_url  = pContentUrl
           .
    // If success, a new talk-id is returned. If failure, an error thrown           
end procedure.