
/*------------------------------------------------------------------------
    File        : add_talk_meta
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed May 16 16:49:42 EDT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

            
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
            