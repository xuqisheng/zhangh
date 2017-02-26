
IF OBJECT_ID('cardmake') IS NOT NULL
    DROP TABLE cardmake
;
CREATE TABLE cardmake 
(
    date      datetime   DEFAULT getdate() NOT NULL,
    roomno    char(6)    NOT NULL,
    type      char(2)    NOT NULL,
    empno     char(10)    NOT NULL,
    accnt     char(10)   NOT NULL,
    dep       datetime   NOT NULL,
    pc_id     varchar(4) NOT NULL,
    cardnum   int        DEFAULT 0 NOT NULL,
    isdone    char(1)  default 'F'  NOT NULL,
    isvalid   char(1)  default 'T'  NOT NULL,
    doorcode  char(2)    NULL,
    card_type char(10)   NULL
);
EXEC sp_primarykey 'cardmake', date,roomno;
CREATE NONCLUSTERED INDEX index1  ON cardmake(roomno,date);
