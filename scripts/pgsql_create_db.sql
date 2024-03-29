CREATE ROLE scm LOGIN PASSWORD 'cloudera';
CREATE DATABASE scm OWNER scm ENCODING 'UTF8';

CREATE ROLE amon LOGIN PASSWORD 'cloudera';
CREATE DATABASE amon OWNER amon ENCODING 'UTF8';

CREATE ROLE rman LOGIN PASSWORD 'cloudera';
CREATE DATABASE rman OWNER rman ENCODING 'UTF8';

CREATE ROLE hue LOGIN PASSWORD 'cloudera';
CREATE DATABASE hue OWNER hue ENCODING 'UTF8';

CREATE ROLE hive LOGIN PASSWORD 'cloudera';
CREATE DATABASE metastore OWNER hive ENCODING 'UTF8';

CREATE ROLE nav LOGIN PASSWORD 'cloudera';
CREATE DATABASE nav OWNER nav ENCODING 'UTF8';

CREATE ROLE navms LOGIN PASSWORD 'cloudera';
CREATE DATABASE navms OWNER navms ENCODING 'UTF8';

CREATE ROLE oozie LOGIN PASSWORD 'cloudera';
CREATE DATABASE oozie OWNER oozie ENCODING 'UTF8';

CREATE ROLE ranger LOGIN PASSWORD 'cloudera';
CREATE ROLE rangeradmin LOGIN PASSWORD 'cloudera';
CREATE ROLE rangerkms LOGIN PASSWORD 'cloudera';
CREATE DATABASE ranger OWNER ranger ENCODING 'UTF8';

ALTER DATABASE metastore SET standard_conforming_strings=off;
ALTER DATABASE oozie SET standard_conforming_strings=off;


