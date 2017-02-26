drop TABLE front_selected ;
CREATE TABLE front_selected 
(
    modu_id char(2) NOT NULL,
    pc_id   char(4) NOT NULL,
    mode    char(1) NOT NULL,
    class   char(1) NOT NULL,
    accnt   char(10) NOT NULL
);
EXEC sp_primarykey 'dbo.front_selected', modu_id,pc_id,accnt;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON dbo.front_selected(modu_id,pc_id,accnt);
