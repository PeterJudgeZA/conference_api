/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
 /*------------------------------------------------------------------------
    File        : TalksHandler
    Description : 
    Author(s)   : pjudge
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using OpenEdge.Net.HTTP.StatusCodeEnum.
using OpenEdge.Web.IWebRequest.
using OpenEdge.Web.SendExceptionError.
using OpenEdge.Web.WebHandler.
using OpenEdge.Web.WebResponse.
using OpenEdge.Web.WebResponseWriter.
using Progress.Json.ObjectModel.JsonObject.

class Conference.SI.TalksHandler inherits WebHandler:
    {logic/shared/talks_dataset.i &ACCESS-LEVEL=private}
    
    // we are required to implement this method  
    method override protected integer HandleNotAllowedMethod( input poRequest as IWebRequest ):
        // we want to deal with errors ourselves
        undo, throw new SendExceptionError(StatusCodeEnum:MethodNotAllowed).
    end method.
    
    // we are required to implement this method 
    method override protected integer HandleNotImplemented( input poRequest as IWebRequest ):
        // we want to deal with errors ourselves
        undo, throw new SendExceptionError(StatusCodeEnum:NotImplemented).
    end method.
    
    method override protected integer HandleGet( input poRequest as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable filter as character no-undo.
        define variable skipRecs as integer no-undo initial 0.
        define variable topRecs as integer no-undo initial 0.
        define variable qryCnt as integer no-undo initial 0.
        define variable hBusinessLogic as handle no-undo.
        define variable writer as WebResponseWriter no-undo.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               msgBody          = new JsonObject()
               resp:ContentType = 'application/json'
               resp:Entity      = msgBody
               .
        //web/talks/{talk-id} | GET | n/a | n/a |  logic/talk/read_talks.p:get_single_talk
        if right-trim(poRequest:UriTemplate, '/':u) eq '/talks/~{talk-id}' then
        do:
            assign talkId = poRequest:GetPathParameter('talk-id')
                   record = new JsonObject()
                   .
            run logic/talk/read_talks.p single-run set hBusinessLogic.
            run get_single_talk in hBusinessLogic (talkId, output table ttTalk).
            
            buffer ttTalk:write-json('JsonObject', record, true).
            
            msgBody:Add('data',  record).
            msgBody:Add('count', 1).
        end.
        else
        //web/talks | GET | filter, top, skip  | n/a |  logic/talk/read_talks.p:get_filtered_talks
        if right-trim(poRequest:PathInfo, '/') eq '/talks' then
        do:
            assign topRecs  = integer(poRequest:URI:GetQueryValue('top'))
                   skipRecs = integer(poRequest:URI:GetQueryValue('skip'))
                   filter   = poRequest:URI:GetQueryValue('filter')
                   record   = new JsonObject()
                   .
            
            run logic/talk/read_talks.p single-run set hBusinessLogic.
            run get_filtered_talks in hBusinessLogic (input filter, skipRecs, topRecs,
                                                      output table ttTalk, output qryCnt).
            
            buffer ttTalk:write-json('JsonObject', record, true).
            
            msgBody:Add('data',  record).
            msgBody:Add('count', qryCnt).
        end.
        
        // write the response, whatever it is
        assign writer = new WebResponseWriter(resp).
        writer:Open().
        writer:Close().
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
    end method.
end class.