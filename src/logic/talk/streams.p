/*------------------------------------------------------------------------
    File        : streams.p
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

/* ***************************  Main Block  ************************** */

/* ***************************  Functions & Procedures  ************************** */

procedure list_streams:
    define output parameter pStreams as character extent no-undo.
    
    assign extent(pStreams) = 5
           
           pStreams[1] = 'ABL'
           pStreams[2] = 'SQL'
           pStreams[3] = 'DB'
           pStreams[4] = 'KEY'   //Keynote
           pStreams[5] = 'GEN'
           .
end procedure. 


