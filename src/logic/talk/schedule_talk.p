/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : schedule_talk.p
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
procedure schedule_talk:
    define input  parameter pRoom as character no-undo.
    define input  parameter pStartAt as datetime-tz no-undo.
    define input  parameter pTalk as character no-undo.
    define input  parameter pDuration as integer no-undo.
    define output parameter pId as character no-undo.
    
    define buffer bSlot for timeslot. 
    
    Assert:NotNullOrEmpty(pRoom, 'Room').
    Assert:NotNullOrEmpty(pTalk, 'Talk').
    Assert:NotNull(pStartAt, 'Start tie').
    Assert:IsPositive(pDuration, 'Talk duration').
    
    if can-find(bSlot where bSlot.room eq pRoom and bSlot.start_at eq pStartAt) then
        return error new AppError(substitute('Room &1 already scheduled for &2',
                                                pRoom,
                                                iso-date(pStartAt)), 0).
    create bSlot.
    assign pId            = substitute('SLOT-&1', string(next-value(seq_name_cnt), '999'))
           bSlot.id       = pId
           bSlot.room     = pRoom
           bSlot.start_at = pStartAt
           bSlot.talk     = pTalk
           bSlot.duration = pDuration
           .
end procedure.

procedure cancel_scheduled_talk_by_id:
    define input parameter pId as character no-undo.
    
    define variable hTalksLogic as handle no-undo.
    define buffer bSlot for timeslot.
    
    find bSlot where bSlot.talk eq pId exclusive-lock no-error.
    if available bSlot then
    do:
        // cancel all the talks
        run logic/talk/update_talk.p single-run set hTalksLogic.
        run set_talk_status in hTalksLogic (bSlot.talk, TalkStatusEnum:Accepted).
        
        delete bSlot.
    end.
    else
        return error new AppError(substitute('Slot &1 not found'), 0).
    
    finally:
        delete object hTalksLogic no-error.
    end finally.
end procedure.

procedure cancel_scheduled_talk_by_talk:
    define input  parameter pTalk as character no-undo.
    
    define variable updateError as AppError no-undo.
    define variable hTalksLogic as handle no-undo.
    define buffer bSlot for timeslot.
    
    assign updateError = new AppError().
    for each bSlot where bSlot.talk eq pTalk exclusive-lock:
        delete bSlot.
        
        catch e as Progress.Lang.Error:
            updateError:AddMessage(substitute('Update error: &1', e:GetMessage(1)), 0).
        end catch.
    end.
    
    // cancel all the talks
    run logic/talk/update_talk.p single-run set hTalksLogic.
    run set_talk_status in hTalksLogic (pTalk, TalkStatusEnum:Accepted).
    
    if updateError:NumMessages gt 0 then
        return error updateError.
    
    finally:
        delete object hTalksLogic no-error.
    end finally.
end procedure.

procedure update_schedule:
    define input-output parameter table for ttTimeslot.
    
    define variable updateError as AppError no-undo.
    define buffer bSlot for timeslot.
    
    assign updateError = new AppError().
    for each ttTimeslot,
             first bSlot where 
                   bSlot.id eq ttTimeslot.id 
                   exclusive-lock:
        // update the slot
        buffer-copy ttTimeslot
                    except id room start_at  
                 to bSlot.
        catch e as Progress.Lang.Error:
            updateError:AddMessage(substitute('Update error: &1', e:GetMessage(1)), 0).
        end catch.
    end.
    
    if updateError:NumMessages gt 0 then
        return error updateError.
end procedure.

