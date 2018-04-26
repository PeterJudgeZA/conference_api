/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : SpeakerBE
    Description : Business logic for a speaker 
    Author(s)   : pjudge
    Created     : 2017-10-02
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using OpenEdge.BusinessLogic.BusinessEntity from propath.
using Conference.BusinessLogic.SpeakerBE from propath.

class Conference.BusinessLogic.SpeakerBE inherits BusinessEntity:
    {Conference/Shared/speaker_dataset.i &ACCESS-LEVEL=private}
     
    define data-source srcSpeaker for Speaker.
    
    constructor public SpeakerBE():
        super(dataset dsSpeaker:handle).
        
        assign // Data Source for each table in dataset. Should be in table order as defined in DataSet
               extent(this-object:ProDataSource) = 1 
               this-object:ProDataSource[1]      = data-source srcSpeaker:handle
               
               //  Skip-list entry for each table in dataset. Should be in temp-table order as defined in DataSet
               // Each skip-list entry is a comma-separated list of field names, to be ignored in create stmt
               extent(this-object:SkipList) = 1
               this-object:SkipList[1]      = ''
               .
    end constructor.
    
    method public void Add(input-output dataset dsSpeaker):
        super:CreateData(input-output dataset dsSpeaker by-reference).
    end method.

    method public void Remove(input-output dataset dsSpeaker):
        super:DeleteData(input-output dataset dsSpeaker by-reference).
    end method.
    
    method public void Update(input-output dataset dsSpeaker):
        super:UpdateData(input-output dataset dsSpeaker by-reference).
    end method.
    
    method public void Get(input  pSpeaker as character,
                           output dataset dsSpeaker):
        super:ReadData(substitute('where id = &1', pSpeaker)).
    end method.

    method public void List(input pFilter as character,
                            output dataset dsSpeaker):
        super:ReadData(pFilter).
    end method.
    
    /*-
Add(name, bio, photo, url) returns  id
Get(id) returns speaker
List(filter) returns speaker[]
Remove(id)
Update(id, name, bio, photo, url)
    */
    
end class.