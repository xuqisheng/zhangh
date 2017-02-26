if object_id('pms_building') is not null
	drop table pms_building
;
CREATE TABLE pms_building
(
    roomno   char(8)  NOT NULL,
    type     char(4)  NOT NULL,
    tag      char(1)  DEFAULT '1' 			 NULL,
    wktime   datetime DEFAULT getdate() 	 NULL,
    changed  char(1)  DEFAULT 'F' 			 NULL,
    settime  datetime DEFAULT getdate() 	 NULL,
    chgtime  datetime DEFAULT getdate() 	 NULL,
    accnt    char(10) NULL,
    toroomno char(8)  DEFAULT '' null NULL
)
;
EXEC sp_primarykey 'pms_building', roomno,type;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON pms_building(roomno,type)
;
