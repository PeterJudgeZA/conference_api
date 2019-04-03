Folder structure of this project:

/AppServer
    - Hosts the ABL code. 
      The ABL code in this folder will be deployed to the publish folder of ABL application in the PAS for OpenEdge server. 
      This ABL code is for common business logic and will be shared by all the ABL Services deployed on the same ABL application.

/PASOEContent
    - Contains all the files that will be deployed to PAS for OpenEdge server as a standalone web application.
    
/PASOEContent/static
    - Contains all the static resources like images, error pages, header and footer, and login pages. 
        
/PASOEContent/WEB-INF/oeablSecurity.[properties|csv]
    - Contains the security settings of the web application. If you update these files, you must disable and enable the Java web application.
    
/PASOEContent/WEB-INF/openedge
    - Contains the ABL code or r-code files for the web application that you are deploying. For example, web-handlers. If you want to publish/export the business entities along with web application, create them under this folder.
    
/PASOEContent/WEB-INF/tlr
    - Contains the templates for tailoring files. It runs the core tailoring for adding and removing an oeabl Java web application to/from openedge.properties file. 
      If changes are made here you must undeploy the Java web application and then deploy its replacement to pick up the deployment tailoring changes. 