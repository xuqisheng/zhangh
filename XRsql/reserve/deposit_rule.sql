if exists(select 1 from sysobjects where name='deposit_rule' and type='U')
drop table deposit_rule
;
CREATE TABLE deposit_rule 
(
    code      char(10)      NOT NULL,
    descript  varchar(255)  DEFAULT '' NOT NULL,
    descript1 varchar(255)  DEFAULT '' NOT NULL,
    type      char(1)       NOT NULL,
    amount    money			 DEFAULT 0 NOT NULL,
    arr_bef   int           NULL,
    bok_aft   int           NULL,
    halt      char(1)       DEFAULT 'F' NOT NULL,
    seq       int           NULL,
    cby       char(10)      NULL,
    changed   datetime      NULL
)

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON deposit_rule(code)
;