/** This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.  **/
 /*------------------------------------------------------------------------
    File        : TalksHandler
    Description : 
    Author(s)   : pjudge
    Created     : 2017-10-04
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using OpenEdge.Net.HTTP.Filter.Payload.MessageWriter from propath.
using OpenEdge.Net.HTTP.IHttpResponse from propath.
using OpenEdge.Net.HTTP.StatusCodeEnum from propath.
using OpenEdge.Net.URI from propath.
using OpenEdge.Web.IWebRequest from propath.
using OpenEdge.Web.WebHandler from propath.
using OpenEdge.Web.WebRequest from propath.
using OpenEdge.Web.WebResponse from propath.
using OpenEdge.Web.WebResponseWriter from propath.
using OpenEdge.Net.HTTP.Filter.Writer.EntityWriterBuilder from propath.
using OpenEdge.Core.KeyValuePair from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Lang.Object from propath.

class Conference.SI.TalksHandler inherits WebHandler:
    {Conference/Shared/talks_dataset.i &ACCESS-LEVEL=private}
     
    define variable ttTalk as handle no-undo.
    method override protected integer HandleNotAllowedMethod( input poRequest as IWebRequest ):
        return integer(StatusCodeEnum:MethodNotAllowed).
    end method.

    method override protected integer HandleNotImplemented( input poRequest as IWebRequest ):
        return integer(StatusCodeEnum:NotImplemented).
/*        message req:PathParameterNames.           // tlk,sprk,...                   */
/*        message req:UriTemplate.                  // /speakers/{spkr}/talks/{tlk}   */
/*        message req:PathInfo.                     // /speakers/psc-123/talks/abl-042*/
/*        message req:TransportPath.                // /web                           */
/*        message req:GetPathParameter('tlk':u).    // abl-042                        */
/*        message req:Method.     // GET, PUT, POST, DELETE, ...                      */
/*                                                                                    */
    end method.
    
    method override protected integer HandleGet( input pReq as OpenEdge.Web.IWebRequest ):
        define variable talkId as character no-undo.
        define variable resp  as WebResponse no-undo.
        define variable msgBody as JsonObject no-undo.
        define variable talks as JsonArray no-undo.
        define variable record as JsonObject no-undo.
        define variable links as JsonObject no-undo.
        define variable speakerName as character no-undo.
        define variable linkBase as character no-undo.
        define variable filter as character no-undo.
        define variable skipRecs as integer no-undo initial 0.
        define variable topRecs as integer no-undo  initial 0.
        define variable qryCnt as integer no-undo.
        define variable hTalks as handle no-undo.
        
        resp = new OpenEdge.Web.WebResponse().
        
        if pReq:PathInfo eq '/talks/' then
        do:
            run logic/talk/read_talks.p persistent set hTalks.
            
            topRecs  = integer(pReq:URI:GetQueryValue('top')). 
            skipRecs = integer(pReq:URI:GetQueryValue('skip')).
            filter   = pReq:URI:GetQueryValue('filter').
            // get the requested talk data
            run get_filtered_talks in hTalks
                                        (input filter, skipRecs, topRecs,
                                         output table ttTalk, output qryCnt).
            
            msgBody = new JsonObject().
            resp:ContentType = 'application/vnd.conf.talks+json'.
            resp:Entity = msgBody.
            talks   = new JsonArray().
            msgBody:Add('talks', talks).
            links   = new JsonObject().
            msgBody:Add('links', links).
            linkBase = '/web/api/talks'. 
            links:Add('first', substitute('&1?skip=&2&top=&3', linkBase, 0, topRecs)).
            links:Add('next', substitute('&1?skip=&2&top=&3', linkBase, skipRecs, topRecs)).
            links:Add('prev', substitute('&1?skip=&2&top=&3', linkBase, skipRecs + skipRecs, topRecs)).
            links:Add('last',  substitute('&1?skip=-1', linkBase)).
            
            if skipRecs eq 0       then links:SetNull('prev').
            if topRecs le skipRecs then links:SetNull('next').
            
            for each ttTalk:
                run logic/speaker/get_name(ttTalk.speaker, output speakerName).
                
                record = new JsonObject().
                talks:Add(record).
                record:Read(buffer ttTalk:handle).
                links = new JsonObject().
                
                record:Add('links', links).
                
                links:Add('self',    linkBase + '/' + ttTalk.id).
                links:Add('speaker', '/api/web/speakers/' + speakerName ).
                links:Add('times',   '/api/web/timeslots?talk=' + ttTalk.id).
            end.
        end.
       // Add cleanup; error handling for path validation and other issues
    end method.

    method override public  integer HandleRequest():
        def var location as OpenEdge.Net.URI no-undo. 
        def var req  as OpenEdge.Web.IWebRequest no-undo.
        def var resp as OpenEdge.Web.WebResponse no-undo.
        
        assign req = new WebRequest().
        
        assign resp = new WebResponse().
        if     trim(req:PathInfo, '/':u) eq 'talks':u
           and req:Method eq 'POST':u 
           then
        do:
            assign resp:StatusCode = integer(OpenEdge.Net.HTTP.StatusCodeEnum:Created)    //201
                   location      = new URI(req:URI:Scheme, req:URI:Host, req:URI:Port)
                   location:Path = req:WebAppPath           // /api
                                 + req:TransportPath        // /web 
                                 + req:PathInfo             // /talks/
                                 + 'abl-999'
                  .
            resp:SetHeader('Location':u, location:ToString()).
        end.

        SendResponse(resp).
        return 0.
     end method.
        
        
        /*
         WebResponseBuilder
                :New()              // RETURN WebResponseBuilder (wraps 
                :From(IWebRequest)
                
                :Status(200)
                :WithBody('data', 'content/type')                
                :WithBody('data')                
                :SetHeader('location', 'abc')
                :SetCookie()
                :Created('location')
                :FoundAt('location')
                :Status(405)
                /* -- up to here returns the builder -- */
                
                :Response   // RETURN WebResponse or IHttpResponse
                :Reply      // RETURN VOID. Writes to WebResponseWriter
                .
        */
        
     
     method protected void SendResponse(input pResponse as IHttpResponse):
        define variable writer as WebResponseWriter no-undo.
        define variable msgWriter as MessageWriter no-undo.
        
        // write the response, whatever it is
        assign writer = new WebResponseWriter(pResponse).
        writer:Open().
        writer:Close().
     end method.
     
end class.