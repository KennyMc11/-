-- ========== 1. ОКОННЫЕ ФУНКЦИИ ==========

-- ROW_NUMBER: нумерация (3 самых дорогих товара в категории)
SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
  FROM products
) t WHERE rn <= 3;

-- LAG: разница с прошлым днем
SELECT date, amount, amount - LAG(amount) OVER (ORDER BY date) AS diff
FROM sales;

-- ========== 2. РАБОТА С ДУБЛИКАТАМИ ==========

-- Найти дубли по email
SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

-- Удалить дубли (оставить один)
DELETE FROM users WHERE id NOT IN (SELECT MIN(id) FROM users GROUP BY email);

-- ========== 3. ОБНОВЛЕНИЕ И ВСТАВКА ==========

-- UPSERT (есть - обнови, нет - вставь)
INSERT INTO stock (product_id, qty) VALUES (1, 100)
ON DUPLICATE KEY UPDATE qty = qty + 100;

-- UPDATE с JOIN
UPDATE orders o JOIN returns r ON o.id = r.order_id SET o.status = 'returned';

-- ========== 4. АГРЕГАЦИЯ И ГРУППИРОВКА ==========

-- ИТОГИ с ROLLUP (общий + по регионам + по городам)
SELECT region, city, SUM(sales) FROM orders GROUP BY ROLLUP(region, city);

-- PIVOT через CASE (месяцы в столбцы)
SELECT 
  SUM(CASE WHEN MONTH(date)=1 THEN amount END) AS Jan,
  SUM(CASE WHEN MONTH(date)=2 THEN amount END) AS Feb
FROM sales WHERE YEAR(date) = 2024;

-- ========== 5. ПОДЗАПРОСЫ ==========

-- Выше среднего
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- EXISTS (есть ли заказы)
SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);

-- ========== 6. CTE (ОБЩИЕ ТАБЛИЧНЫЕ ВЫРАЖЕНИЯ) ==========

-- Простой CTE для читаемости
WITH expensive AS (SELECT * FROM products WHERE price > 1000)
SELECT category, COUNT(*) FROM expensive GROUP BY category;

-- Рекурсивный CTE (числа от 1 до 10)
WITH RECURSIVE nums(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM nums WHERE n < 10
)
SELECT * FROM nums;

-- ========== 7. ТИПЫ JOIN ==========

-- LEFT JOIN: клиенты без заказов
SELECT c.* FROM customers c LEFT JOIN orders o ON c.id = o.cust_id WHERE o.id IS NULL;

-- INNER JOIN: только купившие
SELECT DISTINCT c.name FROM customers c JOIN orders o ON c.id = o.cust_id;

-- ========== 8. СТРОКИ И JSON ==========

-- Склеить строки (GROUP_CONCAT)
SELECT customer_id, GROUP_CONCAT(product_name SEPARATOR ', ') AS products
FROM orders GROUP BY customer_id;

-- Разбить строку "a,b,c" на строки (MySQL)
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('a,b,c', ',', n), ',', -1) AS val
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) AS nums(n);

-- JSON: взять поле
SELECT JSON_EXTRACT('{"name":"John"}', '$.name');