"Challenge 1"
USE Publications;

SELECT qty, title_id FROM sales;

SELECT price, royalty, title_id FROM `titles`;

SELECT title_id, au_id, royaltyper FROM titleauthor;

"Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication"
SELECT titleauthor.title_id, titleauthor.au_id, (titles.advance * titleauthor.royaltyper / 100) AS ADVANCE, (titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS SALES_ROYALTIES
FROM titleauthor
LEFT JOIN titles ON titles.title_id=titleauthor.title_id
LEFT JOIN sales ON sales.title_id=titles.title_id;

"Step 2: Aggregate the total royalties for each title and author"
SELECT step1.au_id, step1.title_id, ADVANCE+SUM(SALES_ROYALTIES) AS AGG_ROYALTIES
FROM (
SELECT titleauthor.title_id, titleauthor.au_id, (titles.advance * titleauthor.royaltyper / 100) AS ADVANCE, (titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS SALES_ROYALTIES
FROM titleauthor
LEFT JOIN titles ON titles.title_id=titleauthor.title_id
LEFT JOIN sales ON sales.title_id=titles.title_id
) step1
GROUP BY step1.title_id, step1.au_id;

"Step 3: Calculate the total profits of each author"
SELECT step2.au_id, SUM(AGG_ROYALTIES) AS PROFITS
FROM(
SELECT step1.au_id, step1.title_id, ADVANCE+SUM(SALES_ROYALTIES) AS AGG_ROYALTIES
FROM (
SELECT titleauthor.title_id, titleauthor.au_id, (titles.advance * titleauthor.royaltyper / 100) AS ADVANCE, (titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS SALES_ROYALTIES
FROM titleauthor
LEFT JOIN titles ON titles.title_id=titleauthor.title_id
LEFT JOIN sales ON sales.title_id=titles.title_id
) step1
GROUP BY step1.title_id, step1.au_id
) step2
GROUP BY step2.`au_id`
ORDER BY PROFITS DESC
LIMIT 3;

"Challenge 2"
"Step 1"
CREATE TEMPORARY TABLE Step1
SELECT titleauthor.title_id, titleauthor.au_id, (titles.advance * titleauthor.royaltyper / 100) AS ADVANCE, (titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS SALES_ROYALTIES
FROM titleauthor
LEFT JOIN titles ON titles.title_id=titleauthor.title_id
LEFT JOIN sales ON sales.title_id=titles.title_id;

"Step 2"
CREATE TEMPORARY TABLE Step2
SELECT Step1.au_id, Step1.title_id, AVG(Step1.ADVANCE)+SUM(Step1.SALES_ROYALTIES) AS AGG_ROYALTIES
FROM Step1
GROUP BY Step1.title_id, Step1.au_id;

"Step 3"
SELECT Step2.au_id, SUM(AGG_ROYALTIES) AS PROFITS
FROM Step2
GROUP BY Step2.`au_id`
ORDER BY PROFITS DESC
LIMIT 3;

"Challenge 3"
CREATE TABLE most_profiting_authors
SELECT Step2.au_id, SUM(AGG_ROYALTIES) AS PROFITS
FROM Step2
GROUP BY Step2.`au_id`
ORDER BY PROFITS DESC;