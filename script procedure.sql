-- PARTE 1 — Índices e Consultas no cenário company
--  Análise de dados mais relevantes para criação dos índices:
-- Consultas:
-- Qual o departamento com maior número de pessoas?
-- Atributos usados: department.idDepartment, employee.idDepartment
-- Acesso frequente: employee.idDepartment
-- Quais são os departamentos por cidade?
-- Atributos usados: department.city
-- Acesso frequente: department.city
-- Relação de empregados por departamento
-- Atributos usados: employee.idDepartment, employee.name

-- Criando as tabelas

show databases;
create database if not exists departaments;
use departaments;
CREATE TABLE if not exists department (
    idDepartment INT PRIMARY KEY AUTO_INCREMENT,
    deptName VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE if not exists employee (
    idEmployee INT PRIMARY KEY AUTO_INCREMENT,
    empName VARCHAR(100),
    salary DECIMAL(10,2),
    idDepartment INT,
    FOREIGN KEY (idDepartment) REFERENCES department(idDepartment)
);

-- ÍNDICES CRIADOS:

-- Índice em employee.idDepartment para otimizar buscas por departamento
CREATE INDEX idx_employee_department ON employee(idDepartment);

-- Índice em department.city para otimizar buscas por cidade
CREATE INDEX idx_department_city ON department(city);
-- Motivo:
-- employee.idDepartment é chave estrangeira, muito usada em consultas e junções.
-- department.city é usada para filtros frequentes.
-- Escolhido B-Tree (default) pois são colunas com ordenação e filtros.

-- Consultas:


-- Qual o departamento com maior número de pessoas?

SELECT d.deptName, COUNT(e.idEmployee) AS total_employees
FROM department d
JOIN employee e ON d.idDepartment = e.idDepartment
GROUP BY d.idDepartment
ORDER BY total_employees DESC
LIMIT 1;


-- Quais são os departamentos por cidade?

SELECT city, GROUP_CONCAT(deptName) AS departments
FROM department
GROUP BY city;

-- Relação de empregados por departamento

SELECT d.deptName, e.empName
FROM employee e
JOIN department d ON e.idDepartment = d.idDepartment
ORDER BY d.deptName;

-- resumo do projeto


-- Company DB - Índices e Consultas

## Objetivo
-- Otimizar consultas frequentes ao banco de dados da empresa usando índices estratégicos.

## Índices criados
-- 1. `idx_employee_department` → acelera consultas por `idDepartment` em `employee`.
-- . `idx_department_city` → acelera filtros por `city` na `department`.

## Consultas realizadas
-- Departamento com maior número de empregados.
-- Departamentos por cidade.
-- Relação de empregados por departamento.

## Justificativa
-- Criei índices **apenas nas colunas frequentemente usadas em JOINs e WHERE**, para melhorar o desempenho sem comprometer o custo de manutenção do índice.

-- PARTE 2

-- Procedure para manipulação de dados

DELIMITER //

CREATE PROCEDURE manage_employee(
    IN action_type INT,    -- 1: INSERT, 2: UPDATE, 3: DELETE
    IN emp_id INT,
    IN emp_name VARCHAR(100),
    IN emp_salary DECIMAL(10,2),
    IN dept_id INT
)
BEGIN
    IF action_type = 1 THEN
        -- Inserção
        INSERT INTO employee(empName, salary, idDepartment)
        VALUES (emp_name, emp_salary, dept_id);

    ELSEIF action_type = 2 THEN
        -- Atualização
        UPDATE employee
        SET empName = emp_name, salary = emp_salary, idDepartment = dept_id
        WHERE idEmployee = emp_id;

    ELSEIF action_type = 3 THEN
        -- Remoção
        DELETE FROM employee WHERE idEmployee = emp_id;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ação inválida!';
    END IF;
END //

DELIMITER ;


-- Exemplo de chamada

-- Inserir novo empregado
CALL manage_employee(1, NULL, 'Maria Silva', 4500.00, 1);

-- Atualizar empregado com id 3
CALL manage_employee(2, 3, 'João Souza', 5500.00, 2);

-- Deletar empregado com id 5
CALL manage_employee(3, 5, NULL, NULL, NULL);


-- Parte da Procedure

# Procedures de manipulação de dados

## Objetivo
-- Criar uma única procedure para inserção, atualização e remoção de empregados.

## Estrutura
-- `action_type`: define qual ação será executada.
-- `emp_id`, `emp_name`, `emp_salary`, `dept_id`: dados necessários.

## Vantagem
-- Evita repetição de código e centraliza a manipulação de dados.

## Como usar
-- `1` → INSERIR
-- '2` → ATUALIZAR
-- `3` → REMOVER




