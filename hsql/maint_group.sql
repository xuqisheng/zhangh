ALTER TABLE rep_trial_balance_history CHANGE id id BIGINT(16) NULL;
UPDATE rep_trial_balance_history SET id = NULL;
ALTER TABLE rep_trial_balance_history CHANGE id id BIGINT(16) NOT NULL AUTO_INCREMENT,ADD PRIMARY KEY(id);

ALTER TABLE rep_jie_history CHANGE id id BIGINT(16) NULL;
UPDATE rep_jie_history SET id = NULL;
ALTER TABLE rep_jie_history CHANGE id id BIGINT(16) NOT NULL AUTO_INCREMENT,ADD PRIMARY KEY(id);

ALTER TABLE rep_jiedai_history CHANGE id id BIGINT(16) NULL;
UPDATE rep_jiedai_history SET id = NULL;
ALTER TABLE rep_jiedai_history CHANGE id id BIGINT(16) NOT NULL AUTO_INCREMENT,ADD PRIMARY KEY(id);

ALTER TABLE rep_dai_history CHANGE id id BIGINT(16) NULL;
UPDATE rep_dai_history SET id = NULL;
ALTER TABLE rep_dai_history CHANGE id id BIGINT(16) NOT NULL AUTO_INCREMENT,ADD PRIMARY KEY(id);

ALTER TABLE rep_jour_history CHANGE id id BIGINT(16) DEFAULT '0' NOT NULL, DROP PRIMARY KEY;
ALTER TABLE rep_jour_history CHANGE id id BIGINT(16) NULL;
UPDATE rep_jour_history SET id = NULL;
ALTER TABLE rep_jour_history CHANGE id id BIGINT(16) NOT NULL AUTO_INCREMENT,ADD PRIMARY KEY(id);
