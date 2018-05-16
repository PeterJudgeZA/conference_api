/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : read_talks.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
{logic/shared/speaker_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure get_speaker_name:
    define input  parameter pId as character no-undo.
    define output parameter pName as character no-undo.
    
    define buffer bSpeaker for speaker.
    
    find bSpeaker where bSpeaker.id eq pId no-lock no-error.
    if available bSpeaker then
        assign pName = bSpeaker.name.
end procedure.

procedure get_speaker_pic:
    define input  parameter pId as character no-undo.
    define output parameter pPic as memptr.
    
    define buffer bSpeaker for speaker.
    
    find bSpeaker where bSpeaker.id eq pid no-lock no-error.
    if available bSpeaker then
        copy-lob bSpeaker.photo to pPic.
    else
        return error new AppError(substitute('Speaker &1 not found', pId), 0).
end procedure.