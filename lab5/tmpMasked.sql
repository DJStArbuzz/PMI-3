
-- Функция для определения роли текущего пользователя
CREATE FUNCTION dbo.GetCurrentUserRole()
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @role NVARCHAR(50);
    
    IF IS_MEMBER('ManagerRole') = 1
        SET @role = 'Manager'
    ELSE IF IS_MEMBER('EmployeeRole') = 1
        SET @role = 'Employee'
    ELSE
        SET @role = 'Unknown'
        
    RETURN @role;
END;
GO


-- Функция условного маскирования данных на основе роли
CREATE FUNCTION dbo.ConditionalMask(@data NVARCHAR(255), @data_type NVARCHAR(20))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @result NVARCHAR(255);
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    IF @user_role = 'Manager'
        SET @result = @data;  -- Менеджер видит оригинальные данные
    ELSE
    BEGIN
        -- Сотрудник видит маскированные данные
        IF @data_type = 'phone'
            SET @result = SUBSTRING(@data, 1, 4) + '-XXX-XXXX'
        ELSE IF @data_type = 'name'
        BEGIN
            DECLARE @space_pos INT = CHARINDEX(' ', @data);
            IF @space_pos > 0
                SET @result = LEFT(@data, 1) + REPLICATE('*', 5) + ' ' + 
                             SUBSTRING(@data, @space_pos + 1, 1) + REPLICATE('*', 5)
            ELSE
                SET @result = LEFT(@data, 1) + REPLICATE('*', 8)
        END
        ELSE IF @data_type = 'house_number'
            SET @result = '###'
        ELSE IF @data_type = 'description'
            SET @result = 'Данные скрыты'
        ELSE
            SET @result = REPLICATE('*', 8)
    END
    
    RETURN @result;
END;
GO

-- Процедура для получения данных пациентов с условным маскированием
CREATE PROCEDURE dbo.GetPatientsData
    @patient_id INT = NULL
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    IF @patient_id IS NULL
    BEGIN
        SELECT 
            p.id,
            dbo.ConditionalMask(p.full_name, 'name') AS full_name,
            p.street,
            dbo.ConditionalMask(CAST(p.house_number AS NVARCHAR(10)), 'house_number') AS house_number,
            p.district_id,
            d.district_number,
            CASE 
                WHEN @user_role = 'Manager' THEN 'Полный доступ'
                ELSE 'Ограниченный доступ'
            END AS access_level
        FROM Patient p
        JOIN District d ON p.district_id = d.id
        ORDER BY p.id;
    END
    ELSE
    BEGIN
        SELECT 
            p.id,
            dbo.ConditionalMask(p.full_name, 'name') AS full_name,
            p.street,
            dbo.ConditionalMask(CAST(p.house_number AS NVARCHAR(10)), 'house_number') AS house_number,
            p.district_id,
            d.district_number,
            CASE 
                WHEN @user_role = 'Manager' THEN 'Полный доступ'
                ELSE 'Ограниченный доступ'
            END AS access_level
        FROM Patient p
        JOIN District d ON p.district_id = d.id
        WHERE p.id = @patient_id;
    END
END;
GO

-- Процедура для получения данных терапевтов с маскированием
CREATE PROCEDURE dbo.GetTherapistsData
    @include_schedule BIT = 0
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    SELECT 
        t.id,
        dbo.ConditionalMask(t.full_name, 'name') AS full_name,
        dbo.ConditionalMask(t.phone, 'phone') AS phone,
        t.office_number,
        t.district_id,
        d.district_number,
        CASE 
            WHEN @user_role = 'Manager' THEN 'Все данные'
            ELSE 'Только основная информация'
        END AS info_level
    FROM Therapist t
    JOIN District d ON t.district_id = d.id;
    
    -- Только менеджеры видят расписание
    IF @include_schedule = 1 AND @user_role = 'Manager'
    BEGIN
        SELECT 
            ts.therapist_id,
            ts.day_of_week,
            ts.start_time,
            ts.end_time,
            t.full_name AS therapist_name
        FROM Therapist_schedule ts
        JOIN Therapist t ON ts.therapist_id = t.id
        ORDER BY ts.therapist_id, ts.day_of_week;
    END
    ELSE IF @include_schedule = 1 AND @user_role = 'Employee'
    BEGIN
        SELECT 'Расписание доступно только менеджерам' AS message;
    END
END;
GO

