/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : FilterParams
    Author(s)   : pjudge
    Notes       : Input parameters for filtering a table
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using logic.FilterParams.

class logic.FilterParams:
    define public property TableName as character no-undo get. set.
    define public property TopRecs as integer no-undo get. set.
    define public property SkipRecs as integer no-undo get. set.
    define public property Where as character no-undo get. set.
    define public property SortBy as character no-undo get. set.
    define public property FieldList as character no-undo get. set.

    method override public character ToString():
        return substitute('where &1 by &2 field-list &3 [top:&4 skip:&5]',
                    this-object:Where, SortBy, FieldList, TopRecs, SkipRecs).
    end method.    
    
    method static public character BuildQueryString(input pFilter as FilterParams, input dataset-handle pDataset):
        define variable queryString as character no-undo.
        define variable buffer as handle no-undo.
        
        //find table by name from TableName
        //find table by serialize-name from TableName
        
        // for fields in WHERE
            //find by name 
            //find by serialize-name
        
        return queryString.
    end method.
    
end class.