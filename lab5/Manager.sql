USE lab_3_test2;
GO

PRINT '=== ТЕСТИРОВАНИЕ РОЛИ MANAGER ===';

-- Проверка SELECT прав
PRINT 'Проверка SELECT:';
BEGIN TRY
    SELECT * FROM Patient;
    PRINT '   ✓ SELECT Patient - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ SELECT Patient - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка INSERT прав
PRINT 'Проверка INSERT:';
BEGIN TRY
    INSERT INTO Patient (full_name, street, house_number, district_id) 
    VALUES ('Тест менеджера', 'Ул. Менеджерская', 100, 1);
    PRINT '   ✓ INSERT Patient - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ INSERT Patient - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка UPDATE прав
PRINT 'Проверка UPDATE:';
BEGIN TRY
    UPDATE Patient SET full_name = 'Обновленный менеджером' 
    WHERE full_name = 'Тест менеджера';
    PRINT '   ✓ UPDATE Patient - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ UPDATE Patient - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка DELETE прав
PRINT 'Проверка DELETE:';
BEGIN TRY
    DELETE FROM Patient WHERE full_name = 'Обновленный менеджером';
    PRINT '   ✓ DELETE Patient - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ DELETE Patient - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка создания объектов
PRINT 'Проверка создания объектов:';
BEGIN TRY
    CREATE TABLE ManagerTestTable (id INT, data NVARCHAR(50));
    INSERT INTO ManagerTestTable VALUES (1, 'Тест');
    SELECT * FROM ManagerTestTable;
    DROP TABLE ManagerTestTable;
    PRINT '   ✓ CREATE/INSERT/SELECT/DROP TABLE - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ Создание объектов - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    EXEC GetTodayCallsTest2;
    PRINT '   ✓ EXEC GetTodayCallsTest2 - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ EXEC GetTodayCallsTest2 - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    EXEC GetDistrictStreets @district_number = 2;
    PRINT '   ✓ EXEC GetDistrictStreets - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ EXEC GetDistrictStreets - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

PRINT '=== ПРОВЕРКА СИСТЕМЫ МАСКИРОВАНИЯ ===';

-- Проверка маскированных столбцов
SELECT 
    t.name AS table_name,
    c.name AS column_name,
    c.is_masked,
    c.masking_function
FROM sys.masked_columns c
JOIN sys.tables t ON c.object_id = t.object_id;

-- Проверка прав UNMASK
SELECT 
    pr.name AS principal_name,
    pr.type_desc AS principal_type,
    pe.permission_name,
    pe.state_desc
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
WHERE pe.permission_name = 'UNMASK';


PRINT 'Пациенты:';
EXEC dbo.GetPatientsData;

PRINT 'Терапевты с расписанием:';
EXEC dbo.GetTherapistsData @include_schedule = 1;

PRINT 'Вызовы за последний месяц:';
EXEC dbo.GetCallsData;

PRINT 'Полная статистика:';
EXEC dbo.GetStatistics;

PRINT 'Конкретный пациент:';
EXEC dbo.GetPatientsData @patient_id = 2;

SELECT full_name, phone FROM Therapist;
EXEC dbo.GetPatientsData;
-- 2.1 Создание представлений с маскированием
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

-- 2.2 Создание функции для условного маскирования
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

-- 2.3 Создание процедур с условным маскированием
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
