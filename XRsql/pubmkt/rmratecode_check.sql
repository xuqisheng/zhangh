if exists (select 1 from sysobjects where name='rmratecode_check' and type='U')
drop table rmratecode_check
;
CREATE TABLE dbo.rmratecode_check 
(
    pc_id         char(4)      NOT NULL,
    mdi_id        int          NOT NULL,
    accnt         char(10)     default '' NOT NULL,
    number        int          NOT NULL,
    roomno        char(5)      DEFAULT '' NOT NULL,
    code          char(4)      DEFAULT '' NOT NULL,
    pccode        char(5)      default '' NOT NULL,
    argcode       char(3)      DEFAULT '' NOT NULL,
    amount        money        default 0  ,
    quantity      money        DEFAULT 1 ,
    rule_calc     char(10)     NOT NULL,
    starting_date datetime     DEFAULT '2000/1/1' NOT NULL,
    closing_date  datetime     DEFAULT '2038/12/31' NOT NULL,
    starting_time char(8)      DEFAULT '00:00:00' NOT NULL,
    closing_time  char(8)      DEFAULT '23:59:59' NOT NULL,
    descript      char(30)     NOT NULL,
    descript1     char(30)     DEFAULT '' NOT NULL,
    pccodes       varchar(255) DEFAULT '' NOT NULL,
    pos_pccode    char(5)      DEFAULT '' NOT NULL,
    credit        money        DEFAULT 0 
)
;
EXEC sp_primarykey 'dbo.rmratecode_check', pc_id,mdi_id,accnt,number
;
IF OBJECT_ID('dbo.rmratecode_check') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.rmratecode_check >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.rmratecode_check >>>'
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.rmratecode_check(pc_id,mdi_id,accnt,number)
;
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.rmratecode_check') AND name='index1')
    PRINT '<<< CREATED INDEX dbo.rmratecode_check.index1 >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX dbo.rmratecode_check.index1 >>>'
;
