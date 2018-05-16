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
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonDataType.
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
        if pReq:UriTemplate eq '/talks/~{talk-id}/' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id')
                   record = new JsonObject()
                   .
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
        if pReq:UriTemplate eq '/talks/~{talk-id}/' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id')
                   record = new JsonObject()
                   .
            run logic/talk/read_talks.p single-run set hBusinessLogic.
            run get_single_talk in hBusinessLogic (talkId, output table ttTalk).
            
            //buffer ttTalk:write-json('JsonObject', record, true).
            record:Read(buffer ttTalk:handle).
            
            msgBody:Add('data',  record).
            msgBody:Add('count', 1).
        end.
        else
        //web/talks/{talk-id}/schedule | GET | n/a | n/a| logic/talk/list_talk_schedule.p:get_schedule
        if pReq:UriTemplate eq '/talks/~{talk-id}/schedule' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id')
                   record = new JsonObject()
                   .
            run logic/talk/list_talk_schedule.p single-run set hBusinessLogic.
            run get_schedule in hBusinessLogic (talkId, output table ttTimeslot).
            
            record:Read(buffer ttTimeslot:handle).
            
            msgBody:Add('data',  record).
        end.        
        //web/talks/streams | GET | n/a | n/a | logic/talk/streams.p:list_streams
        if pReq:PathInfo eq '/talks/streams/' then
        do:
            run logic/talk/streams.p single-run set hBusinessLogic.
            run list_streams in hBusinessLogic (output streams).
            
            msgBody:Add('data', new JsonArray(streams)).
        end.
        else
        //web/talks | GET | filter, top, skip  | n/a |  logic/talk/read_talks.p:get_filtered_talks
        if pReq:PathInfo eq '/talks/' then
        do:
            assign topRecs  = integer(pReq:URI:GetQueryValue('top'))
                   skipRecs = integer(pReq:URI:GetQueryValue('skip'))
                   filter   = pReq:URI:GetQueryValue('filter')
                   record   = new JsonObject()
                   .
            
            run logic/talk/read_talks.p single-run set hBusinessLogic.
            run get_filtered_talks in hBusinessLogic (input filter, skipRecs, topRecs,
                                                      output table ttTalk, output qryCnt).
            
            record:Read(buffer ttTalk:handle).
            
            msgBody:Add('data',  record).
            msgBody:Add('count', qryCnt).
        end.
        
        SendResponse(resp).
        
        // Add cleanup; error handling for path validation and other issues
        return 0.
    end method.
    
    method override protected integer HandlePost( input pReq as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable record as JsonObject no-undo.
        define variable talkName as character no-undo.
        define variable streamId as character no-undo.
        define variable appBase as character no-undo.
        define variable linkBase as character no-undo.
        define variable hBusinessLogic as handle no-undo.
        
        assign resp             = new OpenEdge.Web.WebResponse()
               resp:StatusCode  = StatusCodeEnum:Created:GetValue()     //201/Created
               msgBody          = new JsonObject()
               resp:ContentType = 'application/vnd.conf.talks+json'
               resp:Entity      = msgBody
               
               appBase          = trim(pReq:WebAppPath, '/':u)  + '/'
                                + trim(pReq:TransportPath, '/':u) + '/' 
               linkBase         = appBase + trim(pReq:PathInfo, '/':u)
               .
        
        //web/talks| POST | n/a | {"stream": string, "name": string } |  logic/talk/new_talk.p:new_talk
        if pReq:PathInfo eq '/talks/' then
        do:
            assign record = cast(pReq:Entity, JsonObject).
            if     record:Has('stream')
               and record:GetType('stream') eq JsonDataType:STRING
            then
                assign streamId = record:GetCharacter('stream').

            if     record:Has('name')
               and record:GetType('name') eq JsonDataType:STRING
            then
                assign talkName = record:GetCharacter('name').
            
            run logic/talk/new_talk.p single-run set hBusinessLogic.
            run new_talk in hBusinessLogic (streamId, talkName, output talkId).
            
            resp:SetHeader('Location', linkBase + '/' + talkId).  
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
        if pReq:PathInfo eq '/talks/' then
        do:
            assign record          = cast(pReq:Entity, JsonObject)
                   //201/Created
                   resp:StatusCode = StatusCodeEnum:Created:GetValue()
                   appBase         = trim(pReq:WebAppPath, '/':u)  + '/'
                                   + trim(pReq:TransportPath, '/':u) + '/' 
                   linkBase        = appBase + trim(pReq:PathInfo, '/':u)
                   .
            if     record:Has('name')
               and record:GetType('name') eq JsonDataType:STRING
            then
                assign talkName = record:GetCharacter('name').
            if     record:Has('speaker')
               and record:GetType('speaker') eq JsonDataType:STRING
            then
                assign speaker = record:GetCharacter('speaker').
            if     record:Has('talkAbstract')
               and record:GetType('talkAbstract') eq JsonDataType:STRING
            then
                assign talkAbstract = record:GetCharacter('talkAbstract').
            if     record:Has('contentUrl')
               and record:GetType('contentUrl') eq JsonDataType:STRING
            then
                assign contentUrl = record:GetCharacter('contentUrl').
            if     record:Has('contentType')
               and record:GetType('contentType') eq JsonDataType:STRING
            then
                assign contentType = record:GetCharacter('contentType').
            
            run logic/talk/new_talk.p single-run set hBusinessLogic.
            run create_talk in hBusinessLogic (talkName, speaker, talkAbstract, contentUrl, contentType, 
                                               output talkId).
            
            resp:SetHeader('Location', linkBase + '/' + talkId).
        end.
        else
        //web/talks/{talk-id} | PUT | n/a | ttTalk | logic/talk/update_talk.p:update_talks
        if pReq:UriTemplate eq '/talks/~{talk-id}/' then
        do:
            assign talkId = pReq:GetPathParameter('talk-id')
                   record = cast(pReq:Entity, JsonObject)
                   .
            buffer ttTalk:read-json('JsonObject', record, 'EMPTY').
            
            // some validation?
            if can-find(ttTalk where ttTalk.id ne talkId) then
                undo, throw new SendExceptionError(StatusCodeEnum:BadRequest,
                                                   substitute('Bad request: talk.id mismatch &1', talkId)) .
            
            run logic/talk/update_talk.p single-run set hBusinessLogic.
            run update_talks in hBusinessLogic (input-output table ttTalk).
            
            assign record = new JsonObject().
            record:Read(buffer ttTalk:handle).
            
            msgBody:Add('data',  record).
        end.
        else
        //web/talks/{talk-id}/{stream-id} | PUT | n/a | n/a | logic/talk/update_talk.p:switch_stream
        if pReq:UriTemplate eq '/talks/~{talk-id}/~{stream-id}/' then
        do:
            assign talkId   = pReq:GetPathParameter('talk-id')
                   streamId = pReq:GetPathParameter('stream-id')
                   .
            run logic/talk/update_talk.p single-run set hBusinessLogic.
            run switch_stream in hBusinessLogic (talkId, input-output streamId).
            
            msgBody:Add('data',  streamId).
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
    end method.
    
end class.