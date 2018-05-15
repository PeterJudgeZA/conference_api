/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : session_start.p
    Description : This is a PASOE session startup event procedure 
    Author(s)   : pjudge
    Notes       : * The session startup procedure is condifued in $CATALINA_BASE/conf/openedge.properties
                    [AppServer.Agent.${oepas-app}]
                    ; other properties like PROPATH
                    sessionStartupProc=path/to/session_start.p
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Conference.SI.DOHEventHandler.
using OpenEdge.Web.DataObject.ServiceRegistry.

define input  parameter pcArgs as character no-undo.

/* ***************************  Main Block  *************************** */
// [OPTIONAL] This preloads all mapping files named *.map and *.gen in the instance's oepnedge folder.
ServiceRegistry:RegisterAllFromFolder(substitute('&1/openedge', os-getenv('CATALINA_BASE'))).

// sets up the handler for events from the DOH
new DOHEventHandler().

/* EOF */