-- Процедура для работы с вызовами
CREATE PROCEDURE dbo.GetCallsData
    @date_from DATE = NULL,
    @date_to DATE = NULL
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    IF @date_from IS NULL
        SET @date_from = DATEADD(DAY, -30, GETDATE());
    IF @date_to IS NULL
        SET @date_to = GETDATE();
    
    SELECT 
        c.id,
        c.appeal_date,
        c.start_time,
        c.end_time,
        c.visit_status,
        -- Условное маскирование имен в зависимости от роли
        CASE 
            WHEN @user_role = 'Manager' THEN p.full_name
            ELSE dbo.ConditionalMask(p.full_name, 'name')
        END AS patient_name,
        CASE 
            WHEN @user_role = 'Manager' THEN t.full_name
            ELSE dbo.ConditionalMask(t.full_name, 'name')
        END AS therapist_name,
        dbo.ConditionalMask(t.phone, 'phone') AS therapist_phone,
        CASE 
            WHEN @user_role = 'Manager' THEN 'Все детали'
            ELSE 'Основная информация'
        END AS detail_level
    FROM Call c
    JOIN Patient p ON c.patient_id = p.id
    JOIN Therapist t ON c.therapist_id = t.id
    WHERE c.appeal_date BETWEEN @date_from AND @date_to
    ORDER BY c.appeal_date DESC, c.start_time;
END;
GO

-- Процедура для получения диагнозов с маскированием
CREATE PROCEDURE dbo.GetDiagnosesData
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    SELECT 
        id,
        name,
        CASE 
            WHEN @user_role = 'Manager' THEN description
            ELSE dbo.ConditionalMask(description, 'description')
        END AS description,
        CASE 
            WHEN @user_role = 'Manager' THEN 'Полное описание'
            ELSE 'Скрытое описание'
        END AS description_status
    FROM Diagnosis
    ORDER BY name;
END;
GO

-- Процедура для статистики с разным уровнем детализации
CREATE PROCEDURE dbo.GetStatistics
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    -- Базовая статистика (видят все)
    SELECT 
        'Общее количество пациентов' AS metric,
        COUNT(*) AS value
    FROM Patient
    
    UNION ALL
    
    SELECT 
        'Общее количество вызовов',
        COUNT(*) 
    FROM Call
    
    UNION ALL
    
    SELECT 
        'Количество завершенных вызовов',
        COUNT(*) 
    FROM Call 
    WHERE visit_status = 1
    
    UNION ALL
    
    SELECT 
        'Количество активных терапевтов',
        COUNT(*) 
    FROM Therapist;
    
    -- Расширенная статистика (только для менеджеров)
    IF @user_role = 'Manager'
    BEGIN
        SELECT '--- ДЕТАЛЬНАЯ СТАТИСТИКА (только для менеджеров) ---' AS message;
        
        SELECT 
            d.name AS diagnosis_name,
            COUNT(cd.diagnosis_id) AS usage_count
        FROM Call_diagnosis cd
        JOIN Diagnosis d ON cd.diagnosis_id = d.id
        GROUP BY d.name
        ORDER BY usage_count DESC;
        
        SELECT 
            t.full_name AS therapist_name,
            COUNT(c.id) AS call_count
        FROM Call c
        JOIN Therapist t ON c.therapist_id = t.id
        GROUP BY t.full_name
        ORDER BY call_count DESC;
        
        SELECT 
            d.district_number,
            COUNT(p.id) AS patient_count
        FROM Patient p
        JOIN District d ON p.district_id = d.id
        GROUP BY d.district_number
        ORDER BY d.district_number;
    END
    ELSE
    BEGIN
        SELECT 'Детальная статистика доступна только менеджерам' AS message;
    END
END;
GO

-- Процедура для проверки системы маскирования
CREATE PROCEDURE dbo.CheckMaskingSystem
AS
BEGIN
    DECLARE @user_role NVARCHAR(50) = dbo.GetCurrentUserRole();
    
    PRINT '=== ДИАГНОСТИКА СИСТЕМЫ МАСКИРОВАНИЯ ===';
    PRINT 'Текущий пользователь: ' + USER_NAME();
    PRINT 'Роль: ' + @user_role;
    PRINT ' ';
    
    -- Тест маскирования разных типов данных
    SELECT 
        'Телефон' AS data_type,
        '+7-900-123-45-67' AS original_value,
        dbo.ConditionalMask('+7-900-123-45-67', 'phone') AS masked_value
    UNION ALL
    SELECT 
        'Имя пациента',
        'Иванов Иван Иванович',
        dbo.ConditionalMask('Иванов Иван Иванович', 'name')
    UNION ALL
    SELECT 
        'Номер дома', 
        '123',
        dbo.ConditionalMask('123', 'house_number')
    UNION ALL
    SELECT 
        'Описание диагноза',
        'Подробное описание диагноза',
        dbo.ConditionalMask('Подробное описание диагноза', 'description');
        
    PRINT ' ';
    PRINT 'Доступные процедуры:';
    SELECT 
        name AS procedure_name,
        create_date
    FROM sys.procedures 
    WHERE name LIKE 'Get%Data' OR name LIKE 'Get%Statistics'
    ORDER BY name;
END;
GO