-- Создание ролей
CREATE ROLE ManagerRole;
CREATE ROLE EmployeeRole;

-- ========== ПРАВА ДЛЯ MANAGER ==========
-- Полные права на все таблицы
GRANT SELECT, INSERT, UPDATE, DELETE ON District TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Diagnosis TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Patient TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Therapist TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Therapist_schedule TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Call TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Call_diagnosis TO ManagerRole;

-- ========== ПРАВА ДЛЯ EMPLOYEEROLE ==========

-- Полный запрет на прямые операции с таблицами
DENY SELECT, INSERT, UPDATE, DELETE ON District TO EmployeeRole;
DENY SELECT, INSERT, UPDATE, DELETE ON Diagnosis TO EmployeeRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Patient TO EmployeeRole;
DENY SELECT, INSERT, UPDATE, DELETE ON Therapist TO EmployeeRole;
DENY SELECT, INSERT, UPDATE, DELETE ON Therapist_schedule TO EmployeeRole;
DENY SELECT, INSERT, UPDATE, DELETE ON Call TO EmployeeRole;
DENY SELECT, INSERT, UPDATE, DELETE ON Call_diagnosis TO EmployeeRole;

-- ========== СОЗДАНИЕ ПРЕДСТАВЛЕНИЙ ДЛЯ СОТРУДНИКА ==========
CREATE OR ALTER VIEW vw_MaskedPatients AS
SELECT 
    id,
    -- Маскирование имени: первые 2 буквы + xxxx
    LEFT(full_name, 2) + 'xxxx' AS full_name,
    street,
    '***' AS house_number,  -- Полное маскирование
    district_id
FROM Patient;
GO

CREATE OR ALTER VIEW vw_MaskedTherapists AS
SELECT 
    id,
    LEFT(full_name, 2) + 'xxxx' AS full_name,
    -- Маскирование телефона: +7-900-xxxx-xx67
    LEFT(phone, 6) + 'xxxx' + RIGHT(phone, 4) AS phone,
    office_number,
    district_id
FROM Therapist;
GO

CREATE OR ALTER FUNCTION dbo.MaskData(@value NVARCHAR(255), @dataType NVARCHAR(20))
RETURNS NVARCHAR(255)
AS
BEGIN
    RETURN CASE 
        WHEN @dataType = 'name' THEN LEFT(@value, 2) + 'xxxx'
        WHEN @dataType = 'phone' THEN LEFT(@value, 6) + 'xxxx' + RIGHT(@value, 4)
        WHEN @dataType = 'description' THEN 'xxxx'
        ELSE 'xxxx'
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.GetPatientsDataWithMasking
AS
BEGIN
    IF IS_MEMBER('ManagerRole') = 1
        -- Менеджер: оригинальные данные
        SELECT * FROM Patient;
    ELSE
        -- Сотрудник: маскированные данные через представление
        SELECT * FROM vw_MaskedPatients;
END;
GO

CREATE OR ALTER PROCEDURE dbo.GetTherapistsDataWithMasking
AS
BEGIN
    IF IS_MEMBER('ManagerRole') = 1
        SELECT * FROM Therapist;
    ELSE
        SELECT * FROM vw_MaskedTherapists;
END;
GO


-- Маскирование по примеру partial(2,"xxxx",0)
ALTER TABLE Patient ALTER COLUMN full_name ADD MASKED WITH (FUNCTION = 'partial(2,"xxxx",0)');
ALTER TABLE Therapist ALTER COLUMN phone ADD MASKED WITH (FUNCTION = 'partial(2,"xxxx",2)');
ALTER TABLE Diagnosis ALTER COLUMN description ADD MASKED WITH (FUNCTION = 'partial(0,"xxxx",0)');


-- ========== ПРАВА ДОСТУПА К ПРЕДСТАВЛЕНИЯМ ==========

-- Сотрудник может только читать маскированные данные
GRANT SELECT ON vw_MaskedPatients TO EmployeeRole;
GRANT SELECT ON vw_MaskedTherapists TO EmployeeRole;
GRANT SELECT ON vw_MaskedDiagnosis TO EmployeeRole;
GRANT SELECT ON vw_Calls_ReadOnly TO EmployeeRole;


-- ========== СОЗДАНИЕ ЛОГИНОВ И ПОЛЬЗОВАТЕЛЕЙ ==========
CREATE LOGIN manager WITH PASSWORD = '1234567';
CREATE LOGIN employee WITH PASSWORD = '1234567';
GO

CREATE USER manager FOR LOGIN manager;
CREATE USER employee FOR LOGIN employee;
GO

ALTER ROLE ManagerRole ADD MEMBER manager;
ALTER ROLE EmployeeRole ADD MEMBER employee;
GO

-- ========== ПРОВЕРКА ПРАВ ==========
-- Проверка прав для ManagerRole
SELECT 
    OBJECT_NAME(major_id) AS object_name,
    permission_name,
    state_desc
FROM sys.database_permissions 
WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('ManagerRole')
AND major_id > 0;

-- Проверка прав для EmployeeRole
SELECT 
    OBJECT_NAME(major_id) AS object_name,
    permission_name,
    state_desc
FROM sys.database_permissions 
WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('EmployeeRole')
AND major_id > 0;