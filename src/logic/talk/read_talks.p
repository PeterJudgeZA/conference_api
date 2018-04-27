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
using OpenEdge.Core.Assert.
using OpenEdge.Core.String.
using OpenEdge.Net.URI.
using Progress.Lang.AppError.
using logic.FilterParams.

{Conference/Shared/talks_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure read_param_filter:
    define input parameter pParams as FilterParams no-undo.
    define output parameter table for ttTalk.
    define output parameter pCount as integer no-undo.
    
    Assert:NotNull(pParams, 'Filter params').
    run get_filtered_talks (pParams:Where,
                            pParams:SkipRecs,
                            pParams:TopRecs,
                            output table ttTalk,
                            output pCount).
end procedure.

procedure get_filtered_talks:
    define input  parameter pFilter as character no-undo.
    define input  parameter pSkipRecs as integer no-undo.
    define input  parameter pTopRecs as integer no-undo.
    define output parameter table for ttTalk.
    define output parameter pCount as integer no-undo.
    
    define buffer bTalk for talk.
    define query qTalk for bTalk scrolling.
    
    empty temp-table ttTalk.
    
    if String:IsNullOrEmpty(pFilter) then
        assign pFilter = 'true'.
    
    query qTalk:query-prepare('preselect each bTalk where ' + pFilter + ' no-lock ').
    query qTalk:query-open().
    
    if    pTopRecs le 0 
       or pTopRecs eq ?
    then
        assign pTopRecs = query qTalk:num-results.  
    
    if pSkipRecs eq ? then
        assign pSkipRecs =  0.
    
    query qTalk:reposition-forward(pSkipRecs).
    
    get next qTalk.
    do while     available bTalk
             and pCount le pTopRecs
    :
        create ttTalk.
        buffer-copy bTalk
                    except talk_status content_url  
                 to ttTalk
                    assign ttTalk.talk_status = TalkStatusEnum:GetEnum(bTalk.talk_status)
                           ttTalk.content_url = URI:Parse(bTalk.content_url)                when bTalk.content_url ne ''
                           
                           pCount                = pCount + 1.
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
                           ttTalk.content_url = URI:Parse(bTalk.content_url)              when bTalk.content_url ne ''
                           .
    end.
    else
        return error new AppError(substitute('Talk &1 not found', pId), 0).
end procedure.

/* EOF */