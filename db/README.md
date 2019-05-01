# Conference Sample Database
This folder contains a sample database for use with the Conference API's.

## DB Structure
The database is configured with standard Schema, Data, Index, and LOB areas which are consistent with the Sports2020 database included with OE12 and as utilized for various modernization demos.
 
## Creation
Through use of the included build.xml ANT can be utilized to create an instance in a default location:

- **Windows:** C:\Databases\conference 
- **Unix:** /usr/databases/conference

From a ProEnv session as administrator simply run `ant create` in this directory to generate a copy of the database using the default path. The database will be created with 8K blocks, UTF-8 codepage, and will load all schema and data located within this directory.

## Development
If the overall repo directory is imported into Progress Developer Studio for OpenEdge (PDSOE), a database connection "conf" is expected. Import the `db_import.xml` file into the Database Connections of PDSOE to add the sample database at the default location for Windows using port 2468 and with automatic startup/shutdown enabled.
