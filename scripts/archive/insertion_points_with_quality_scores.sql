
--	DROP DATABASE insertion_points_with_quality_scores;
CREATE DATABASE insertion_points_with_quality_scores;
USE insertion_points_with_quality_scores;

CREATE TABLE insertion_points (
	subject_id VARCHAR(10),
	name VARCHAR(50),
	q_score INT,
	chromosome VARCHAR(10),
	position INT,
	direction VARCHAR(1),
	pre_or_post_herv VARCHAR(4)
);

CREATE INDEX subject_id ON insertion_points ( subject_id );
CREATE INDEX name ON insertion_points ( name );
CREATE INDEX q_score ON insertion_points ( q_score );
CREATE INDEX chromosome ON insertion_points ( chromosome );
CREATE INDEX position ON insertion_points ( position );

--	http://dev.mysql.com/doc/refman/5.7/en/load-data.html
--	This file must be readable by the 'mysql' user.
--
--	LOAD DATA INFILE '/Users/jakewendt/s3/herv/1000genomes/20160226.1000genomes.chimeric_hg19_realignment/insertion_points_with_quality.sorted.csv'
--	INTO TABLE insertion_points_with_quality_scores.insertion_points
--	FIELDS TERMINATED BY ','
--	IGNORE 1 LINES;
--

--ALTER TABLE insertion_points CHANGE insertion_point_name name VARCHAR(20);
--ALTER TABLE insertion_points CHANGE map_quality_score q_score INT;


SELECT 'name', 'name_count', 'subject_count',
	'ave_per_subject',
	'aveQ', 'minQ', 'maxQ',
	'stdQ', 'varQ'
UNION
SELECT name, COUNT(name) AS name_count,
	COUNT(DISTINCT subject_id) AS subject_count,
	TRUNCATE(COUNT(subject_id)/COUNT(DISTINCT subject_id),3) AS ave_per_subject,
	TRUNCATE(AVG(q_score), 3) AS aveQ, MIN(q_score) AS minQ, MAX(q_score) AS maxQ,
	TRUNCATE(STDDEV_POP(q_score),3) AS stdQ, TRUNCATE(VAR_POP(q_score),3) AS varQ
FROM insertion_points
GROUP BY name
INTO OUTFILE '/tmp/points.csv'
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\n';

--WHERE chromosome = 'chrY'
--HAVING AVG(q_score) > 10





CREATE TABLE input (
	siteq00 VARCHAR(50),
	prevalence FLOAT,
	meanNreads FLOAT,
	meanQ FLOAT,
	rangeQ FLOAT
);

CREATE INDEX siteq00 ON input ( siteq00 );

--	This file is from Amelia. Must convert the windows CRLF.
--
--	LOAD DATA INFILE '/Users/jakewendt/Downloads/q00_site_quality_scores.csv'
--	INTO TABLE insertion_points_with_quality_scores.input
--	FIELDS TERMINATED BY ','
--	IGNORE 1 LINES;
--

SELECT 'name', 'name_count', 'subject_count',
	'ave_per_subject',
	'aveQ', 'minQ', 'maxQ',
	'stdQ', 'varQ'
UNION
SELECT name, COUNT(name) AS name_count,
	COUNT(DISTINCT subject_id) AS subject_count,
	TRUNCATE(COUNT(subject_id)/COUNT(DISTINCT subject_id),3) AS ave_per_subject,
	TRUNCATE(AVG(q_score), 3) AS aveQ, MIN(q_score) AS minQ, MAX(q_score) AS maxQ,
	TRUNCATE(STDDEV_POP(q_score),3) AS stdQ, TRUNCATE(VAR_POP(q_score),3) AS varQ
FROM input i
JOIN insertion_points p ON i.siteq00 = p.name
GROUP BY name
INTO OUTFILE '/tmp/points.csv'
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\n';






