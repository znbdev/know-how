Oracle
=====

Oracle数据库的增删改查（CRUD）SQL示例。这将包括创建表、插入数据、查询数据、更新数据和删除数据的基本操作示例。

=====

# 基本CRUD操作示例

以下是一组Oracle数据库的基本增删改查（CRUD）操作示例：

## 1. 创建表示例

```
sql
-- 创建员工表
CREATE TABLE employees (
employee_id NUMBER(10) PRIMARY KEY,
first_name VARCHAR2(50),
last_name VARCHAR2(50),
email VARCHAR2(100),
hire_date DATE,
salary NUMBER(10,2),
department_id NUMBER(5)
);

-- 创建部门表（用于连接查询示例）
CREATE TABLE departments (
department_id NUMBER(5) PRIMARY KEY,
department_name VARCHAR2(50)
);
```
## 2. 插入数据（Create）

```
sql
-- 插入部门数据
INSERT INTO departments (department_id, department_name) VALUES (10, '财务部');
INSERT INTO departments (department_id, department_name) VALUES (20, '人事部');
INSERT INTO departments (department_id, department_name) VALUES (30, '技术部');

-- 插入员工数据
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 5000.00, 10);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', TO_DATE('2019-03-22', 'YYYY-MM-DD'), 5500.00, 20);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (3, 'Bob', 'Johnson', 'bob.johnson@example.com', TO_DATE('2021-07-10', 'YYYY-MM-DD'), 4800.00, 10);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (4, 'Alice', 'Williams', 'alice.williams@example.com', TO_DATE('2018-11-05', 'YYYY-MM-DD'), 6200.00, 30);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (5, 'Charlie', 'Brown', 'charlie.brown@example.com', TO_DATE('2020-09-18', 'YYYY-MM-DD'), 4500.00, 30);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (6, 'Diana', 'Davis', 'diana.davis@example.com', TO_DATE('2017-05-30', 'YYYY-MM-DD'), 7100.00, 10);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (7, 'Eva', 'Miller', 'eva.miller@example.com', TO_DATE('2021-02-14', 'YYYY-MM-DD'), 5300.00, 20);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id)
VALUES (8, 'Frank', 'Wilson', 'frank.wilson@example.com', TO_DATE('2019-12-03', 'YYYY-MM-DD'), 4900.00, 30);
```
## 3. 查询数据（Read）

### 基本查询

```
sql
-- 查询所有数据
SELECT * FROM employees;

-- 查询特定列
SELECT employee_id, first_name, last_name, email FROM employees;

-- 带条件查询
SELECT * FROM employees WHERE department_id = 10;

-- 带排序的查询
SELECT * FROM employees ORDER BY salary DESC;

-- 带限制条件的查询
SELECT * FROM employees WHERE salary > 5000;

-- 模糊查询
SELECT * FROM employees WHERE first_name LIKE 'J%';
```
### 获取前N条记录

```
sql
-- 获取前10条记录（按薪资降序）
SELECT * FROM (
SELECT * FROM employees ORDER BY salary DESC
) WHERE ROWNUM <= 10;

-- 获取薪资最高的前5名员工
SELECT * FROM (
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary DESC
) WHERE ROWNUM <= 5;

-- Oracle 12c及以上版本的简化语法
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 5 ROWS ONLY;

-- 获取按薪资排序的前30%员工
SELECT employee_id, first_name, last_name, salary,
ROUND(PERCENT_RANK() OVER (ORDER BY salary DESC) * 100, 2) AS percent_rank
FROM employees
WHERE PERCENT_RANK() OVER (ORDER BY salary DESC) <= 0.3
ORDER BY salary DESC;
```
### 分页查询

