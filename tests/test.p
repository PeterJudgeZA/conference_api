
/*------------------------------------------------------------------------
    File        : test.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Apr 26 16:21:06 EDT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

using Conference.BusinessLogic.TalkStatusEnum.

/* ********************  Preprocessor Definitions  ******************** */
{logic/shared/talks_dataset.i }

/* ***************************  Main Block  *************************** */

create ttTalk.
assign ttTalk.id          = substitute('&1-&2', 'ABL', string(next-value(seq_name_cnt), '999'))
       ttTalk.talk_status = TalkStatusEnum:Submitted:ToString()
       ttTalk.name        = 'lorem ipsum'
       .
create ttTalk.
assign ttTalk.id          = substitute('&1-&2', 'ABL', string(next-value(seq_name_cnt), '999'))
       ttTalk.talk_status = TalkStatusEnum:Submitted:ToString()
       ttTalk.name        = 'bacon sausage'
       .
       
buffer ttTalk:write-json('file', session:temp-dir + '/talks.json', yes). //, ?, ?, ?, yes).
       