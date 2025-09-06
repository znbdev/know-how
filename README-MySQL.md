```markdown
MySQL
=====

MySQL数据库的增删改查（CRUD）SQL示例。这将包括创建表、插入数据、查询数据、更新数据和删除数据的基本操作示例。

=====

# 基本CRUD操作示例

以下是一组MySQL数据库的基本增删改查（CRUD）操作示例：

## 1. 创建表示例

```sql
-- 创建员工表
CREATE TABLE employees (
id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
department VARCHAR(50),
salary DECIMAL(10, 2),
hire_date DATE,
is_active BOOLEAN DEFAULT TRUE
);

-- 创建部门表
CREATE TABLE departments (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50) NOT NULL,
location VARCHAR(100)
);
```

## 2. 插入数据（Create）

```sql
-- 插入单条记录
INSERT INTO departments (name, location)
VALUES ('人力资源部', '北京');

INSERT INTO departments (name, location)
VALUES ('技术部', '上海');

INSERT INTO employees (first_name, last_name, email, department, salary, hire_date)
VALUES ('张', '三', 'zhangsan@company.com', '技术部', 8000.00, '2023-01-15');

-- 插入多条记录
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date)
VALUES
('李', '四', 'lisi@company.com', '人力资源部', 7500.00, '2023-02-20'),
('王', '五', 'wangwu@company.com', '技术部', 9000.00, '2023-03-10'),
('赵', '六', 'zhaoliu@company.com', '技术部', 8500.00, '2023-04-05');
```

## 3. 查询数据（Read）

```sql
-- 查询所有员工
SELECT * FROM employees;

-- 查询特定列
SELECT first_name, last_name, email FROM employees;

-- 带条件查询
SELECT * FROM employees WHERE department = '技术部';

-- 带排序的查询
SELECT * FROM employees ORDER BY salary DESC;

-- 带限制的查询
SELECT * FROM employees LIMIT 5;

-- 聚合查询
SELECT department, COUNT(*) as employee_count, AVG(salary) as avg_salary
FROM employees
GROUP BY department;

-- 多表连接查询
SELECT e.first_name, e.last_name, e.email, d.name as department_name
FROM employees e
JOIN departments d ON e.department = d.name;
```

## 4. 更新数据（Update）

```sql
-- 更新单个记录
UPDATE employees
SET salary = 9500.00
WHERE email = 'zhangsan@company.com';

-- 更新多个记录
UPDATE employees
SET salary = salary * 1.1
WHERE department = '技术部';

-- 更新多个字段
UPDATE employees
SET salary = 10000.00, is_active = FALSE
WHERE id = 1;
```

## 5. 删除数据（Delete）

```sql
-- 删除特定记录
DELETE FROM employees WHERE id = 1;

-- 删除满足条件的记录
DELETE FROM employees WHERE hire_date < '2023-01-01';

-- 注意：删除所有记录但保留表结构
-- DELETE FROM employees;

-- 注意：删除表（危险操作）
-- DROP TABLE employees;
```

## 6. 其他常用操作

```sql
-- 添加新列
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- 修改列
ALTER TABLE employees MODIFY COLUMN phone VARCHAR(30);

-- 删除列
ALTER TABLE employees DROP COLUMN phone;

-- 创建索引
CREATE INDEX idx_employee_department ON employees(department);

-- 查看表结构
DESCRIBE employees;

-- 清空表数据（保留表结构）
TRUNCATE TABLE employees;
```

# Reference

- [MySQL Workbench](https://www.mysql.com/cn/products/workbench/)
