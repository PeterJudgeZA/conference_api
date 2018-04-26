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

using Progress.Lang.AppError.

{Conference/Shared/talks_dataset.i }


/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */
procedure update_talks:
    define input parameter table for ttTalk.
    
    define variable updateError as AppError no-undo.
    define buffer bTalk for talk.
    
    assign updateError = new AppError().
    for each ttTalk
        transaction:
        find bTalk where bTalk.id eq ttTalk.id exclusive-lock no-error.
        if available bTalk then
        do:
            buffer-copy ttTalk
                        except id talk_status content_url  
                     to bTalk
                        assign bTalk.talk_status = ttTalk.talk_status:ToString()
                               bTalk.content_url = ttTalk.content_url:ToString() 
                               .
        end.
        else
            updateError:AddMessage(substitute('Talk &1 not found', ttTalk.id), 0).
        
        catch e as Progress.Lang.Error:
            updateError:AddMessage(substitute('Update error: &1', e:GetMessage(1)), 0).
        end catch.
    end.
    
    if updateError:NumMessages gt 0 then
        return error updateError.
end procedure .

