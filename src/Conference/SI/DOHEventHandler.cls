/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
/*------------------------------------------------------------------------
    File        : DOHEventHandler
    Purpose     : 
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Conference.SI.DOHEventHandler.
using OpenEdge.Web.DataObject.DataObjectHandler.
using OpenEdge.Web.DataObject.HandlerErrorEventArgs.
using OpenEdge.Web.DataObject.OperationInvocationEventArgs.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using OpenEdge.Net.HTTP.HttpHeader.

class Conference.SI.DOHEventHandler: 
    /* ciorcular dep to cheat death aka GC */
    define variable oCheat as DOHEventHandler no-undo.
    
    constructor public DOHEventHandler():
        oCheat = this-object.
        
        DataObjectHandler:Invoked:Subscribe(InvokedHandler).
        DataObjectHandler:OperationError:Subscribe(OperationErrorHandler).
    end constructor.

    /* Event published when an error is encountered 
       
       @param Progress.Lang.Object The handler publishing the event
       @param HandlerErrorEventArgs Event args for this event */
    method public void OperationErrorHandler (input poSender as Progress.Lang.Object,
                                              input poEventArgs as HandlerErrorEventArgs):
        message 'OPERATIONERROR'.
    end method. 
    
    /* Event published after the business logic function was called by the handler 
       
       @param Progress.Lang.Object The handler publishing the event
       @param OperationInvocationEventArgs Event args for this event */
    method public void InvokedHandler (input poSender as Progress.Lang.Object,
                                       input poEventArgs as OperationInvocationEventArgs):
        define variable msgBody as JsonObject no-undo.
        define variable data as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable talks as JsonArray no-undo.
        define variable links as JsonObject no-undo.
        define variable speakerName as character no-undo.
        define variable appBase as character no-undo.
        define variable linkBase as character no-undo.
        define variable skipRecs as integer no-undo initial 0.
        define variable topRecs as integer no-undo  initial 0.
        define variable cnt as integer no-undo.
        define variable loop as integer no-undo.
        define variable locationHdr as HttpHeader no-undo.
        define variable hdrValue as character no-undo.
        
        assign appBase  = trim(poEventArgs:Request:WebAppPath, '/':u)  + '/':u
                            + trim(poEventArgs:Request:TransportPath, '/':u) + '/' 
               linkBase = appBase + trim(poEventArgs:Request:PathInfo, '/':u)
               .
        if     poEventArgs:Response:StatusCode  eq 201 
           and poEventArgs:Response:HasHeader('Location') 
       then
            assign locationHdr       = poEventArgs:Response:GetHeader('Location')
                   hdrValue          = linkBase + '/' + locationHdr:Value
                   locationHdr:Value = hdrValue
                   .
        else
        if poEventArgs:Response:ContentType eq 'application/vnd.conf.talks+json' then
        do:
            assign msgBody  = cast(poEventArgs:Response:Entity, JsonObject)
                   //data     = msgBody:GetJsonObject('data':u)
                   cnt      = msgBody:GetInteger('count')
                   talks    = msgBody:GetJsonObject('data':u):GetJsonArray('ttTalk')
                   
                   
                   links    = new JsonObject()
                   topRecs  = integer(poEventArgs:Request:URI:GetQueryValue('top'))
                   skipRecs = integer(poEventArgs:Request:URI:GetQueryValue('skip'))
                   .
            
            msgBody:Add('links', links).
            links:Add('first', substitute('&1?skip=&2&top=&3', linkBase, 0, topRecs)).
            links:Add('next', substitute('&1?skip=&2&top=&3', linkBase, skipRecs, topRecs)).
            links:Add('prev', substitute('&1?skip=&2&top=&3', linkBase, skipRecs + skipRecs, topRecs)).
            links:Add('last',  substitute('&1?skip=-1', linkBase)).
            
            if skipRecs eq 0       then links:SetNull('prev').
            if topRecs le skipRecs then links:SetNull('next').
            
            do loop = 1 to cnt:
                assign record = talks:GetJsonObject(loop)
                       links  = new JsonObject()
                       .
                // add the links here
                record:Add('links',  links).
                links:Add('self',    linkBase + '/' + record:GetCharacter('id')).
                links:Add('speaker', appBase + '/speakers/' + record:GetCharacter('speaker') ).
                links:Add('times',   appBase + '/timeslots?talk=' + record:GetCharacter('id')).
            end.
        end.    // Talks
    end method.
    
end class.