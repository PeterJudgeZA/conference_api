/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : SI.Speakers
    Description : Service interface for working with speakers 
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Conference.SI.Speakers: 
    {logic/shared/speaker_dataset.i}

    METHOD PUBLIC VOID ReadSpeakers(INPUT filter AS CHARACTER,
                                    OUTPUT DATASET dsSpeaker):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        DEFINE VARIABLE cnt AS INTEGER NO-UNDO.
        
        RUN logic/speaker/find_speaker.p SINGLE-RUN SET hProc.
        
        RUN get_filtered_speakers IN hProc (INPUT filter,
                                            INPUT 0,       // skip
                                            INPUT 0,       // top
                                            OUTPUT TABLE ttSpeaker,
                                            OUTPUT cnt). 
    END METHOD.
    
    METHOD PUBLIC VOID CreateSpeakers(INPUT-OUTPUT DATASET dsSpeaker):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        DEFINE QUERY qrySpeaker FOR ttSpeaker.
        
        RUN logic/speaker/new_speaker.p PERSISTENT SET hProc.
        
        // We're using a query here because we update the ID field, which is the 
        // primary unique value
        OPEN QUERY qrySpeaker PRESELECT EACH ttSpeaker.   
        GET FIRST qrySpeaker.
        DO WHILE AVAILABLE ttSpeaker:
            RUN create_speaker IN hProc (INPUT  ttSpeaker.name,
                                         OUTPUT ttSpeaker.id).
            GET NEXT qrySpeaker.
        END.
        
        FINALLY:
            CLOSE QUERY qrySpeaker.
            DELETE OBJECT hProc.
        END FINALLY.
    END METHOD.    
    
    /* Submits are processed in row-state order
        1. DELETED
        2. CREATED
        3. MODIFIED    
    */
    METHOD PUBLIC VOID SubmitSpeakers(INPUT-OUTPUT DATASET dsSpeaker):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        
        // deletes
        RUN logic/speaker/remove_speaker.p PERSISTENT SET hProc.
        FOR EACH btSpeaker WHERE ROW-STATE(btSpeaker) EQ ROW-DELETED:
            RUN delete_speaker IN hProc (INPUT btSpeaker.id).
        END.
        DELETE OBJECT hProc.
        
        // creates
        RUN logic/speaker/new_speaker.p PERSISTENT SET hProc.
        FOR EACH btSpeaker WHERE ROW-STATE(btSpeaker) EQ ROW-CREATED:
            
            FIND ttSpeaker WHERE ROWID(ttSpeaker) EQ BUFFER btSpeaker:AFTER-ROWID.
            
            RUN create_speaker IN hProc (INPUT  ttSpeaker.name,
                                         OUTPUT ttSpeaker.id).
        END.
        DELETE OBJECT hProc.
    
        // updates         
        RUN logic/speaker/update_speaker.p PERSISTENT SET hProc.
        
        FOR EACH btSpeaker WHERE ROW-STATE(btSpeaker) EQ ROW-MODIFIED:
            FIND ttSpeaker WHERE ROWID(ttSpeaker) EQ BUFFER btSpeaker:AFTER-ROWID.
            
            RUN update_single_speaker IN hProc (INPUT ttSpeaker.id,
                                                INPUT ttSpeaker.name,
                                                INPUT ttSpeaker.bio,
                                                INPUT ttSpeaker.url).
        END.
        
        FINALLY:
            // in case of error
            DELETE OBJECT hProc NO-ERROR.
        END FINALLY.
    END METHOD.
    
    METHOD PUBLIC VOID UpdateSpeakers(INPUT-OUTPUT DATASET dsSpeaker):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        
        RUN logic/speaker/update_speaker.p SINGLE-RUN SET hProc.
        
        RUN update_speaker IN hProc (INPUT table ttSpeaker).
    END METHOD.    
    
    METHOD PUBLIC VOID DeleteSpeakers(INPUT-OUTPUT DATASET dsSpeaker):
        DEFINE VARIABLE hProc AS HANDLE NO-UNDO.
        
        RUN logic/speaker/remove_speaker.p SINGLE-RUN SET hProc.
                
        FOR EACH ttSpeaker:
            RUN delete_speaker IN hProc (INPUT ttSpeaker.id).
        END.
        
        FINALLY:
            DELETE OBJECT hProc.
        END FINALLY.
    END METHOD.
    
END CLASS.