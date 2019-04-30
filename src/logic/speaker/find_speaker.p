/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : find_speaker.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Main Block  ************************** */
block-level on error undo, throw.

using OpenEdge.Core.String.
using OpenEdge.Net.URI.
using Progress.Lang.AppError.

{logic/shared/speaker_dataset.i}

/* ***************************  Functions & Procedures  ************************** */
procedure get_filtered_speakers:
    define input  parameter pFilter as character no-undo.
    define input  parameter pSkipRecs as integer no-undo.
    define input  parameter pTopRecs as integer no-undo.
    define output parameter table for ttSpeaker.
    define output parameter pCount as integer no-undo.
    
    define buffer bSpeaker for Speaker.
    define query qSpeaker for bSpeaker scrolling.
    
    empty temp-table ttSpeaker.
    
    if String:IsNullOrEmpty(pFilter) then
        assign pFilter = 'true'.
    
    assign pFilter = left-trim(pFilter, 'where ').
    
    query qSpeaker:query-prepare('preselect each bSpeaker where ' + pFilter + ' no-lock ').
    query qSpeaker:query-open().
    
    if    pTopRecs le 0 
       or pTopRecs eq ?
    then
        assign pTopRecs = query qSpeaker:num-results.  
    
    if pSkipRecs eq ? then
        assign pSkipRecs =  0.
    
    query qSpeaker:reposition-forward(pSkipRecs).
    
    get next qSpeaker.
    do while     available bSpeaker
             and pCount le pTopRecs
    :
        create ttSpeaker.
        buffer-copy bSpeaker
                    except photo
                 to ttSpeaker.
        
        assign pCount = pCount + 1.
        get next qSpeaker.
    end.
    
    finally:
        close query qSpeaker.
    end finally.
end procedure.

procedure get_single_speaker:
    define input  parameter pId as character no-undo.
    define output parameter table for ttSpeaker.
    
    define buffer bSpeaker for speaker.
    
    find bSpeaker where bSpeaker.id eq pid no-lock no-error.
    if available bSpeaker then
    do:
        empty temp-table ttSpeaker.
        
        create ttSpeaker.
        buffer-copy bSpeaker
                    except photo
                 to ttSpeaker.
    end.
    else
        return error new AppError(substitute('Speaker &1 not found', pId), 0).
end procedure.

