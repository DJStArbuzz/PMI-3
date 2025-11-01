<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Лабораторная работа №4 - Поликлиника</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        header {
            background: linear-gradient(90deg, #2c3e50, #4a6491);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
        }
        
        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .logo-icon {
            width: 40px;
            height: 40px;
            background-color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2c3e50;
            font-weight: bold;
            font-size: 18px;
        }
        
        h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .badges {
            margin: 20px 0;
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .badge {
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            color: white;
            font-weight: bold;
            transition: transform 0.3s;
        }
        
        .badge:hover {
            transform: translateY(-3px);
        }
        
        .lab-section {
            padding: 30px;
            border-bottom: 1px solid #eee;
        }
        
        .lab-section:last-child {
            border-bottom: none;
        }
        
        h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #4a6491;
        }
        
        h3 {
            color: #4a6491;
            margin: 15px 0;
        }
        
        .task-list {
            list-style-type: none;
            padding-left: 20px;
        }
        
        .task-list li {
            margin: 10px 0;
            padding-left: 25px;
            position: relative;
        }
        
        .task-list li:before {
            content: "▸";
            position: absolute;
            left: 0;
            color: #4a6491;
            font-weight: bold;
        }
        
        .code-block {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 20px;
            border-radius: 8px;
            margin: 15px 0;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
        }
        
        .image-container {
            text-align: center;
            margin: 20px 0;
        }
        
        .image-container img {
            max-width: 100%;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .caption {
            font-style: italic;
            color: #666;
            margin-top: 10px;
        }
        
        .requirements {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #4a6491;
            margin: 20px 0;
        }
        
        .highlight {
            background: #fff3cd;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: bold;
        }
        
        footer {
            text-align: center;
            padding: 20px;
            background: #2c3e50;
            color: white;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">
                <div class="logo-icon">⚕️</div>
                <h1>Лабораторная работа №4 - Поликлиника</h1>
            </div>
            <p class="subtitle">Система управления вызовами врачей на дом</p>
            
            <div class="badges">
                <a href="#lab1" class="badge" style="background: #007bff;">Lab1</a>
                <a href="#lab2" class="badge" style="background: #dc3545;">Lab2</a>
                <a href="#lab3" class="badge" style="background: #28a745;">Lab3</a>
                <a href="#lab4" class="badge" style="background: #ffc107; color: #333;">Lab4</a>
                <a href="#lab5" class="badge" style="background: #6c757d;">Lab5</a>
                <a href="#lab6" class="badge" style="background: #fd7e14;">Lab6</a>
                <a href="#lab7" class="badge" style="background: #6f42c1;">Lab7</a>
                <a href="#lab8" class="badge" style="background: #e83e8c;">Lab8</a>
                <a href="#lab9" class="badge" style="background: #20c997;">Lab9</a>
            </div>
        </header>

        <div class="lab-section">
            <h2>🎯 Цель работы</h2>
            <p>Разработка системы управления вызовами врачей на дом в поликлинике с использованием хранимых процедур, пользовательских функций и триггеров в СУБД MSSQL.</p>
        </div>

        <div class="lab-section" id="lab4">
            <h2>📋 Задание лабораторной работы №4</h2>
            
            <div class="requirements">
                <h3>🔧 Хранимые процедуры</h3>
                <p><strong>Разработать 4 различных хранимых процедуры:</strong></p>
                <ul class="task-list">
                    <li><strong>a)</strong> Процедура без параметров, формирующая список вызовов по каждому врачу на текущий день</li>
                    <li><strong>b)</strong> Процедура, на входе получающая номер участка и формирующая список улиц, находящихся на этом участке</li>
                    <li><strong>c)</strong> Процедура, на входе получающая номер участка, как выходной параметр выдает ФИО врача, обслуживающего данный участок</li>
                    <li><strong>d)</strong> Процедура, находящая один из участков с максимальным количеством домов и возвращающая ФИО врача, обслуживающего данный участок (с использованием вызова предыдущей процедуры)</li>
                </ul>

                <h3>📊 Пользовательские функции</h3>
                <p><strong>Разработать 3 пользовательских функции:</strong></p>
                <ul class="task-list">
                    <li><strong>a)</strong> Скалярная функция, возвращающая по адресу (улица, дом) номер участка</li>
                    <li><strong>b)</strong> Inline-функция, возвращающая все вызовы, поступившие от заданного пациента за текущий год</li>
                    <li><strong>c)</strong> Multi-statement-функция, возвращающая для заданного терапевта список пациентов, ожидающих его посещения в формате: ФИО пациента, адрес, примерное время посещения (из расчета, что на каждое посещение врач тратит 30 мин.)</li>
                </ul>

                <h3>⚡ Триггеры</h3>
                <p><strong>Создать 3 триггера:</strong></p>
                <ul class="task-list">
                    <li><strong>a)</strong> Триггер любого типа на добавление нового врача – если номер участка совпадает с номером какого-то другого врача, то вывод предупреждения и запись не добавляется</li>
                    <li><strong>b)</strong> Последующий триггер на изменение диагноза посещения – если диагноз уже был выставлен, то его менять нельзя</li>
                    <li><strong>c)</strong> Замещающий триггер на операцию отмены вызова – если врач еще не посетил этого пациента, то вызов можно отменить, в противном случае строка с этим вызовом не удаляется</li>
                </ul>
            </div>
        </div>

        <div class="lab-section">
            <h2>📝 Примеры выполнения</h2>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab4/1.png" alt="Пример выполнения задания 1">
                <p class="caption">Пример выполнения задания 1</p>
            </div>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab4/2.png" alt="Пример выполнения задания 2">
                <p class="caption">Пример выполнения задания 2</p>
            </div>
        </div>

        <div class="lab-section" id="lab1">
            <h2>📊 Лабораторная работа №1 - ER-модель</h2>
            <p><strong>Цель:</strong> Разработать ER-модель предметной области поликлиники</p>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab1/1.png" alt="ER-модель Поликлиники">
                <p class="caption">ER-модель Поликлиники</p>
            </div>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab1/2.png" alt="Реляционная модель">
                <p class="caption">Реляционная модель</p>
            </div>
        </div>

        <div class="lab-section" id="lab2">
            <h2>🗃️ Лабораторная работа №2 - Создание БД</h2>
            <p><strong>Цель:</strong> Создание реляционной базы данных на учебном сервере</p>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/main.png" alt="Основное окно БД">
                <p class="caption">Основное окно базы данных</p>
            </div>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/diagram.png" alt="Диаграмма БД">
                <p class="caption">Диаграмма базы данных</p>
            </div>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/main2.png" alt="Таблица Пациенты">
                <p class="caption">Пример заполненной таблицы "Пациенты"</p>
            </div>
        </div>

        <div class="lab-section" id="lab3">
            <h2>🔍 Лабораторная работа №3 - SQL запросы</h2>
            <p><strong>Цель:</strong> Изучение конструкций языка SQL для манипулирования данными</p>
            
            <div class="image-container">
                <img src="https://github.com/DJStArbuzz/PMI-3/blob/main/lab3/ex.png" alt="Пример запроса">
                <p class="caption">Пример запроса: Определение диагнозов с превышением порога заболеваемости</p>
            </div>
        </div>

        <footer>
            <p>© 2024 Лабораторная работа №4 - Система управления поликлиникой</p>
            <p>Выполнено в рамках курса "Базы данных"</p>
        </footer>
    </div>
</body>
</html>
