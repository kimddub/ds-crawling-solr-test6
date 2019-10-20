DROP DATABASE IF EXISTS ds5;

CREATE DATABASE ds5;

USE ds5;


# drop table `site`;
CREATE TABLE `site`(
	`code` INT(10) AUTO_INCREMENT PRIMARY KEY,
	site VARCHAR(100) NOT NULL
);

SELECT *
FROM `site`;

DESC `site`;

# truncate `site`;

INSERT INTO `site`
VALUES (1,"naver"),
	(2,"daum");


# drop table `category`;
CREATE TABLE `category`(
	`code` INT(10) AUTO_INCREMENT,
	sectionId VARCHAR(50) NOT NULL,
	subSectionId VARCHAR(50) NOT NULL,
	section VARCHAR(100) NOT NULL,
	subSection VARCHAR(100) NOT NULL,
	siteCode INT(10) NOT NULL,
	popState TINYINT(1) NOT NULL DEFAULT(0),
	PRIMARY KEY(`code`),
	FOREIGN KEY (siteCode) REFERENCES site (`code`) ON DELETE CASCADE
);

SELECT *
FROM `category`;

DESC `category`;

# truncate `category`;
INSERT INTO `category` 
VALUE (101,"102","276","사회","인물",1,0), 
	(102,"100","265","정치","국회/정당",1,0), 
	(103,"105","732","IT/과학","보안/해킹",1,0);
	
INSERT INTO `category` 
VALUE (201,"society","people?","사회","인물",2,0), 
	(202,"politics","assembly?","정치","국회/정당",2,0), 
	(203,"digital","software?","IT","소프트웨어",2,0);
	

# drop table `media`;
CREATE TABLE `media`(
	`code` INT(10) AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL
);

SELECT *
FROM `media`
ORDER BY `name`;

# truncate `media`;
INSERT INTO `media`
VALUES (1,"매일신문"),
	(2,"뉴시스");


# drop table article;
CREATE TABLE article(
	`code` INT(10) AUTO_INCREMENT,
	id VARCHAR(200) NOT NULL,
	siteCode INT(10) NOT NULL,
	mediaCode INT(10) NOT NULL,
	webPath VARCHAR(100) NOT NULL,
	regDate DATETIME NOT NULL,
	colDate DATETIME NOT NULL,
	title VARCHAR(1000) NOT NULL,
	`body` LONGTEXT,
	analysisState TINYINT(1) DEFAULT(0),
	PRIMARY KEY(`code`),
	UNIQUE KEY(id,siteCode,mediaCode),
	FOREIGN KEY (siteCode) REFERENCES site (`code`) ON DELETE CASCADE,
	FOREIGN KEY (mediaCode) REFERENCES media (`code`) ON DELETE CASCADE
);

DESC article;

SELECT *
FROM article
ORDER BY regDate DESC;

# truncate article;
INSERT INTO article (id,siteCode,mediaCode,webPath,regDate,colDate,BODY,analysisState) 
VALUES ("0004222112", 1, 3, "test111", NOW(), NOW(),"test111",0)
ON DUPLICATE KEY UPDATE
	`code`=LAST_INSERT_ID(`code`), 
	webPath = VALUES(webPath),
	regDate = VALUES(regDate),
	colDate = VALUES(colDate),
	`body` = VALUES(`body`),
	analysisState = 0;

SELECT COUNT(*)
FROM article
WHERE siteCode=2;

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM article
WHERE siteCode=2;

# 해당 카테고리의 게시물 몇개?
SELECT COUNT(*)
FROM article AS A
INNER JOIN (
	SELECT articleCode
	FROM categorize
	WHERE categoryCode = 101
) AS C
ON A.code = C.articleCode;

# 해당 카테고리의 게시물
SELECT *
FROM article AS A
INNER JOIN (
	SELECT articleCode
	FROM categorize
	WHERE categoryCode = 101
) AS C
ON A.code = C.articleCode
ORDER BY regDate DESC;

-- delete from article
-- order by regDate desc
-- limit 50;


	
# drop table `categorize`;
CREATE TABLE `categorize`(
	`code` INT(10) AUTO_INCREMENT,
	articleCode INT(10) NOT NULL,
	categoryCode INT(10) NOT NULL,
	regDate DATETIME NOT NULL,
	unregDate DATETIME DEFAULT(0),
	state TINYINT(1) DEFAULT(0),
	PRIMARY KEY(`code`),
	UNIQUE KEY(articleCode,categoryCode),
	FOREIGN KEY (articleCode) REFERENCES article (`code`) ON DELETE CASCADE,
	FOREIGN KEY (categoryCode) REFERENCES category (`code`) ON DELETE CASCADE
);


SELECT *
FROM `categorize`;

DESC `categorize`;

# truncate `categorize`;
INSERT INTO `categorize` (articleCode,categoryCode,regDate)
VALUES (1,1,0);



# drop table `keyword`;
CREATE TABLE `keyword`(
	`code` INT(10) AUTO_INCREMENT,
	word VARCHAR(100) NOT NULL,
	articlecode INT(10) NOT NULL,
	regDate DATETIME NOT NULL,
	PRIMARY KEY(`code`),
	UNIQUE KEY(word,articleCode),
	FOREIGN KEY (articleCode) REFERENCES article (`code`) ON DELETE CASCADE
);

SELECT *
FROM `keyword`;

DESC `keyword`;

# truncate `keyword`;
INSERT INTO `keyword`
VALUES (1,"keyword",1),
	(2,"keyword",1),
	(3,"keyword",3);


