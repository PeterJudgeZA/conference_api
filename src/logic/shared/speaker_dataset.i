&if false &then
/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : logic/shared/speaker_dataset.i
    Description : 
    Author(s)   : pjudge
    Notes       :
  ----------------------------------------------------------------------*/
&endif
define {&ACCESS-LEVEL} temp-table ttSpeaker no-undo before-table btSpeaker
        field id as character
        field name as character
        field bio as character
        field photo as blob serialize-hidden
        field url as character
        index idx1 as primary unique id
        index idx2 name.

define {&ACCESS-LEVEL} dataset dsSpeaker for ttSpeaker.
