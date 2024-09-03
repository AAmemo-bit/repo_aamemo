import psycopg2
from psycopg2 import sql
import os

# Configuración de la base de datos
DB_PARAMS = {
    'dbname': 'usac',
    'user': 'postgres',
    'password': 'A@merida123',
    'host': 'localhost',
    'port': '5432'
}

Cprimera = 15.00
Cotras = 20.00

def connect_db():
    return psycopg2.connect(**DB_PARAMS)

def clear_file(file_name):
    with open(file_name, 'w') as file:
        pass

def delete_all_records():
    conn = connect_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM registro_parqueo;")
            conn.commit()
    finally:
        conn.close()

def insert_record(nombre, nit, vehiculo, entrada, salida, tiempo_total_horas, monto_total):
    conn = connect_db()
    try:
        with conn.cursor() as cur:
            query = sql.SQL("INSERT INTO registro_parqueo (nombre_del_cliente, nit, placa, hora_entrada, hora_salida, tiempo_total, monto_total) VALUES (%s, %s, %s, %s, %s, %s, %s)")
            values = (nombre, nit, vehiculo, entrada, salida, tiempo_total_horas, monto_total)
            cur.execute(query, values)
            conn.commit()
    finally:
        conn.close()

def print_invoice(nombre, nit, vehiculo, entrada, salida, tiempo_total_horas, monto_total):
    print("----Factura----")
    print(f"Nombre: {nombre}")
    print(f"NIT: {nit}")
    print(f"Placa: {vehiculo}")
    print(f"Hora de Entrada: {entrada}")
    print(f"Hora de Salida: {salida}")
    print(f"Tiempo cobrado: {tiempo_total_horas} horas")
    print(f"Monto Total a Pagar: Q{monto_total:.2f}")
    print("---------------")

def main():
    nombre = ''
    nit = ''
    vehiculo = ''
    entrada = ''
    salida = ''
    tiempo_total_horas = 0
    monto_total = 0

    while True:
        print("1. Ingresar datos para factura")
        print("2. Cancelar el parqueo")
        print("3. Imprimir Factura")
        print("4. Borrar datos")
        print("5. Salir")
        opcion = int(input("Ingrese su elección: "))

        if opcion == 1:
            nombre = input('Ingrese su nombre: ')
            nit = input('Ingrese su nit: ')
            vehiculo = input('Ingrese la placa de su vehículo: ')
            print('Datos de usuario ingresados correctamente.')

        elif opcion == 2:
            if not all([nombre, nit, vehiculo]):
                print('Primero ingrese datos para la facturación')
            else:
                try:
                    entrada = input('Hora de entrada (HH:MM): ')
                    salida = input('Hora de salida (HH:MM): ')
                    
                    entrada_hora, entrada_minuto = map(int, entrada.split(':'))
                    salida_hora, salida_minuto = map(int, salida.split(':'))
                    
                    if (entrada_hora < 0 or entrada_hora > 23 or entrada_minuto < 0 or entrada_minuto > 59 or
                        salida_hora < 0 or salida_hora > 23 or salida_minuto < 0 or salida_minuto > 59 or
                        (salida_hora < entrada_hora) or (salida_hora == entrada_hora and salida_minuto < entrada_minuto)):
                        raise ValueError('Hora de entrada o salida no válida.')
                    
                    tiempo_total_minutos = (salida_hora * 60 + salida_minuto) - (entrada_hora * 60 + entrada_minuto)
                    tiempo_total_horas = (tiempo_total_minutos + 59) // 60  # Redondear hacia arriba

                    monto_total = Cprimera if tiempo_total_horas <= 1 else Cprimera + (tiempo_total_horas - 1) * Cotras
                    
                    insert_record(nombre, nit, vehiculo, entrada, salida, tiempo_total_horas, monto_total)

                    with open('salida.txt', 'a') as file:
                        file.write(f'Nombre: {nombre}\n')
                        file.write(f'NIT: {nit}\n')
                        file.write(f'Placa: {vehiculo}\n')
                        file.write(f'Hora de Entrada: {entrada}\n')
                        file.write(f'Hora de Salida: {salida}\n')
                        file.write(f'Tiempo Total: {tiempo_total_horas} horas\n')
                        file.write(f'Monto Total a Pagar: Q{monto_total:.2f}\n\n')

                    print(f'Monto Total a Pagar: Q{monto_total:.2f}')

                except Exception as e:
                    print(f'Error en la compra. {e}')

        elif opcion == 3:
            if not all([nombre, nit, vehiculo]):
                print('No se han ingresado datos de cliente para imprimir la factura.')
            else:
                print_invoice(nombre, nit, vehiculo, entrada, salida, tiempo_total_horas, monto_total)

        elif opcion == 4:
            try:
                delete_all_records()
                clear_file('salida.txt')
                print('Todos los datos han sido borrados.')
            except Exception as e:
                print(f'Error al borrar los datos. {e}')

        elif opcion == 5:
            print('Gracias, vuelva pronto.')
            break

        else:
            print('Opción no válida. Intente de nuevo.')

if __name__ == '__main__':
    main()