# bulk update
-- UPDATE `article`
-- SET analysisState = 1
-- WHERE `code` IN(1, 2 ,3);

-- UPDATE table
-- SET column2 = (CASE column1 WHEN 1 THEN 'val1'
--                  WHEN 2 THEN 'val2'
--                  WHEN 3 THEN 'val3'
--          END)
-- WHERE column1 IN(1, 2 ,3);


# 데이터 최근 크롤링 순서로 검색 
SELECT *
FROM article
ORDER BY colDate DESC, regDate DESC;

#형태소 분석 완료된 게시물 수 (게시물 기준)
SELECT COUNT(*)
FROM article
WHERE analysisState = 1;

#게시물의 카테고리 확인
SELECT *
FROM `categorize`
WHERE articleCode = 190;

# 키워드 조회
SELECT *
FROM `keyword`
ORDER BY `code` DESC;

# 한 게시물의 분석된 키워드 수
SELECT COUNT(*)
FROM `keyword`
WHERE articleCode = 1;


#형태소 분석 새로 할 때
-- UPDATE article
-- SET analysisState = 0

# 형태소 분석이 된 기사의 수 (키워드 기준)
SELECT COUNT(K.articleCode)
FROM (	SELECT COUNT(articleCode) AS `count`,articleCode
	FROM `keyword`
	GROUP BY articleCode
	ORDER BY articleCode ASC
) AS K

# 게시물 당 키워드 수
SELECT articleCode, COUNT(*) AS `count`
FROM keyword
GROUP BY articleCode
ORDER BY `count` DESC

# 시간 단위별 데이터 수집 건수
SELECT COUNT(*), colDate
FROM article
GROUP BY colDate

# 분 단위 데이터 수집 건수 + 사이트/카테고리/언론사 별
SELECT A2.timeZone, COUNT(*) AS `count`
FROM article AS A1
INNER JOIN (
	SELECT `code`, DATE_FORMAT(colDate, "%c-%e %H:%i") AS timeZone
	FROM `article`) AS A2
ON A1.`code` = A2.`code`
INNER JOIN (
	SELECT articleCode
	FROM categorize
	WHERE categoryCode = 101
) AS A3
ON A1.code = A3.articleCode
WHERE A1.siteCode=1 
-- 	AND A1.mediaCode=17
GROUP BY A2.timeZone

# 수집된 기사의 언론사 중 빈도높은순
SELECT mediaCode, COUNT(*) AS `count`
FROM article
GROUP BY mediaCode
ORDER BY `count` DESC;

# 분단위 데이터 수집 건수
SELECT A2.timeZone, COUNT(*) AS `count`
FROM article AS A1
INNER JOIN (
	SELECT `code`, DATE_FORMAT(colDate, "%c-%e %H:%i") AS timeZone
	FROM `article`) AS A2
ON A1.`code` = A2.`code`
-- INNER JOIN (
-- 	SELECT articleCode
-- 	FROM categorize
-- 	WHERE categoryCode = 101
-- ) AS A3
-- ON A1.code = A3.articleCode
WHERE 1=1
-- 	and A1.siteCode=2
-- 	AND A1.mediaCode=4
GROUP BY A2.timeZone;

# 시간대별 데이터 수집 건수
SELECT A1.code, A2.timezone, COUNT(*)
FROM article AS A1
INNER JOIN (
	SELECT `code`, DATE_FORMAT(colDate, "%c-%e %H 시") AS timezone
	FROM `article` ) AS A2
ON A1.`code` = A2.`code`
GROUP BY A2.timezone

# 사이트-카테고리의 최신 데이터 시간
SELECT regDate
FROM article
WHERE siteCode = 1 
AND `code` IN (SELECT articleCode FROM categorize WHERE categoryCode = 101)
ORDER BY regDate DESC
LIMIT 1;

# 이슈 키워드 조회 + 날짜
SELECT *, COUNT(`word`) AS `frequency` 
FROM `keyword`
GROUP BY `word`
HAVING articleCode IN ( SELECT `code`
			FROM article
			WHERE regDate BETWEEN "2019-10-11 00:00" AND "2019-10-12 17:00")
ORDER BY `frequency` DESC;

# 이슈 키워드 조회 + 사이트/언론사/카테고리
SELECT K.*, COUNT(K.`word`) AS `frequency` 
FROM `keyword` AS K
INNER JOIN ( SELECT `code`
		FROM article 
		WHERE siteCode =1 AND mediaCode=3) AS A
ON K.articleCode = A.`code`
INNER JOIN (
	SELECT articleCode
	FROM categorize
	WHERE categoryCode = 101
) AS C
ON  A.code = C.articleCode
GROUP BY K.`word`
HAVING K.articleCode IN ( SELECT `code`
			FROM article
			WHERE regDate BETWEEN "2019-10-11 00:00" AND "2019-10-12 17:00")
ORDER BY `frequency` DESC;

# 이슈 키워드 조회 + 사이트/언론사/카테고리 의 총 수
SELECT A.siteCode, A.mediaCode, C.categoryCode, COUNT(*) AS `counut`
FROM `keyword` AS K
INNER JOIN ( SELECT *
		FROM article 
		WHERE siteCode =1) AS A
ON K.articleCode = A.`code`
INNER JOIN (
	SELECT *
	FROM categorize
	WHERE categoryCode = 101
) AS C
ON  A.code = C.articleCode
WHERE K.articleCode IN ( SELECT `code`
			FROM article
			WHERE regDate BETWEEN "2019-10-08 00:00" AND "2019-10-13 17:00");

SELECT *
FROM article
WHERE `code` = 4999

SELECT *
FROM keyword
