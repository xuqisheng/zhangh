
CREATE proc p_tcr_lyrepo02
	@pc_id		VARCHAR(4),
	@bdate		DATETIME = NULL
AS

DECLARE		@CODE		VARCHAR(6),
				@rs INT,
				@rc	INT,
				@lrs	INT,
				@lrc INT,
				@codettl VARCHAR(7)



IF @bdate IS NULL
	SELECT @bdate = bdate FROM accthead


DELETE FROM lyrepo02 WHERE pc_id = @pc_id
INSERT INTO lyrepo02 SELECT @pc_id,CODE,num,descript,0,0,0,0 FROM lyrepo02 WHERE pc_id='9999'

DECLARE c_gds CURSOR FOR SELECT gclass+order_+nation,mtc+mgc+mmc,mtt+mgt+mmt,ytc+ygc+ymc,ytt+ygt+ymt FROM ygststa WHERE DATE = @bdate
OPEN c_gds
FETCH c_gds INTO @CODE,@rs,@rc,@lrs,@lrc
WHILE @@sqlstatus = 0
BEGIN
		IF @CODE = '3'
			SELECT @CODE = '2'
		SELECT @codettl = ''

		SELECT @codettl = '4049'+worldcode FROM countrycode WHERE CODE = SUBSTRING(@CODE,4,3)


		IF NOT EXISTS (SELECT 1 FROM lyrepo02 WHERE  pc_id = @pc_id AND CODE = @CODE)
			SELECT @CODE = '404'+worldcode FROM countrycode WHERE CODE = SUBSTRING(@CODE,4,3)

		UPDATE lyrepo02 SET rs = rs + @rs,rc = rc + @rc,lrs = lrs + @lrs,lrc = lrc + @lrc WHERE pc_id = @pc_id AND CODE= @CODE

 		UPDATE lyrepo02 SET rs = rs + @rs,rc = rc + @rc,lrs = lrs + @lrs,lrc = lrc + @lrc WHERE pc_id = @pc_id AND CODE = @codettl

		FETCH c_gds INTO @CODE,@rs,@rc,@lrs,@lrc
END
CLOSE c_gds
DEALLOCATE CURSOR c_gds


UPDATE lyrepo02 SET rs = rs- (SELECT SUM(rs) FROM lyrepo02 WHERE pc_id=@pc_id AND num IN ('02','03','04') ) WHERE num='06' AND pc_id=@pc_id
UPDATE lyrepo02 SET lrs = lrs - (SELECT SUM(lrs) FROM lyrepo02 WHERE pc_id=@pc_id AND num IN ('02','03','04') ) WHERE num='06' AND pc_id=@pc_id
UPDATE lyrepo02 SET rc = rc - (SELECT SUM(rc) FROM lyrepo02 WHERE pc_id=@pc_id AND num IN ('02','03','04') ) WHERE num='06' AND pc_id=@pc_id
UPDATE lyrepo02 SET lrc = lrc - (SELECT SUM(lrc) FROM lyrepo02 WHERE pc_id=@pc_id AND num IN ('02','03','04') )WHERE num='06' AND pc_id=@pc_id

SELECT num,descript,rs,lrs,rc,lrc,CONVERT(CHAR(2),CONVERT(INTEGER,num)+24),
char201 = (SELECT descript FROM lyrepo02 WHERE pc_id = @pc_id AND num=CONVERT(CHAR(2),CONVERT(INTEGER,a.num)+24)),
numb081 = (SELECT rs FROM lyrepo02 WHERE pc_id = @pc_id AND num=CONVERT(CHAR(2),CONVERT(INTEGER,a.num)+24)),
numb082 = (SELECT lrs FROM lyrepo02 WHERE pc_id = @pc_id AND num=CONVERT(CHAR(2),CONVERT(INTEGER,a.num)+24)),
numb083 = (SELECT rc FROM lyrepo02 WHERE pc_id = @pc_id AND num=CONVERT(CHAR(2),CONVERT(INTEGER,a.num)+24)),
numb084 = (SELECT lrc FROM lyrepo02 WHERE pc_id = @pc_id AND num=CONVERT(CHAR(2),CONVERT(INTEGER,a.num)+24))

FROM lyrepo02 a WHERE pc_id = @pc_id AND a.num<='24' ORDER BY num;
