/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
 /*------------------------------------------------------------------------
    File        : FilterResponse
    Description : 
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

class logic.FilterResponse:
    define public property TableName as character no-undo get. set.
    define public property NumRecs as integer no-undo get. set.
    define public property IsLastBatch as logical no-undo get. set.    
    define public property PagingContext as character no-undo get. set. 
    define public property TableContext as Progress.Lang.Object no-undo get. set.
    
    method override public character ToString():
        return substitute('returned &1 rows from table &3 [is-last-batch:&2; page-ctx:&5 has-table-ctx:&4]',
                            this-object:NumRecs, IsLastBatch, TableName, valid-object(TableContext), PagingContext).
    end method.
    
end class.