```
sql
-- 使用ROWNUM实现分页（第1页，每页5条记录）
SELECT * FROM (
SELECT ROWNUM rn, t.* FROM (
SELECT * FROM employees ORDER BY employee_id
) t WHERE ROWNUM <= 5
) WHERE rn > 0;

-- 第2页，每页5条记录
SELECT * FROM (
SELECT ROWNUM rn, t.* FROM (
SELECT * FROM employees ORDER BY employee_id
) t WHERE ROWNUM <= 10
) WHERE rn > 5;

-- Oracle 12c及以上版本的简化分页语法
-- 第1页，每页5条记录
SELECT * FROM employees
ORDER BY employee_id
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 第2页，每页5条记录
SELECT * FROM employees
ORDER BY employee_id
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;
```
### 高级查询

```
sql
-- 聚合查询
SELECT department_id, COUNT(*) as employee_count, AVG(salary) as avg_salary,
MIN(salary) as min_salary, MAX(salary) as max_salary, SUM(salary) as total_salary
FROM employees
GROUP BY department_id;

-- 带条件的聚合查询
SELECT department_id, COUNT(*) as employee_count, AVG(salary) as avg_salary
FROM employees
WHERE salary > 5000
GROUP BY department_id
HAVING COUNT(*) >= 2;

-- 连接查询
SELECT e.first_name, e.last_name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 左连接查询（包含没有部门信息的员工）
SELECT e.first_name, e.last_name, e.salary, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- 子查询示例
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 相关子查询（查找每个部门薪资最高的员工）
SELECT e1.first_name, e1.last_name, e1.salary, e1.department_id
FROM employees e1
WHERE e1.salary = (
SELECT MAX(e2.salary)
FROM employees e2
WHERE e2.department_id = e1.department_id
);

-- 使用窗口函数进行排名
SELECT first_name, last_name, salary, department_id,
ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num,
RANK() OVER (ORDER BY salary DESC) as salary_rank,
DENSE_RANK() OVER (ORDER BY salary DESC) as dense_salary_rank,
ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_row_num
FROM employees;
```
### 复杂查询示例

```
sql
-- 使用CASE语句进行条件查询
SELECT first_name, last_name, salary,
CASE
WHEN salary >= 6000 THEN '高薪'
WHEN salary >= 5000 THEN '中等'
ELSE '较低'
END AS salary_level
FROM employees;

-- 使用UNION合并查询结果
SELECT first_name, last_name, '高薪员工' AS category
FROM employees WHERE salary >= 6000
UNION
SELECT first_name, last_name, '普通员工' AS category
FROM employees WHERE salary < 6000
ORDER BY category;

-- 使用WITH子句（CTE）简化复杂查询
WITH dept_avg AS (
SELECT department_id, AVG(salary) AS avg_dept_salary
FROM employees
GROUP BY department_id
)
SELECT e.first_name, e.last_name, e.salary, d.department_name, da.avg_dept_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN dept_avg da ON e.department_id = da.department_id
WHERE e.salary > da.avg_dept_salary;
```
## 4. 更新数据（Update）

```
sql
-- 更新单条记录
UPDATE employees
SET salary = 5200.00
WHERE employee_id = 1;

-- 更新多条记录
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10;

-- 使用子查询更新
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees)
WHERE employee_id = 3;
```
## 5. 删除数据（Delete）

```
sql
-- 删除特定记录
DELETE FROM employees WHERE employee_id = 3;

-- 删除满足条件的多条记录
DELETE FROM employees WHERE salary < 4000;

-- 删除所有记录（谨慎使用）
DELETE FROM employees;

-- 截断表（比DELETE更高效，但不可回滚）
TRUNCATE TABLE employees;
```
## 6. 其他常用操作

```
sql
-- 添加新列
ALTER TABLE employees ADD phone_number VARCHAR2(20);

-- 修改列
ALTER TABLE employees MODIFY email VARCHAR2(150);

-- 删除列
ALTER TABLE employees DROP COLUMN phone_number;

-- 创建索引
CREATE INDEX idx_employee_salary ON employees(salary);

-- 删除表
DROP TABLE employees;
```
# Reference
```

# Reference
```

# Reference
