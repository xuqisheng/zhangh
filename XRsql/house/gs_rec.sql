drop TABLE gs_rec ;
CREATE TABLE gs_rec 
(
    log_date datetime    NOT NULL,
    date     datetime    NOT NULL,
    code     char(1)     NOT NULL,
    site     varchar(10) NOT NULL,
    item     char(3)     NOT NULL,
    amount   money       DEFAULT 0				 NOT NULL,
    empno    char(10)     NOT NULL,
    sta      char(1)     DEFAULT 'I'				 NOT NULL,
    mode     char(1)     NOT NULL
)
EXEC sp_primarykey 'gs_rec', log_date,date,code,site,item;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON gs_rec(log_date ,date ,code ,site ,item)
;
CREATE NONCLUSTERED INDEX index2
    ON gs_rec(code ,site ,item)
;
CREATE NONCLUSTERED INDEX index3
    ON gs_rec(empno)
;