import xlsxwriter
import random
from faker import Factory
from datetime import datetime
import json

degree_data = json.load(open('data.json', 'r', encoding='utf-8'))

factory = Factory.create('pt_PT')

current_day = datetime.now().day
current_month = datetime.now().month
current_year = datetime.now().year

document_headers = [
    "Inscritos por UC",
    "",
    "Ciclo de Estudos: 1º Ciclo / Mestrado Integrado",
    "Ano Letivo: " + str(current_year) + '/' + str(current_year + 1),
    "UOEI: Escola de Engenharia",
    "Curso: " + degree_data["name"],
]

table_headers = [
    ("Código do ano letivo", 24),
    ("Código da escola", 18),
    ("UOEI", 20),
    ("Código do curso", 18),
    ("Curso", 40),
    ("Edição", 5.5),
    ("Ano Curricular da UC", 23),
    ("Código da UC", 16),
    ("Unidade Curricular", 50),
    ("Código da Opção", 20),
    ("Designação da Opção", 24),
    ("Nº Mecanográfico", 19),
    ("Nome", 58),
    ("Email", 28),
    ("Género", 9),
    ("Regimes especiais de frequência", 38)
]

special_statuses = ["TE", "AUM", "EINT", "TE2", "PD", "DLG", "DAE"]

def generate_xlsx(filename='students_by_courses.xlsx'):
    students = generate_students()

    workbook = xlsxwriter.Workbook(filename)
    worksheet = workbook.add_worksheet(f"Listagem_Inscritos_por_UC_{current_day:02d}_{current_month:02d}")

    row = 0

    header_format = workbook.add_format({'font_size': 10, 'font_name': 'Aptos Narrow', 'bg_color': '#ffffff'})

    for header in document_headers:
        worksheet.set_row(row, 20, header_format)
        worksheet.write(row, 0, header, header_format)
        row += 1

    table_header_format = workbook.add_format({'bold': True, 'font_size': 8, 'font_name': 'Verdana', 'bg_color': '#a05d62', 'font_color': '#ffffff', 'align': 'center', 'valign': 'vcenter'})

    for i, table_header in enumerate(table_headers):
        worksheet.set_column(i, i, table_header[1])
        worksheet.set_row(row, 20)
        worksheet.write(row, i, table_header[0], table_header_format)

    row += 1

    row_formats = [workbook.add_format({'font_size': 8, 'font_name': 'Verdana', 'bg_color': '#f5f5f5', 'font_color': '#000000'}),
                   workbook.add_format({'font_size': 8, 'font_name': 'Verdana', 'bg_color': '#ffffff', 'font_color': '#000000'})]

    for course in degree_data['courses']:
        course_year = course['year']

        for student in students[course_year - 1]:
            worksheet.set_row(row, 20)
            row_format = row_formats[row % 2]

            parent_course = {'code': '' ,'name': ''}
            has_sub_courses = 'courses' in course

            if has_sub_courses:
                parent_course = course
                course = random.choice(course['courses'])

            worksheet.write(row, 0, current_year, row_format)
            worksheet.write(row, 1, degree_data['school']['code'], row_format)
            worksheet.write(row, 2, degree_data['school']['name'], row_format)
            worksheet.write(row, 3, degree_data['code'], row_format)
            worksheet.write(row, 4, degree_data['name'], row_format)
            worksheet.write(row, 5, "", row_format)
            worksheet.write(row, 6, course_year, row_format)
            worksheet.write(row, 7, course['code'], row_format)
            worksheet.write(row, 8, course['name'], row_format)
            worksheet.write(row, 9, parent_course['code'], row_format)
            worksheet.write(row, 10, parent_course['name'], row_format)
            worksheet.write(row, 11, student['number'], row_format)
            worksheet.write(row, 12, student['name'], row_format)
            worksheet.write(row, 13, student['email'], row_format)
            worksheet.write(row, 14, student['gender'], row_format)
            worksheet.write(row, 15, student['special_status'], row_format)
            row += 1

            if has_sub_courses:
                course = parent_course

    workbook.close()

def generate_student():
    number = f"A{random.randint(100000, 139999)}"
    gender = random.choice(["M", "F"])
    return {
            "name": generate_name(gender), 
            "number": number,
            "email": number + "@alunos.uminho.pt",
            "gender": gender,
            "special_status": random.choice(special_statuses) if random.random() < 0.1 else ""
        }

def generate_students():
    first_year_students = [generate_student() for _ in range(220)]
    second_year_students = [generate_student() for _ in range(160)]
    third_year_students = [generate_student() for _ in range(130)]
    return [first_year_students, second_year_students, third_year_students]

def generate_name(gender):
    last_names = [factory.last_name() for _ in range(random.randint(2, 5))]
    return (factory.first_name_male() if gender == "M" else factory.first_name_female()) + " " + " ".join(last_names)

if __name__ == "__main__":
    generate_xlsx('students_by_courses.xlsx')
    print("Excel file 'students_by_courses.xlsx' generated successfully.")