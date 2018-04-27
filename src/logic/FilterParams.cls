/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : FilterParams
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

class logic.FilterParams:
    define public property TopRecs as integer no-undo get. set.
    define public property SkipRecs as integer no-undo get. set.
    define public property Where as character no-undo get. set.
    define public property SortBy as character no-undo get. set.
    define public property FieldList as character no-undo get. set.

    method override public character ToString():
        return substitute('where &1 by &2 field-list &3 [top:&4 skip:&5]',
                    this-object:Where, SortBy, FieldList, TopRecs, SkipRecs).
    end method.    
end class.