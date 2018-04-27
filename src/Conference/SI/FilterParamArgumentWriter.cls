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

using OpenEdge.Web.DataObject.Writer.ArgumentValueWriter.
using logic.FilterParams.
using OpenEdge.Core.KeyValuePair.

class Conference.SI.FilterParamArgumentWriter inherits ArgumentValueWriter: 

    constructor public FilterParamArgumentWriter():
        super (get-class(FilterParams)).
    end constructor.
    
    method override public void Open():
        /* If nothing's passed in, use a JsonObject of our own. 
           Don't do this in the constructor as a micro-optimisation (yes, I know) */
        if not valid-object(this-object:Value) then
            assign this-object:Value = new FilterParams().
        
        super:Open().
    end method.
    
    method override public void Write(input pData as Progress.Lang.Object ):
        define variable kvp as KeyValuePair no-undo.
        case true:
            when not valid-object(pData) then
                return.
            when type-of(pData, KeyValuePair) then
            do:
                assign kvp = cast(pData, KeyValuePair).
                
                case kvp:Key:ToString():
                    when 'tlk' or
                    when 'spkr' then
                        assign cast(this-object:Value, FilterParams):Where = substitute('id = "&1"', 
                                                                                    kvp:Value:ToString()).
                    
                    when '$top' or 
                    when 'top' then
                        assign cast(this-object:Value, FilterParams):TopRecs = integer(kvp:Value:ToString()).
                    
                    when '$skip' or 
                    when 'skip' then
                        assign cast(this-object:Value, FilterParams):SkipRecs = integer(kvp:Value:ToString()).
                    
                    when '$filter' or 
                    when 'filter' then
                        assign cast(this-object:Value, FilterParams):Where = kvp:Value:ToString().
                    
                    when '$select' then
                        assign cast(this-object:Value, FilterParams):FieldList = kvp:Value:ToString().
                        
                    when '$sortby' or
                    when 'sorty' or
                    when 'by' then
                        assign cast(this-object:Value, FilterParams):SortBy = kvp:Value:ToString().
                end case.
            end.
        end case.
        
    end method.

end class.