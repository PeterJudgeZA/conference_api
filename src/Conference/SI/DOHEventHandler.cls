/*------------------------------------------------------------------------
    File        : DOHEventHandler
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jul 21 16:06:27 EDT 2016
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Conference.SI.DOHEventHandler.
using OpenEdge.Web.DataObject.DataObjectHandler.
using OpenEdge.Web.DataObject.HandlerErrorEventArgs.
using OpenEdge.Web.DataObject.HandlerLoadEntityEventArgs.
using OpenEdge.Web.DataObject.OperationInvocationEventArgs.
using OpenEdge.Web.DataObject.ServiceDiscoveryEventArgs.

class Conference.SI.DOHEventHandler: 
    /* ciorcular dep to cheat death aka GC */
    define variable oCheat as DOHEventHandler no-undo.
    
    constructor public DOHEventHandler():
        oCheat = this-object.
        
        DataObjectHandler:DiscoverService:Subscribe(DiscoverServiceHandler).
        
        DataObjectHandler:Invoked:Subscribe(InvokedHandler).
        DataObjectHandler:OperationError:Subscribe(OperationErrorHandler).
        DataObjectHandler:LoadEntity:Subscribe(LoadEntityHandler).
        DataObjectHandler:UnloadEntity:Subscribe(UnloadEntityHandler).
        DataObjectHandler:Invoking:Subscribe(InvokingHandler).
        
    end constructor.

    /* Event published when an error is encountered 
       
       @param Progress.Lang.Object The handler publishing the event
       @param HandlerErrorEventArgs Event args for this event */
    method public void OperationErrorHandler (input poSender as Progress.Lang.Object,
                                              input poEventArgs as HandlerErrorEventArgs):
        message 'OPERATIONERROR'.
    end method. 
    
    /* Event published to invoke/load a piece of business logic (aka Business Entity).
       
       If none exists, we try a simple DYNAMIC-NEW. 
       
       @param Progress.Lang.Object The handler publishing the event
       @param HandlerLoadEntityEventArgs Event args for this event */
    method public void LoadEntityHandler (input poSender as Progress.Lang.Object,
                                          input poEventArgs as HandlerLoadEntityEventArgs):
        message 'LOAD-ENTITY'.
        
        /**    
        assign poEventArgs:BusinessEntity = ServiceManager:Instance
                                                :GetService( // sports.CustomerBE
                                                             poEventArgs:Operation:TargetName ).
    
         **/
    end method. 
    
    method public void DiscoverServiceHandler(input pSender as Progress.Lang.Object,
                                              input pEventArgs as ServiceDiscoveryEventArgs):
        define variable acceptable as character no-undo.
        define variable chrPos as integer no-undo.
        
        message 'DISCOVER-SERVICE'.
        
        assign acceptable = pEventArgs:Request:GetHeader('Accept'):Value
               chrPos     = index(acceptable, '/':u)
               acceptable = substring(acceptable, chrPos + 1)
               acceptable = entry(1, acceptable, '+':u)
               
               chrPos     = index(acceptable, '-':u)
               acceptable = trim(substring(acceptable, chrPos + 1), 'v':u)
               
               pEventArgs:Version = acceptable
               .
        message acceptable.
    end method.
    
    /* Event published to invoke/load a piece of business logic (aka Business Entity).
       
       If none exists, we try a simple DYNAMIC-NEW. 
       
       @param Progress.Lang.Object The handler publishing the event
       @param HandlerLoadEntityEventArgs Event args for this event */
    method public void UnloadEntityHandler (input poSender as Progress.Lang.Object,
                                          input poEventArgs as HandlerLoadEntityEventArgs):
         
        message 'UNLOAD-ENTITY'.
    end method.
        
    /* Event published before the business logic function is called by the handler
       
       @param Progress.Lang.Object The handler publishing the event
       @param OperationInvocationEventArgs Event args for this event */
    method public void InvokingHandler (input poSender as Progress.Lang.Object,
                                                        input poEventArgs as OperationInvocationEventArgs):
        message 'INVOKING'.
    end method. 

    /* Event published after the business logic function was called by the handler 
       
       @param Progress.Lang.Object The handler publishing the event
       @param OperationInvocationEventArgs Event args for this event */
    method public void InvokedHandler (input poSender as Progress.Lang.Object,
                                       input poEventArgs as OperationInvocationEventArgs):
        /**
        define variable sparkEntity as ISparkEntity no-undo.
        define variable sparkCount as integer no-undo.
        define variable sparkData as JsonObject no-undo.
        
        
        sparkEntity = cast(poEventArgs:BusinessEntity, ISparkEntity).        

        sparkData = new JsonObject().
        sparkData:Add('data', cast(poEventArgs:Response:Entity, JsonObject)).
        
        sparkCount = sparkEntity:HowMany(poEventArgs:Request:URI:GetQueryValue('filter')).
        sparkData:Add('count', sparkCount).
        
        poEventArgs:Response:Entity = sparkData.
*/         
        
        message 'INVOKED'.
/*
        assign poEventArgs:BusinessEntity = ServiceManager:Instance
                                                :GetService( // sports.CustomerBE
                                                             poEventArgs:Operation:TargetName ).
        
         
        poEventArgs:Response:StatusCode = 404.
        poEventArgs:Response:StatusReason = "Customer not available".
        poEventArgs:ReturnStatusCode = 0.
*/        
    end method.
    

end class.