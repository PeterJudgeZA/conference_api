/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
 /*------------------------------------------------------------------------
    File        : FilterParamArgumentWriter
    Description : 
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Ccs.Common.Support.ICharacterHolder.
using Ccs.Common.Support.ILongcharHolder.
using OpenEdge.Web.DataObject.Writer.ObjectValueWriter.
using Progress.Json.ObjectModel.JsonObject.
using logic.FilterParams.
using Progress.Json.ObjectModel.ObjectModelParser.

class Conference.SI.FilterParamArgumentWriter inherits ObjectValueWriter:

    constructor public FilterParamArgumentWriter():
         //super (get-class(FilterParams)).
         super().
    end constructor.
    
    method override public void Open():
        /* If nothing's passed in, use a JsonObject of our own. 
           Don't do this in the constructor as a micro-optimisation (yes, I know) */
        if not valid-object(this-object:Value) then
            assign this-object:Value = new FilterParams().
        
        super:Open().
    end method.
    
    /**
    method override public void Write(input pData as Progress.Lang.Object ):
        define variable jsonFilter as JsonObject no-undo.
                super:Write(pData).
        
        case true:
            when not valid-object(pData) then
                return.
            
            when type-of(pData, ILongcharHolder) then
                assign jsonFilter = cast((new ObjectModelParser()):Parse(cast(pData, ILongcharHolder):Value),
                                         JsonObject). 
                
            when type-of(pData, ICharacterHolder) then
                assign jsonFilter = cast((new ObjectModelParser()):Parse(cast(pData, ICharacterHolder):Value),
                                         JsonObject). 
                
            when type-of(pData, JsonObject) then
                assign jsonFilter = cast(pData, JsonObject).
                
            otherwise
        end case.
        
        if not valid-object(jsonFilter) then
            return.        
    end method.
    **/
    
end class.