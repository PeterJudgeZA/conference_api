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
{Conference/Shared/speaker_dataset.i }


/* ***************************  Main Block  ************************** */
procedure update_speaker:
    define input parameter table for ttSpeaker.
end procedure .

procedure update_pic:
    define input parameter pId as character.
    define input parameter pPhoto as memptr no-undo.
end procedure .