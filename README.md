<h1 name="content" align="center"><a href=""><img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/></a> MSSQL</h1>

<p align="center">
  <a href="#-lab1"><img alt="lab1" src="https://img.shields.io/badge/Lab1-blue"></a> 
  <a href="#-lab2"><img alt="lab2" src="https://img.shields.io/badge/Lab2-red"></a>
  <a href="#-lab3"><img alt="lab3" src="https://img.shields.io/badge/Lab3-green"></a>
  <a href="#-lab4"><img alt="lab4" src="https://img.shields.io/badge/Lab4-yellow"></a>
  <a href="#-lab5"><img alt="lab5" src="https://img.shields.io/badge/Lab5-gray"></a>
  <a href="#-lab6"><img alt="lab6" src="https://img.shields.io/badge/Lab6-orange"></a> 
  <a href="#-lab7"><img alt="lab7" src="https://img.shields.io/badge/Lab7-brown"></a>
  <a href="#-lab8"><img alt="lab8" src="https://img.shields.io/badge/Lab8-purple"></a>
  <a href="#-lab9"><img alt="lab9" src="https://img.shields.io/badge/Lab9-violet"></a> 
</p>

<img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Регистратура поликлиники – вызовы на дом (Вариант №3)
<p aligh="justify>
<h3>
  <a href="#client"></a>

  Информация о терапевтах: ФИО, телефон, номер кабинета, номер участка.
  Информация об адресах: номер участка, название улицы, список домов.
  Информация о вызовах: ФИО пациента, адрес, дата, время обращения, диагноз (выставляемый
после посещения пациента врачом).
  Реализовать:
- Вывод данных для участка о количестве пациентов, вызывавших врача за заданный период;
- Вычисление номера участка больного на основании адреса;
- Вывод данных для участка о количестве вызовов за заданный период;
- Вывод для терапевта списка пациентов, ожидающих посещения врача;
- Вывод по каждому диагнозу количества пациентов за заданный период.
</h3>
</p>
<img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Лабораторная работа №1


<p aligh="justify>
<h3>
  <a href="#client"></a>
  Разработать ER-модель данной предметной области: выделить сущности, их атрибуты,
связи между сущностями.
Для каждой сущности указать ее имя, атрибут (или набор атрибутов), являющийся
первичным ключом, список остальных атрибутов.
Для каждого атрибута указать его тип, ограничения, может ли он быть пустым, является ли
он первичным ключом.
Для каждой связи между сущностями указать:
- тип связи (1:1, 1:M, M:N)
- обязательность
ER-модель д.б. представлена в виде ER-диаграммы (картинка)
По имеющейся ER-модели создать реляционную модель данных и отобразить ее в виде
списка сущностей с их атрибутами и типами атрибутов, для атрибутов указать, явл. ли он
первичным или внешним ключом
</h3>
</p3>

ER-модель Поликлиники
![image](https://github.com/DJStArbuzz/PMI-3/blob/main/lab1/1.png)


Реляционная модель
![image](https://github.com/DJStArbuzz/PMI-3/blob/main/lab1/2.png)
# <img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Лабораторная работа №2

<p aligh="justify>
<h3>
  <a href="#client"></a>
В соответствии с реляционной моделью данных, разработанной в Лаб.№1, создать реляционную БД на учебном сервере БД :
- создать таблицы, определить первичные ключи и иные ограничения
- определить связи между таблицами
- создать диаграмму
- заполнить все таблицы адекватной информацией (не меньше 10 записей в таблицах, наличие примеров для связей типа 1:M )

</h3>
</p3>

![image](https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/main.png)
![image](https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/%D0%B4%D0%B8%D0%B0%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B0.png)
Пример заполненной таблицы "Пациенты":
![image](https://github.com/DJStArbuzz/PMI-3/blob/main/lab2/main2.png)
```
-- Таблица участков
CREATE TABLE District (
    id BIGINT PRIMARY KEY,
    district_number BIGINT NOT NULL UNIQUE,
    streets NVARCHAR NOT NULL
);

-- Таблица диагнозов
CREATE TABLE Diagnosis (
    id BIGINT PRIMARY KEY,
    name CHAR(100) NOT NULL UNIQUE,
    description CHAR
);

-- Таблица пациентов
CREATE TABLE Patient (
    id BIGINT PRIMARY KEY,
    full_name CHAR(100) NOT NULL,
    street CHAR(100) NOT NULL,
    house_number BIGINT NOT NULL,
    district_id BIGINT REFERENCES District(id) ON DELETE SET NULL
);

-- Таблица терапевтов
CREATE TABLE Therapist (
    id BIGINT PRIMARY KEY,
    full_name CHAR(100) NOT NULL,
    phone CHAR(12),
    office_number BIGINT NOT NULL,
    district_id BIGINT REFERENCES District(id) ON DELETE SET NULL,
 );

-- Таблица графиков работы
CREATE TABLE Therapist_schedule (
    id BIGINT PRIMARY KEY,
    therapist_id BIGINT REFERENCES Therapist(id) ON DELETE CASCADE,
    day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

ALTER TABLE Therapist ADD therapist_schedule_id BIGINT REFERENCES Therapist_schedule(id) ON DELETE SET NULL;

-- Таблица вызовы
CREATE TABLE Call (
    id BIGINT PRIMARY KEY,
    appeal_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    visit_status BIT NOT NULL DEFAULT 0,
    patient_id BIGINT REFERENCES Patient(id) ON DELETE CASCADE,
    therapist_id BIGINT REFERENCES Therapist(id) ON DELETE SET NULL
);

-- Таблица вызовы-диагноз
CREATE TABLE Call_diagnosis (
    diagnosis_id BIGINT REFERENCES Diagnosis(id) ON DELETE CASCADE,
    call_id BIGINT REFERENCES Call(id) ON DELETE CASCADE,
    doctor_comment CHAR,
    PRIMARY KEY (diagnosis_id, call_id)
);
```
![image](/sources/yargu.png)
