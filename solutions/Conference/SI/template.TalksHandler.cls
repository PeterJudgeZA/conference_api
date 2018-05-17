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

using OpenEdge.Net.HTTP.Filter.Payload.MessageWriter.
using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Net.HTTP.StatusCodeEnum.
using OpenEdge.Web.IWebRequest.
using OpenEdge.Web.SendExceptionError.
using OpenEdge.Web.WebHandler.
using OpenEdge.Web.WebResponse.
using OpenEdge.Web.WebResponseWriter.
using Progress.Json.ObjectModel.JsonObject.

class Conference.SI.TalksHandler inherits WebHandler:
    {logic/shared/talks_dataset.i &ACCESS-LEVEL=private}
    
    method override protected integer HandleDelete(input pReq as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable hBusinessLogic as handle no-undo.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               msgBody          = new JsonObject()
               resp:ContentType = 'application/vnd.conf.talks+json'
               resp:Entity      = msgBody
               .
        //web/talks/{talk-id} | DELETE | n/a | n/a |  logic/talk/schedule_talk.p:cancel_scheduled_talk_by_talk
        if right-trim(pReq:UriTemplate, '/':u) eq '/talks/~{talk-id}' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id').
            
            run logic/talk/schedule_talk.p single-run set hBusinessLogic.
            run cancel_scheduled_talk_by_talk in hBusinessLogic (talkId).
        end.
        
        SendResponse(resp).
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
    end method.

    method override protected integer HandleNotAllowedMethod( input poRequest as IWebRequest ):
        // we want to deal with errors ourselves
        undo, throw new SendExceptionError(StatusCodeEnum:MethodNotAllowed).
    end method.
    
    method override protected integer HandleNotImplemented( input poRequest as IWebRequest ):
        // we want to deal with errors ourselves
        undo, throw new SendExceptionError(StatusCodeEnum:NotImplemented).
    end method.
    
    method override protected integer HandleGet( input pReq as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable filter as character no-undo.
        define variable skipRecs as integer no-undo initial 0.
        define variable topRecs as integer no-undo initial 0.
        define variable qryCnt as integer no-undo initial 0.
        define variable streams as character extent no-undo.
        define variable hBusinessLogic as handle no-undo.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               msgBody          = new JsonObject()
               resp:ContentType = 'application/vnd.conf.talks+json'
               resp:Entity      = msgBody
               .
        //web/talks/{talk-id} | GET | n/a | n/a |  logic/talk/read_talks.p:get_single_talk
        if right-trim(pReq:UriTemplate, '/':u) eq '/talks/~{talk-id}' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id')
                   record = new JsonObject()
                   .
            run logic/talk/read_talks.p single-run set hBusinessLogic.
            run get_single_talk in hBusinessLogic (talkId, output table ttTalk).
            
            buffer ttTalk:write-json('JsonObject', record, true).
            
            msgBody:Add('data',  record).
            msgBody:Add('count', 1).
        end.
        else
        //web/talks/{talk-id}/schedule | GET | n/a | n/a| logic/talk/list_talk_schedule.p:get_schedule
        if right-trim(pReq:UriTemplate, '/':u) eq '/talks/~{talk-id}/schedule' then
        do:
            // IMPLEMENTATION HERE
        end.        
        //web/talks/streams | GET | n/a | n/a | logic/talk/streams.p:list_streams
        if right-trim(pReq:PathInfo, '/') eq '/talks/streams' then
        do:
            // IMPLEMENTATION HERE
        end.
        else
        //web/talks | GET | filter, top, skip  | n/a |  logic/talk/read_talks.p:get_filtered_talks
        if right-trim(pReq:PathInfo, '/') eq '/talks' then
        do:
            // HOW-TO get values from the QUERY string
            assign topRecs  = integer(pReq:URI:GetQueryValue('top'))
                   skipRecs = integer(pReq:URI:GetQueryValue('skip'))
                   filter   = pReq:URI:GetQueryValue('filter')
                   .
            // IMPLEMENTATION HERE
        end.
        
        SendResponse(resp).
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
    end method.
    
    method override protected integer HandlePut( input pReq as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable hBusinessLogic as handle no-undo.
        define variable talkName as character no-undo.
        define variable speaker as character no-undo.
        define variable talkAbstract as character no-undo.
        define variable contentUrl as character no-undo.
        define variable contentType as character no-undo.
        define variable appBase as character no-undo.
        define variable linkBase as character no-undo.
        define variable streamId as character no-undo.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               msgBody          = new JsonObject()
               resp:ContentType = 'application/vnd.conf.talks+json'
               resp:Entity      = msgBody
               .
        
        // POST is usually a CREATE but we're cheating a little here
        //web/talks| PUT | n/a | {"speaker": string, "name": string , "abstract": string, "contentUrl": string, "contentType": string } |  logic/talk/new_talk.p:create_talk
        if right-trim(pReq:PathInfo, '/') eq '/talks' then
        do:
            assign record          = cast(pReq:Entity, JsonObject)
                   //201/Created
                   resp:StatusCode = StatusCodeEnum:Created:GetValue()
                   appBase         = trim(pReq:WebAppPath, '/':u)  + '/'
                                   + trim(pReq:TransportPath, '/':u) + '/' 
                   linkBase        = appBase + trim(pReq:PathInfo, '/':u)
                   .
            // GET THE 'name' PROPERTY FROM THE INPUT JSON
            assign talkName = record:GetCharacter('name').
            
            // CALL BUSINESS LOGIC
            
            
            //EXAMPLE SETTING THE Location HEADER TO something like api/web/talks/ABL-018
            resp:SetHeader('Location', linkBase + '/' + talkId).
        end.
        else
        //web/talks/{talk-id} | PUT | n/a | ttTalk | logic/talk/update_talk.p:update_talks
        if right-trim(pReq:UriTemplate, '/':u) eq '/talks/~{talk-id}' then
        do:
            // IMPLEMENTATION HERE
        end.
        else
        //web/talks/{talk-id}/{stream-id} | PUT | n/a | n/a | logic/talk/update_talk.p:switch_stream
        if right-trim(pReq:UriTemplate, '/':u) eq '/talks/~{talk-id}/~{stream-id}' then
        do:
            // IMPLEMENTATION HERE
        end.
        
        SendResponse(resp).
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
    end method.
    
    /* Writes a response back to the client
       
       @param IHttpResponse The response to write */
    method protected void SendResponse(input pResponse as IHttpResponse):
        define variable writer as WebResponseWriter no-undo.
        define variable msgWriter as MessageWriter no-undo.
        
        // write the response, whatever it is
        assign writer = new WebResponseWriter(pResponse).
        writer:Open().
        writer:Close().
    end method.
    
    /* Handles an exception that has been raised while dealing with the request 
    
       @param Progress.Lang.Error The as-yet-unhandled exception
       @param IWebRequest The request that resulting in the exception
       @return integer A non-null status code use to deal with errors */
    method override protected integer HandleException(input poError as Progress.Lang.Error,
                                                      input pReq as IWebRequest):
        define variable resp as IHttpResponse no-undo.
        
        if not CanAcceptContentType(pReq, 'application/json') then
        do:
            if type-of(poError, SendExceptionError) then
                return integer(cast(poError, SendExceptionError):StatusCode).
            else
                return integer(StatusCodeEnum:NotAcceptable). 
        end.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               resp:ContentType = 'application/vnd.conf.error+json'
               resp:Entity      = poError
               .
        if type-of(poError, SendExceptionError) then
            assign resp:StatusCode = integer(cast(poError, SendExceptionError):StatusCode). 
        else
            assign resp:StatusCode = integer(StatusCodeEnum:InternalServerError).       //500
        
        // we will return the error
        SendResponse(resp).
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
        
        // if something goes horribly horribly wrong
        catch writeError as Progress.Lang.Error :
            return integer(StatusCodeEnum:InternalServerError).       //500
        end catch.
    end method.
    
end class.