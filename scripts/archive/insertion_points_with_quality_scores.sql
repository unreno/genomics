
--	DROP DATABASE insertion_points_with_quality_scores;
CREATE DATABASE insertion_points_with_quality_scores;
USE insertion_points_with_quality_scores;

CREATE TABLE insertion_points (
	subject_id VARCHAR(10), 
	name VARCHAR(20),
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

