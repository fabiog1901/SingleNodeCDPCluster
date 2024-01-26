CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'cloudera';
GRANT ALL ON hue.* TO 'hue'@'localhost' identified by 'cloudera';

CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON metastore.* TO 'hive'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE efm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON efm.* TO 'efm'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE nifireg DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON nifireg.* TO 'nifireg'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE registry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON registry.* TO 'registry'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE streamsmsgmgr DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON streamsmsgmgr.* TO 'streamsmsgmgr'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE ranger DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON ranger.* TO 'ranger'@'%' IDENTIFIED BY 'cloudera';

GRANT ALL ON ranger.* TO 'rangeradmin'@'%' IDENTIFIED BY 'cloudera';

GRANT ALL ON ranger.* TO 'rangerkms'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE smm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON smm.* TO 'smm'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE schemaregistry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON schemaregistry.* TO 'schemaregistry'@'%' IDENTIFIED BY 'cloudera';
