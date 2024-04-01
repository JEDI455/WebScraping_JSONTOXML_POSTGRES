import random
from datetime import datetime, timedelta
import psycopg2

#С этим кодом я создаю генератор работников предприятия для того чтобы населить базу данных
class Employee:
    def __init__(self, name, surname, patronymic, gender, job, date_latest, salary, department):
        self.name = name
        self.surname = surname
        self.patronymic = patronymic
        self.gender = gender
        self.job = job
        self.date_latest = date_latest
        self.salary = salary
        self.department = department
    def display_info(self):
        """
        Этот метод нужен для проверки правильности работы фукнцией создания работников
        """
        print(f'Фамилия: {self.surname}')
        print(f'Имя: {self.name}')
        print(f'Отчество: {self.patronymic}')
        print(f'Пол: {self.gender}')
        print(f'Должность: {self.job}')
        print(f'Дата последнего назначения: {self.date_latest}')
        print(f'Заработная плата: {self.salary}')

#В интернете нашел топ 10 самых популярных имен в Казахстане добавил имя Давид чтобы выполнить условие задания
possible_names_m = ["Алихан", "Омар", "Амир", "Алдияр", "Давид", "Айсултан", "Алан", "Али", "Нурислам"]
#Для имитации настоящей базы я создал списка как для 
possible_names_f = ["Айлин", "Асылым", "Сафия", "Томирис", "Раяна", "Амина", "Раяна", "Светлана", "Айым", "Медина"]
#Создаю списки с правильными склонениями самых популярных фамилий, добавил фамилию Манукян чтобы выполнить условие задания
possible_surnames_f = ["Ахметова", "Омарова", "Ким", "Оспанова", "Иванова", "Алиева", "Сулейменова", "Искакова", "Манукян"]
# Списки с мужских фамилий с добавлением фамилии Манукян для выполнения условий
possible_surnames_m = ["Ахметов", "Омаров", "Ким", "Оспанов", "Иванов", "Алиев", "Сулейменов", "Искаков", "Манукян"]
#В задании указано ФИО что означает наличие отчества, соотвественно сделал список отчеств на оснований списков имен выше
possible_patronymic_m = ["Алиханович", "Омарович", "Амирович", "Алдиярович", "Давидович", "Айсултанович", "Аланович", "Алиевич", "Нурисламович"]
#Адаптировал список отчеств с женским склолением
possible_patronymic_f = ["Алихановна", "Омаровна", "Амировна", "Алдияровна", "Давидовна", "Айсултановна", "Алановна", "Алиевна", "Нурисламовна"]
#Создал список доступных вакансий
possible_job = ["Менеджер", "Дизайнер", "Програмист", "Бухгалтер", "Юрист", "HR", "Продажи", "Тестировщик"]
#Список нужен для  генерации работника, и чтобы алгоритм выбирал ФИО из корректного списка
possible_s = ['Мужской','Женский']
#Список департаментов так как это обязательная таблица для выполнения задания
department_list = ["Снабжение", "Разработка", "Логистика", "Продажи"]
#Предполагаемая дата создания компании
start_date = datetime(2014, 10, 10)
#Текущая дата 
end_date = datetime(2024, 3, 28)


def random_date(start_date, end_date):
    """
    Эта функция позволяет создавать случайную дату в промежутке между start_date и end_date перменных 
    """
    #Конвертируем start_date в timestamp формат
    start_timestamp = start_date.timestamp()
    #Конвертируем end_date в timestamp формат
    end_timestamp = end_date.timestamp()
    random_timestamp = random.uniform(start_timestamp,end_timestamp)
    random_datetime = datetime.fromtimestamp(random_timestamp)
    return random_datetime.date()
def generate_wokrer():
    """
    Эта функция создает сотрудника со всеми необходимыми данными: ФИО, дата последнего назначения, з/п, позиция. Дата назначения генерируется случайно
    благодаря функции random_date
    """
    #Случайный выбор пола сотрудника
    gender = random.choice(possible_s)
    if gender == "Мужской":
        name = random.choice(possible_names_m)
        surname = random.choice(possible_surnames_m)
        patronymic = random.choice(possible_patronymic_m)
    else:
        name = random.choice(possible_names_f)
        surname = random.choice(possible_surnames_f)
        patronymic = random.choice(possible_patronymic_f)
    age = random.randint(20,60)
    job = random.choice(possible_job)
    latest_date = random_date(start_date, end_date)
    salary = random.randint(250000,3000000)
    department = random.choice(department_list)
    return Employee(name, surname, patronymic, gender, job, latest_date, salary, department)


#Здесь я подключаюсь к базеданных которая называется employees 
con = psycopg2.connect(
    host='localhost',
    database = 'employees',
    user = 'postgres',
    password = '12345')

cursor = con.cursor()

def insert_employee(employee):
    """
    Данная функция берет код должности и департамента чтобы правильно распределить все ключевые данные сотрудника
    """
    # Здесь код запрашивает код должности сотрудника чтобы определить какой индекс поставить в таблицу employees
    cursor.execute("SELECT JobID FROM Job WHERE JobName = %s", (employee.job,))
    job_id = cursor.fetchone()[0]

    # Здесь код заправшивает ID департамента чтобы корректно распределить его в таблице employees
    cursor.execute("SELECT DepartmentID FROM Departments WHERE DepartmentName = %s", (employee.department,))
    department_id = cursor.fetchone()[0]

    # Здесь я вставляю все ключевые параметры сотрудника
    sql_employee = """INSERT INTO Employees (Name, Surname, Patronymic, Gender, JobID, Date_latest, DepartmentID)
                      VALUES (%s, %s, %s, %s, %s, %s, %s)"""
    cursor.execute(sql_employee, (employee.name, employee.surname, employee.patronymic, employee.gender,
                                   job_id, employee.date_latest, department_id))

    # Здесь я вставляю заработную плату сотрудника 
    sql_salary = """INSERT INTO Salaries (Employee_ID, Salary)
                    VALUES (currval('employees_employee_id_seq'), %s)"""
    cursor.execute(sql_salary, (employee.salary,))

    # Здесь я вставляю историю последнего повышения/трудостройства
    sql_history = """INSERT INTO Employment_History (Promotion_Date, Employee_ID)
                     VALUES (%s, currval('employees_employee_id_seq'))"""
    cursor.execute(sql_history, (employee.date_latest,))
    con.commit()

workers = [generate_wokrer() for _ in range(100)]
for worker in workers:
    insert_employee(worker)
    worker.display_info()

cursor.close()
con.close()