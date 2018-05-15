/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : TalkBE 
    Description : Business logic for a talk(session) 
    Author(s)   : pjudge
    Created     : 2017-10-02
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using OpenEdge.BusinessLogic.BusinessEntity from propath.
using Progress.Lang.Object from propath.

class Conference.BusinessLogic.TalkBE inherits BusinessEntity: 
    {logic/shared/talks_dataset.i &ACCESS-LEVEL=private}
    
    define data-source srcTalk for Talk.
    define data-source srcSpeaker for Speaker.
    define data-source srcTimeslot for Timeslot.
        
    constructor public TalkBE ():
        super(dataset dsTalk:handle).
        
        assign // Data Source for each table in dataset. Should be in table order as defined in DataSet
               extent(this-object:ProDataSource) = 3 
               this-object:ProDataSource[1]      = data-source srcTalk:handle
               this-object:ProDataSource[2]      = data-source srcSpeaker:handle
               this-object:ProDataSource[3]      = data-source srcTimeslot:handle
               
               //  Skip-list entry for each table in dataset. Should be in temp-table order as defined in DataSet
               // Each skip-list entry is a comma-separated list of field names, to be ignored in create stmt
               extent(this-object:SkipList) = 3
               this-object:SkipList[1]      = ''
               this-object:SkipList[2]      = ''
               this-object:SkipList[3]      = ''
               .
    end constructor.
    
    
    method override protected void CreateData( input-output DATASET-HANDLE hDataSet ):
        
//        super:CreateData(input-output DATASET-HANDLE hDataSet).

        run logic/talk/new_talk.p (...).

    end method.

    method override protected void DeleteData( input-output DATASET-HANDLE hDataSet ):
        
        super:DeleteData(input-output DATASET-HANDLE hDataSet).

    end method.


    method override protected void ReadData( input cFilter as character, output DATASET-HANDLE hDataSet):
        
        super:ReadData(input cFilter, input hBuffer).

    end method.

    method public void ScheduleTalk(input pTalk as character,
                                    input pTimelot as character):
    end method.

    method override protected void UpdateData( input-output DATASET-HANDLE hDataSet ):
        
        super:UpdateData(input-output DATASET-HANDLE hDataSet).

    end method.
    
    /*
Add(speaker, name, abstract) returns id
Approve(id)
Update(id, speaker, name, abstract, content_url, talk_status)
Schedule(id, room, timeslot)
List(filter) returns session[]
    */
    
end class.