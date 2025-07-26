import xlsxwriter
import random
from faker import Factory

factory = Factory.create('pt_PT')
degree_name = "Licenciatura em Engenharia Informática"

document_headers = [
    "Inscritos por UC",
    "",
    "Ciclo de Estudos: 1º Ciclo / Mestrado Integrado",
    "Ano Letivo: 2024/2025",
    "UOEI: Escola de Engenharia",
    "Curso: " + degree_name,
]

table_headers = [
    "Código do ano letivo",
    "Código da escola",	
    "UOEI",
    "Código do curso",
    "Curso",
    "Edição",	
    "Ano Curricular da UC",
    "Código da UC",
    "Unidade Curricular",	
    "Código da Opção",
    "Designação da Opção",
    "Nº Mecanográfico",	
    "Nome",	
    "Email",	
    "Género",
    "Regimes especiais de frequência"
]


def generate_student_xlsx(filename='students.xlsx'):
    workbook = xlsxwriter.Workbook(filename)
    worksheet = workbook.add_worksheet()

    row = 0
    for header in document_headers:
        worksheet.write(row, 0, header)
        row += 1

    for i, table_header in enumerate(table_headers):
        worksheet.write(row, i, table_header)
    
    row += 1

    for i in range(1, 31):
        student = generate_student()
        worksheet.write(row, 0, student['name'])
        row += 1

    workbook.close()

def generate_student():
    number = f"A{random.randint(100000, 999999)}"
    gender = random.choice(["M", "F"])
    return {
            "name": generate_name(gender), 
            "number": number,
            "email": number + "@alunos.uminho.pt",
            "gender": gender
        }

def generate_name(gender):
    last_names = [factory.last_name() for _ in range(random.randint(2, 5))]
    return (factory.first_name_male() if gender == "M" else factory.first_name_female()) + " " + " ".join(last_names)

if __name__ == "__main__":
    generate_student_xlsx('students.xlsx')
    print("Excel file 'students.xlsx' generated successfully.")