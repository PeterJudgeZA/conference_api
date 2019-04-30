/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : update_speaker.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
block-level on error undo, throw.

using Progress.Lang.AppError.

{logic/shared/speaker_dataset.i }

/* ***************************  Main Block  ************************** */
procedure update_single_speaker:
    define input parameter pId as character no-undo.
    define input parameter pName as character no-undo.
    define input parameter pBio as character no-undo.
    define input parameter pUrl as character no-undo.

    define buffer bSpeaker for Speaker.
    
    find bSpeaker where bSpeaker.id eq ttSpeaker.id exclusive-lock no-error.
    if available bSpeaker then
        assign bSpeaker.name = pName
               bSpeaker.bio  = pBio
               bSpeaker.url  = pUrl
               .
    else
        return error new AppError(substitute('Speaker &1 not found', ttSpeaker.id), 0).
end procedure.

procedure update_speaker:
    define input parameter table for ttSpeaker.
    
    define variable updateError as AppError no-undo.
    define buffer bSpeaker for Speaker.
    
    assign updateError = new AppError().
    for each ttSpeaker
        transaction:
        find bSpeaker where bSpeaker.id eq ttSpeaker.id exclusive-lock no-error.
        if available bSpeaker then
        do:
            buffer-copy ttSpeaker
                        except id 
                     to bSpeaker.
        end.
        else
            updateError:AddMessage(substitute('Speaker &1 not found', ttSpeaker.id), 0).
        
        catch e as Progress.Lang.Error:
            updateError:AddMessage(substitute('Update error: &1', e:GetMessage(1)), 0).
        end catch.
    end.
    
    if updateError:NumMessages gt 0 then
        return error updateError.
end procedure.

procedure update_pic:
    define input parameter pId as character.
    define input parameter pPhoto as memptr no-undo.
    
    define buffer bSpeaker for speaker.
    
    find bSpeaker where bSpeaker.id eq pId exclusive-lock no-error.
    if available bSpeaker then
        copy-lob from pPhoto to bSpeaker.photo.
    else
        return error new AppError(substitute('Speaker &1 not found', ttSpeaker.id), 0).
    
    catch e as Progress.Lang.Error:
        return error new AppError(substitute('Update error: &1', e:GetMessage(1)), 0).
    end catch.
end procedure .