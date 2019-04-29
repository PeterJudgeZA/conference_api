# SOLUTIONS
This `solutions/` directory contains partial and complete solutions for the workshops built on the `src/` code.

## Beyond The Code workshop
 File | Purpose 
---- | ---- 
NEXT-1.0.0.war | Complete ABL webapp with one Data Object Service - `ConfSvc/talks` - and its Catalog and mapping file. This webapp uses ANONYMOUS authentication (aka unsecured). Should be deployed using `tcman deploy -a NEXT /path/to/NEXT-1.0.0.war`
NEXT-1.0.0.zip | An incremental ABL webapp containing one Data Object Service - `ConfSvc/talks` - and its Catalog and mapping file. This webapp uses ANONYMOUS authentication (aka unsecured). Should be deployed using `deploysvc -a NEXT /path/to/NEXT-1.0.0.zip`
Speakers.template | A template for the Data Object Service interface for speakers. Contains the CRUDS operation signatures.
Talks.template | A template for the Data Object Service interface for talks. Contains the CRUDS operation signatures.
Conference/SI/Speakers.cls | A completed service interface for accessing speakers logic 
Conference/SI/Talks.cls | A completed service interface for accessing talks logic 



## Implementing REST Service Interfaces workshop
 File | Purpose 
---- | ---- 
Conference/SI/TalksHandler.cls | A complete WebHandler service interface implementation for accessing talks logic.
conf.map | A Data Object Handler mapping file (service descriptor) for exposing the talks logic via a RESTy API.
