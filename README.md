# bdb2mongodb
This is script to convert BerkeleyDB file into MongoDB.
For any reason, if you consider to migrate from BerkeleyDB to MongoDb, you can use this script.

## Installation
sudo cpan MongoDB;

sudo cpan BerkeleyDB;

sudo cpan BDB::Wrapper;

## Usage
perl bdb2mongodb.pl --file=/../../../.../(...).bdb --database=...

### Actual example
perl bdb2mongodb/bdb2mongodb.pl --database=sakuhindb --file=/www/data/bdb/anime/works/youtube_name.bdb --key=url

### Parameters
--database=... Mandatory

--debug Optional: More info will be shown in the process

--drop or --initialize Optional: Drop the collection if exist

--file=... Mandatory: value for the input of BerkeleyDB

--key=... Optional: If the value is blank, "bdbKey" will be used key name of Berkeley DB's key's name. Index will be added to "bdbKey" automatically

--mongoport=... Optional: If the value is blank, 27017 will be used.

--mongoserver=... Optional: If the value is blank, localhost will be used.

--table= or --collection=... Optional: If the value is blank, the name of bdb file will be used for table name

--key=... Optional: If the value is blank, "bdbValue" will be used key name of Berkeley DB's value's name

# COPYRIGHT AND LICENSE
This software is Copyright (c) 2017 by 1st Class, Inc.
This is free software, licensed under BSD license.

# Author
Hajime Kurita, 1st class, inc.

http://twitter.com/hikarine3

https://github.com/hikarine3/

https://en.sakuhindb.com/pe/Administrator/
