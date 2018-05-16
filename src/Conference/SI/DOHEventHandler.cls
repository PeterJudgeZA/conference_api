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
using OpenEdge.Net.HTTP.HttpHeader.
using OpenEdge.Web.DataObject.DataObjectHandler.
using OpenEdge.Web.DataObject.HandlerErrorEventArgs.
using OpenEdge.Web.DataObject.OperationInvocationEventArgs.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonDataType.
using Progress.Json.ObjectModel.JsonObject.

class Conference.SI.DOHEventHandler: 
    /* circular dep to cheat death aka GC */
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
    end method. 
    
    /* Event published after the business logic function was called by the handler 
       
       @param Progress.Lang.Object The handler publishing the event
       @param OperationInvocationEventArgs Event args for this event */
    method public void InvokedHandler (input poSender as Progress.Lang.Object,
                                       input poEventArgs as OperationInvocationEventArgs):
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable talks as JsonArray no-undo.
        define variable links as JsonObject no-undo.
        define variable href as JsonObject no-undo.
        define variable speakerName as character no-undo.
        define variable appBase as character no-undo.
        define variable linkBase as character no-undo.
        define variable skipRecs as integer no-undo initial 0.
        define variable topRecs as integer no-undo  initial 0.
        define variable cnt as integer no-undo.
        define variable loop as integer no-undo.
        define variable locationHdr as HttpHeader no-undo.
        define variable dataValue as character no-undo.
        define variable chrPos as integer no-undo.
        
        assign appBase  = trim(poEventArgs:Request:WebAppPath, '/':u)  + '/':u
                        + trim(poEventArgs:Request:TransportPath, '/':u) + '/' 
               linkBase = appBase + trim(poEventArgs:Request:PathInfo, '/':u)
               .
        if     poEventArgs:Response:StatusCode  eq 201
           and poEventArgs:Response:HasHeader('Location') 
       then
            assign locationHdr       = poEventArgs:Response:GetHeader('Location')
                   dataValue         = linkBase + '/' + locationHdr:Value
                   locationHdr:Value = dataValue
                   .
        else
        if poEventArgs:Response:ContentType eq 'application/vnd.conf.talks+json' then
        do:
            assign msgBody  = cast(poEventArgs:Response:Entity, JsonObject).
            
            if     msgBody:Has('data')
               and msgBody:GetType('data') eq JsonDataType:OBJECT
            then
                assign talks = msgBody:GetJsonObject('data':u):GetJsonArray('talks').
            else
            if     msgBody:Has('talks')
               and msgBody:GetType('talks') eq JsonDataType:ARRAY
            then
                assign talks = msgBody:GetJsonArray('talks').
            
            // we're working with a set
            if lookup('tlk', poEventArgs:Request:PathParameterNames) eq 0 then
            do:
                assign links    = new JsonObject()
                       topRecs  = integer(poEventArgs:Request:URI:GetQueryValue('top'))
                       skipRecs = integer(poEventArgs:Request:URI:GetQueryValue('skip'))
                       .
                if topRecs  eq ? then assign topRecs  = 0.
                if skipRecs eq ? then assign skipRecs = 0.
                
                msgBody:Add('links', links).
                assign href = new JsonObject().
                links:Add('first', href).
                href:Add('href', substitute('&1?skip=&2&4top=&3', linkBase, 0, topRecs, '&')).
                
                assign href = new JsonObject().
                links:Add('next',  href).
                if topRecs le skipRecs then
                    href:AddNull('href').
                else
                    href:Add('href', substitute('&1?skip=&2&4top=&3', linkBase, skipRecs, topRecs, '&')).
                
                assign href = new JsonObject().
                links:Add('prev',  href).
                if skipRecs eq 0 then
                    href:AddNull('href').
                else
                    href:Add('href', substitute('&1?skip=&2&4top=&3', linkBase, skipRecs + skipRecs, topRecs, '&')).
                
                assign href = new JsonObject().
                links:Add('last',  href).
                href:Add('href', substitute('&1?skip=-1', linkBase)).
            end.    // set o' data
            else
                assign chrPos   = r-index(linkBase, '/')
                           linkBase = substring(linkBase, 1, chrPos - 1)
                       .
            assign cnt = talks:Length.
            do loop = 1 to cnt:
                assign record = talks:GetJsonObject(loop)
                       links  = new JsonObject()
                       .
                // add the links here
                record:Add('links', links).
                assign href = new JsonObject().
                links:Add('self', href).
                href:Add('href', linkBase + '/' + record:GetCharacter('id')).
                assign dataValue = record:GetCharacter('speaker')
                       href      = new JsonObject()
                       .
                links:Add('speaker', href).
                if dataValue eq '':u then
                    href:AddNull('href').
                else
                    href:Add('href', appBase + '/speakers/' +  dataValue).
                
                assign href = new JsonObject().
                links:Add('times', href).
                href:Add('href',  appBase + '/timeslots?talk=' + record:GetCharacter('id')).
            end.
        end.    // Talks
    end method.
    
end class.