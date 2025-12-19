USE lab_3_test2;
GO

PRINT '=== ТЕСТИРОВАНИЕ РОЛИ EMPLOYEE ===';

-- Проверка выполнения разрешенных процедур
PRINT 'Проверка выполнения процедур:';
BEGIN TRY
    EXEC GetTodayCallsTest2;
    PRINT '   ✓ EXEC GetTodayCallsTest2 - УСПЕХ (разрешено)';
END TRY
BEGIN CATCH
    PRINT '   ✗ EXEC GetTodayCallsTest2 - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка запрета на выполнение процедур
PRINT 'Проверка запрета на выполнение процедур:';
BEGIN TRY
    EXEC GetDistrictStreets @district_number = 1;
    PRINT '   ✗ EXEC GetDistrictStreets - НЕОЖИДАННО РАБОТАЕТ!';
END TRY
BEGIN CATCH
    PRINT '   ✓ EXEC GetDistrictStreets - ОЖИДАЕМАЯ ОШИБКА';
END CATCH

-- Проверка ограниченного SELECT
PRINT 'Проверка ограниченного SELECT:';
BEGIN TRY
    SELECT * FROM LimitedPatientView;
    PRINT '   ✓ SELECT LimitedPatientView - УСПЕХ';
END TRY
BEGIN CATCH
    PRINT '   ✗ SELECT LimitedPatientView - ОШИБКА: ' + ERROR_MESSAGE();
END CATCH

-- Проверка запрета прямого SELECT
PRINT 'Проверка запрета прямого SELECT:';
BEGIN TRY
    SELECT * FROM Call;
    PRINT '   ✗ SELECT Call - НЕОЖИДАННО РАБОТАЕТ!';
END TRY
BEGIN CATCH
    PRINT '   ✓ SELECT Call - ОЖИДАЕМАЯ ОШИБКА';
END CATCH

PRINT 'Проверка запрета прямого SELECT:';
BEGIN TRY
    SELECT * FROM Patient;
    PRINT '   ✓ SELECT Patient -  РАБОТАЕТ С МАСКАМИ!';
END TRY
BEGIN CATCH
    PRINT '   ✗ SELECT Patient - НЕОЖИДАЕМАЯ ОШИБКА';
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


PRINT 'Пациенты (должны видеть маскированные данные):';
EXEC dbo.GetPatientsData;

PRINT 'Терапевты (без расписания):';
EXEC dbo.GetTherapistsData @include_schedule = 1;

PRINT 'Вызовы за последний месяц:';
EXEC dbo.GetCallsData;

PRINT 'Ограниченная статистика:';
EXEC dbo.GetStatistics;

PRINT 'Конкретный пациент (маскированный):';
EXEC dbo.GetPatientsData @patient_id = 2;

PRINT 'Попытка прямого доступа к таблицам (должна быть ошибка):';
BEGIN TRY
    SELECT TOP 1 * FROM Patient;
    PRINT '   ✗ Неожиданно есть доступ!';
END TRY
BEGIN CATCH
    PRINT '   ✓ Ожидаемая ошибка доступа';
END CATCH




SELECT * FROM vw_MaskedTherapists;
SELECT * FROM vw_MaskedPatients;

EXEC dbo.GetPatientsData;
