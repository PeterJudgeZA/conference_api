
 /*------------------------------------------------------------------------
    File        : SpeakersBE
    Purpose		:
    Syntax      : 
    Description :
    Author(s)   : pjudge
    Created     : Thu May 24 13:20:08 EDT 2018
    Notes       : 
  ----------------------------------------------------------------------*/
  
  /* ***************************  Definitions  ************************** */
  
  /* ********************  Preprocessor Definitions  ******************** */
  
  /* ***************************  Main Block  *************************** */
  
  /** Dynamically generated schema file **/
   

define temp-table ttspeaker no-undo before-table bttspeaker
field id as character
field name as character
field bio as character
field url as character
field photo as BLOB
index idx2  name  ascending 
index pu is  primary   id  ascending . 


define dataset dsspeaker for ttspeaker.