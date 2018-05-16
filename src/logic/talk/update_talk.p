/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : update_talk.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
using Conference.BusinessLogic.TalkStatusEnum.
using OpenEdge.Core.Assert.
using Progress.Lang.AppError.

{logic/shared/talks_dataset.i }

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure set_talk_status:
    define input parameter pTalk as character no-undo.
    define input parameter pStatus as TalkStatusEnum no-undo.
    
    define buffer bTalk for talk.
    define buffer bSlot for timeslot.
    
    Assert:NotNullOrEmpty(pTalk, 'Talk id').
    
    find bTalk where bTalk.id eq pTalk exclusive-lock no-error.
    if available bTalk then
    case pStatus:
        // if we have any scheduled talks, we cannot cancel move off the existing status
        when TalkStatusEnum:Cancelled or
        when TalkStatusEnum:Rejected or
        when TalkStatusEnum:Accepted then
            if not can-find(first bSlot where bSlot.talk eq bTalk.id) then
                assign bTalk.talk_status = pStatus:ToString().
        otherwise 
            assign bTalk.talk_status = pStatus:ToString().
    end case.
    else
        return error new AppError(substitute('Talk &1 not found', pTalk), 0).
end procedure.

procedure switch_stream:
    define input parameter pTalk as character no-undo.
    define input parameter pStream as character no-undo.
    
    define variable newTalkId as character no-undo.
    define buffer bTalk for talk. 
    
    Assert:NotNullOrEmpty(pStream, 'Talk stream').
    Assert:NotNullOrEmpty(pTalk, 'Talk ID').
    
    assign newTalkId                  = pTalk
           entry(1, newTalkId, '-':u) = pStream
           .
    if can-find(bTalk where bTalk.id eq newTalkId) then
        return error new AppError(substitute('Talk found with new id &1', newTalkId), 0).
    
    find bTalk where bTalk.id eq pTalk exclusive-lock no-error.
    if available bTalk then
        assign bTalk.id = newTalkId.
    else
        return error new AppError(substitute('Talk &1 not found', pTalk), 0).
end procedure.

procedure update_talks:
    define input-output parameter table for ttTalk.
    
    define variable updateError as AppError no-undo.
    define buffer bTalk for talk.
    
    assign updateError = new AppError().
    for each ttTalk
        transaction:
        find bTalk where bTalk.id eq ttTalk.id exclusive-lock no-error.
        if available bTalk then
            buffer-copy ttTalk
                        except id 
                     to bTalk.
        else
            updateError:AddMessage(substitute('Talk &1 not found', ttTalk.id), 0).
        
        catch e as Progress.Lang.Error:
            updateError:AddMessage(substitute('Update error: &1', e:GetMessage(1)), 0).
        end catch.
    end.
    
    if updateError:NumMessages gt 0 then
        return error updateError.
end procedure.

procedure cancel_talk:
    define input  parameter pTalk as character no-undo.
    
    define variable updateError as AppError no-undo.
    
    define buffer bTalk for talk.
    define buffer bSlot for timeslot.
    
    assign updateError = new AppError().
    
    find bTalk where bTalk.id eq pTalk exclusive-lock no-error.
    if available bTalk then
    do:
        assign bTalk.talk_status = TalkStatusEnum:Cancelled:ToString().
        for each bSlot where bSlot.talk eq bTalk.id exclusive-lock:
            delete bSlot.
            
            catch e as Progress.Lang.Error:
                updateError:AddMessage(substitute('Update timeslot error: &1', e:GetMessage(1)), 0).
            end catch.
        end.
    end.
    else
        updateError:AddMessage(substitute('Talk &1 not found', pTalk), 0).
    
    if updateError:NumMessages gt 0 then
        return error updateError.
end procedure.
