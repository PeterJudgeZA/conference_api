/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : SI.Talks
    Description : Service interface for working with talks
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Conference.BusinessLogic.TalkStatusEnum.

CLASS Conference.SI.Talks: 
    {logic/shared/talks_dataset.i}
    
    METHOD PUBLIC VOID ReadTalks(INPUT filter AS CHARACTER,
                                 OUTPUT DATASET dsTalk):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        DEFINE VARIABLE cnt AS INTEGER NO-UNDO.
        
        RUN logic/talk/read_talks.p SINGLE-RUN SET hProc.
        
        RUN get_filtered_talks IN hProc (INPUT filter,
                                         INPUT 0,       // skip
                                         INPUT 0,       // top
                                         OUTPUT TABLE ttTalk,
                                         OUTPUT cnt). 
    END METHOD.
    
    METHOD PUBLIC VOID CreateTalks(INPUT-OUTPUT DATASET dsTalk):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        DEFINE QUERY qryTalk FOR ttTalk.
        
        RUN logic/talk/new_talk.p PERSISTENT SET hProc.
       
        // We're using a query here because we update the ID field, which is the 
        // primary unique value
        OPEN QUERY qryTalk PRESELECT EACH ttTalk.   
        GET FIRST qryTalk.
        DO WHILE AVAILABLE ttTalk:
            RUN create_talk IN hProc (INPUT  ttTalk.name,
                                      INPUT  ttTalk.speaker,
                                      INPUT  ttTalk.abstract,
                                      INPUT  ttTalk.content_url,
                                      INPUT  ttTalk.content_type,
                                      OUTPUT ttTalk.id).
            GET NEXT qryTalk.
        END.
        
        FINALLY:
            CLOSE QUERY qryTalk.
        END FINALLY.      
    END METHOD.
        
    /* Submits are processed in row-state order
        1. DELETED
        2. CREATED
        3. MODIFIED    
    */    
    METHOD PUBLIC VOID SubmitTalks(INPUT-OUTPUT DATASET dsTalk):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        DEFINE VARIABLE talkStatus AS TalkStatusEnum NO-UNDO.
        
        // deletes
        FOR EACH btTalk WHERE ROW-STATE(btTalk) EQ ROW-DELETED:
            // mark as error
            ASSIGN BUFFER btTalk:ERROR        = TRUE
                   BUFFER btTalk:REJECTED     = TRUE
                   BUFFER btTalk:ERROR-STRING = 'Delete operation not supported by this Service'
                   DATASET dsTalk:ERROR       = TRUE
                   .
        END.
        DELETE OBJECT hProc.
        
        // creates
        RUN logic/talk/new_talk.p PERSISTENT SET hProc.
        FOR EACH btTalk WHERE ROW-STATE(btTalk) EQ ROW-CREATED:
            
            FIND ttTalk WHERE ROWID(ttTalk) EQ BUFFER btTalk:AFTER-ROWID.
            
            RUN create_talk IN hProc (INPUT  ttTalk.name,
                                      INPUT  ttTalk.speaker,
                                      INPUT  ttTalk.abstract,
                                      INPUT  ttTalk.content_url,
                                      INPUT  ttTalk.content_type,
                                      OUTPUT ttTalk.id).
        END.
        DELETE OBJECT hProc.
    
        // updates         
        RUN logic/talk/update_talk.p PERSISTENT SET hProc.
        
        FOR EACH btTalk WHERE ROW-STATE(btTalk) EQ ROW-MODIFIED:
            
            FIND ttTalk WHERE ROWID(ttTalk) EQ BUFFER btTalk:AFTER-ROWID.
            ASSIGN talkStatus = TalkStatusEnum:GetEnum(ttTalk.talk_status) no-error.
            
            RUN update_single_talk IN hProc (INPUT ttTalk.id,
                                             INPUT ttTalk.name,
                                             INPUT ttTalk.speaker,
                                             INPUT ttTalk.abstract,
                                             INPUT talkStatus,
                                             INPUT ttTalk.content_url,
                                             INPUT ttTalk.content_type).
        END.
        DELETE OBJECT hProc.
        
        FINALLY:
            // in case of error
            DELETE OBJECT hProc NO-ERROR.
        END FINALLY.
    END METHOD.
    
    METHOD PUBLIC VOID UpdateTalks(INPUT-OUTPUT DATASET dsTalk):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        
        RUN logic/talk/update_talk.p SINGLE-RUN SET hProc.
        
        RUN update_talks IN hProc (INPUT-OUTPUT table ttTalk).
    END METHOD.    

END CLASS.