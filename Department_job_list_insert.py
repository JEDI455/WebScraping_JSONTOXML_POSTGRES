import psycopg2


department_list = ["Снабжение", "Разработка", "Логистика", "Продажи"]
possible_job = ["Менеджер", "Дизайнер", "Програмист", "Бухгалтер", "Юрист", "HR", "Продажи", "Тестировщик"]

con = psycopg2.connect(
    host='localhost',
    database = 'employees',
    user = 'postgres',
    password = '12345')

cursor = con.cursor()
def insert_departments(department_list):
    for department_name in department_list:
        sql = """INSERT INTO Departments (DepartmentName) VALUES (%s)"""
        cursor.execute(sql, (department_name,))
    con.commit()
def insert_jobs(possible_job):
    for jobs in possible_job:
        sql = """INSERT INTO Job (JobName) VALUES (%s)"""
        cursor.execute(sql, (jobs,))
        con.commit()
insert_departments(department_list)
insert_jobs(possible_job)
cursor.close()
con.close()