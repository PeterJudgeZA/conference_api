/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
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
    
    assign extent(pStreams) = 6
           // Coding
           pStreams[1] = 'ABL'
           // Database-y
           pStreams[2] = 'SQL'
           pStreams[3] = 'DB'
           //Keynotes
           pStreams[4] = 'KEY'
           // Misc topics
           pStreams[5] = 'GEN'
           // Undefined
           pStreams[6] = 'NON'
           .
end procedure. 
