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
using logic.FilterResponse.

{logic/shared/talks_dataset.i }

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

procedure read_param_filter_response:
    define input parameter pParams as FilterParams no-undo.
    define output parameter table for ttTalk.
    define output parameter pResp as FilterResponse no-undo.
    
    define variable cnt as integer no-undo.
    
    Assert:NotNull(pParams, 'Filter params').
    
    run get_filtered_talks (pParams:Where,
                            pParams:SkipRecs,
                            pParams:TopRecs,
                            output table ttTalk,
                            output cnt).
    
    assign pResp             = new FilterResponse()
           pResp:NumRecs     = cnt
           pResp:IsLastBatch = false
           pResp:TableName   = buffer ttTalk:serialize-name
           .
end procedure.

procedure get_filtered_talks:
    define input  parameter pFilter as character no-undo.
    define input  parameter pSkipRecs as integer no-undo.
    define input  parameter pTopRecs as integer no-undo.
    define output parameter table for ttTalk.
    define output parameter pCount as integer no-undo.
    
    define buffer bTalk for talk.
    define buffer bSpkr for speaker.
    define query qTalk for bTalk, bSpkr scrolling.
    
    empty temp-table ttTalk.
    
    assign pFilter = left-trim(pFilter, 'where ').
    
    if String:IsNullOrEmpty(pFilter) then
        assign pFilter = 'true'.
    
    query qTalk:query-prepare('preselect each bTalk where ' + pFilter + ' no-lock, first bSpkr where bSpkr.id eq bTalk.speaker no-lock').
    query qTalk:query-open().
    
    if    pTopRecs le 0
       or pTopRecs eq ?
    then
        assign pTopRecs = query qTalk:num-results.  
    
    if pSkipRecs eq ? then
        assign pSkipRecs = 0.
    
    query qTalk:reposition-forward(pSkipRecs).
    
    get next qTalk.
    do while     available bTalk
             and pCount lt pTopRecs
    :
        create ttTalk.
        buffer-copy bTalk 
                    except speaker
                to ttTalk
                    assign ttTalk.speaker = bSpkr.name.
        
        assign pCount = pCount + 1.
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
    define buffer bSpkr for speaker.
    
    find bTalk where bTalk.id eq pid no-lock no-error.
    if available bTalk then
    do:
        empty temp-table ttTalk.
        
        find bSpkr where bSpkr.id eq bTalk.speaker no-lock.    
        
        create ttTalk.
        buffer-copy bTalk 
                    except speaker
                to ttTalk
                    assign ttTalk.speaker = bSpkr.name.
    end.
    else
        return error new AppError(substitute('Talk &1 not found', pId), 0).
end procedure.

/* EOF */