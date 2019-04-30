/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : new_speaker.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
block-level on error undo, throw.

using OpenEdge.Core.Assert.

{logic/shared/speaker_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure create_speaker:
    define input  parameter pName as character no-undo.
    define output parameter pId as character no-undo.
    
    define buffer bSpkr for speaker. 
    
    Assert:NotNullOrEmpty(pName, 'speaker name').
    
    // creates a speaker, sets default values.
    create bSpkr.
    assign pId        = substitute('SPKR-&1', string(next-value(seq_name_cnt), '999'))
           bSpkr.id   = pId
           bSpkr.name = pName
           .
    // If success, a new speaker-id is returned. If failure, an error thrown
end procedure.
