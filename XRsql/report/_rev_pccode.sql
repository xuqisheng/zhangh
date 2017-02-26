
// for opera report - payment and revenue 

if object_id('rev_pccode') is not null
	drop TABLE rev_pccode;
CREATE TABLE rev_pccode 
(
    date   datetime   NOT NULL,
    pccode varchar(5) NOT NULL,
    day    money      DEFAULT 0 NOT NULL,		-- gross 
    month  money      DEFAULT 0 NOT NULL,
    year   money      DEFAULT 0 NOT NULL,
    nday    money      DEFAULT 0 NOT NULL,	-- net 
    nmonth  money      DEFAULT 0 NOT NULL,
    nyear   money      DEFAULT 0 NOT NULL
);
CREATE UNIQUE NONCLUSTERED INDEX index1  ON rev_pccode(pccode);


if object_id('yrev_pccode') is not null
	drop TABLE yrev_pccode;
CREATE TABLE yrev_pccode 
(
    date   datetime   NOT NULL,
    pccode varchar(5) NOT NULL,
    day    money      DEFAULT 0 NOT NULL,		-- gross 
    month  money      DEFAULT 0 NOT NULL,
    year   money      DEFAULT 0 NOT NULL,
    nday    money      DEFAULT 0 NOT NULL,	-- net 
    nmonth  money      DEFAULT 0 NOT NULL,
    nyear   money      DEFAULT 0 NOT NULL
);
CREATE UNIQUE NONCLUSTERED INDEX index1 ON yrev_pccode(date,pccode);

