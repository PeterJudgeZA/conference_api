/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
block-level on error undo, throw.
using Progress.Lang.AppError.

procedure delete_speaker:
    define input  parameter pId as character no-undo.
    
    define variable hTalks as handle no-undo.
    
    define buffer bSpeaker for speaker.
    define buffer bTalk for Talk.
    
    find bSpeaker where bSpeaker.id eq pId exclusive-lock no-error.
    if available bSpeaker then
    do:
        run logic/talk/schedule_talk.p persistent set hTalks.
        for each bTalk where bTalk.speaker eq bSpeaker.id no-lock:
            run cancel_talk in hTalks (bTalk.id).
        end.
        
        delete bSpeaker.
    end.
    else
        return error new AppError(substitute('Speaker &1 not found', pId), 0).
    
    finally:
        delete object hTalks no-error.
    end finally.
end procedure.
