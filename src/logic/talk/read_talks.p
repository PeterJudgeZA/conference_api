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

using Conference.BusinessLogic.TalkStatusEnum.
using OpenEdge.Net.URI.
using Progress.Lang.AppError.
using OpenEdge.Core.String.

{Conference/Shared/talks_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure get_filtered_talks:
    define input  parameter pFilter as character no-undo.
    define input  parameter pSkipRecs as integer no-undo.
    define input  parameter pTopRecs as integer no-undo.
    define output parameter table for ttTalk.
    define output parameter pCount as integer no-undo.
    
    define variable cnt as integer no-undo.
    define buffer bTalk for talk.
    define query qTalk for bTalk.
    
    empty temp-table ttTalk.
    
    if String:IsNullOrEmpty(pFilter) then
        assign pFilter = 'true'.
    
    query qTalk:query-prepare('preselect each bTalk where ' + pFilter + ' no-lock ').
    query qTalk:query-open().
    
    assign pCount = query qTalk:num-results.
    
    if    pTopRecs le 0 
       or pTopRecs eq ?
    then
        assign pTopRecs = pCount.  
    
    if not pSkipRecs eq ? 
       and pSkipRecs gt 0
    then
        query qTalk:reposition-forward(pSkipRecs).
    
    get next qTalk.
    do while     available bTalk
             and cnt le pTopRecs
    :
        create ttTalk.
        buffer-copy bTalk
                    except talk_status content_url  
                 to ttTalk
                    assign ttTalk.talk_status = TalkStatusEnum:GetEnum(bTalk.talk_status)
                           ttTalk.content_url = URI:Parse(bTalk.content_url)
                           
                           cnt                = cnt + 1.
        get next qTalk.
    end.
    
    finally:
        close query qTalk.
    end finally.
end procedure.

procedure get_single_talk:
    define input  parameter pId as character no-undo.
    define output parameter table for ttTalk.
    
    define buffer bTalk for talk.
    
    find bTalk where bTalk.id eq pid no-lock no-error.
    if available bTalk then
    do:
        empty temp-table ttTalk.
        
        create ttTalk.
        buffer-copy bTalk
                    except talk_status content_url  
                 to ttTalk
                    assign ttTalk.talk_status = TalkStatusEnum:GetEnum(bTalk.talk_status)
                           ttTalk.content_url = URI:Parse(bTalk.content_url) 
                           .
    end.
    else
        return error new AppError(substitute('Talk &1 not found', pId), 0).
end procedure.

/* EOF */