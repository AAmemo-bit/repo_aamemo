import psycopg2
import os
import re

# Conexión a la base de datos
conn = psycopg2.connect(
    dbname='usac',
    user='postgres',
    password='A@merida',
    host='localhost',
    port='5432'
)
cursor = conn.cursor()

# Nombre del archivo de texto
archivo_texto = 'resultados_verificaciones.txt'

# Verificar si el archivo de texto existe, si no, crearlo
if not os.path.exists(archivo_texto):
    with open(archivo_texto, 'w') as archivo:
        archivo.write('')
    print('El archivo de texto ha sido creado.')
else:
    print('El archivo de texto ya existe.')

# Función para validar que no haya caracteres especiales
def contiene_caracteres_especiales(cadena):
    return bool(re.search(r'[^a-zA-Z0-9 ]', cadena))

# Función para pedir una opción numérica
def pedir_opcion_numerica(mensaje):
    while True:
        opcion = input(mensaje).strip()
        if opcion.isdigit():
            return opcion
        else:
            print('Por favor ingrese solo números válidos.')

# Menú inicial para ingresar usuario
while True:
    print('--- Menú Inicial ---')
    print('1. Ingresar Usuario')
    print('2. Salir')
    opcion_inicial = pedir_opcion_numerica('Ingrese su elección: ')

    if opcion_inicial == '2':
        print('Saliendo del programa...')
        break
    elif opcion_inicial == '1':
        respuesta = input('¿Ya tienes un usuario registrado? (Y/N): ').strip().upper()

        if respuesta == 'Y':
            nombre = input('Ingrese su nombre: ').strip()
            carne = input('Ingrese su carné (9 dígitos): ').strip()

            if contiene_caracteres_especiales(nombre):
                print('El nombre no debe contener caracteres especiales.')
                continue

            if not carne.isdigit() or len(carne) != 9:
                print('El carné debe contener exactamente 9 dígitos numéricos.')
                continue

            cursor.execute("SELECT id FROM usuario WHERE nombre = %s AND carne = %s;", (nombre, carne))
            result = cursor.fetchone()

            if not result:
                print('Usuario no encontrado. Por favor, registre primero los datos del usuario.')
                continue
            else:
                print('¡Bienvenido de nuevo!')

                while True:
                    print('--- Menú de Usuario ---')
                    print('1. Ingresar datos numéricos')
                    print('2. Ingresar palabra para verificar si es palíndromo')
                    print('3. Ver historial de datos')
                    print('4. Borrar datos')
                    print('5. Salir')
                    opcion_usuario = pedir_opcion_numerica('Ingrese su elección: ')

                    if opcion_usuario == '1':
                        numero_str = input('Ingrese el dato numérico a verificar: ').strip()

                        if not numero_str.isdigit():
                            print('Por favor ingrese solo números.')
                        else:
                            numero = int(numero_str)

                            # Verificar si es primo
                            es_primo = numero > 1 and all(numero % i != 0 for i in range(2, int(numero ** 0.5) + 1))
                            if es_primo:
                                print('El número es primo.')
                            else:
                                print('El número no es primo.')

                            # Verificar si es perfecto
                            suma_divisores = sum(i for i in range(1, numero) if numero % i == 0)
                            es_perfecto = suma_divisores == numero
                            if es_perfecto:
                                print('El número es perfecto.')
                            else:
                                print('El número no es perfecto.')

                            # Insertar los resultados en la base de datos
                            cursor.execute('''INSERT INTO verificaciones (id_usuario, dato, es_primo, es_perfecto) 
                                            VALUES (%s, %s, %s, %s);''', 
                                           (result[0], numero, es_primo, es_perfecto))
                            conn.commit()
                            print('Los resultados han sido guardados en la base de datos.')

                            # Guardar en el archivo de texto
                            with open(archivo_texto, 'a') as archivo:
                                archivo.write(f'Usuario: {nombre} (Carné: {carne})\n')
                                archivo.write(f'Número: {numero}\n')
                                archivo.write(f'Es primo: {"Sí" if es_primo else "No"}\n')
                                archivo.write(f'Es perfecto: {"Sí" if es_perfecto else "No"}\n')
                                archivo.write('\n')

                            print('Datos guardados correctamente en el archivo de texto.')

                    elif opcion_usuario == '2':
                        palabra = input('Ingrese una palabra para verificar si es palíndromo: ').strip()

                        if contiene_caracteres_especiales(palabra) or not palabra.isalpha():
                            print('Por favor ingrese solo palabras sin caracteres especiales o números.')
                        else:
                            es_palindromo = palabra.lower() == palabra.lower()[::-1]
                            if es_palindromo:
                                print('La palabra es un palíndromo.')
                            else:
                                print('La palabra no es un palíndromo.')

                            # Guardar los resultados en la base de datos (opcional según los requisitos)
                            cursor.execute('''INSERT INTO verificaciones (id_usuario, dato, es_palindromo) 
                                            VALUES (%s, %s, %s);''', 
                                           (result[0], palabra, es_palindromo))
                            conn.commit()
                            print('El resultado de la palabra ha sido guardado en la base de datos.')

                            # Guardar en el archivo de texto
                            with open(archivo_texto, 'a') as archivo:
                                archivo.write(f'Usuario: {nombre} (Carné: {carne})\n')
                                archivo.write(f'Palabra: {palabra}\n')
                                archivo.write(f'Es palíndromo: {"Sí" if es_palindromo else "No"}\n')
                                archivo.write('\n')

                            print('Datos guardados correctamente en el archivo de texto.')

                    elif opcion_usuario == '3':
                        # Mostrar historial de datos desde la tabla 'verificaciones'
                        cursor.execute('SELECT id_usuario, dato, es_primo, es_perfecto, es_palindromo FROM verificaciones;')
                        result = cursor.fetchall()

                        if not result:
                            print('No hay datos registrados.')
                        else:
                            print('----- Historial de verificaciones -----')
                            print('ID Usuario\tNúmero/Palabra\tPrimo\tPerfecto\tPalíndromo')

                            # Iterar sobre los resultados y mostrarlos
                            for row in result:
                                id_usuario, dato, es_primo, es_perfecto, es_palindromo = row
                                print(f'{id_usuario}\t\t{dato}\t{es_primo}\t{es_perfecto}\t\t{es_palindromo}')

                    elif opcion_usuario == '4':
                        try:
                            # Borrar los registros de la tabla 'verificaciones'
                            cursor.execute('DELETE FROM verificaciones;')
                            conn.commit()
                            print('Todos los datos de las tablas de verificaciones han sido borrados.')

                            # Borrar los datos del archivo de texto 'resultados_verificaciones.txt'
                            if os.path.exists(archivo_texto):
                                # Si el archivo existe, vaciarlo
                                with open(archivo_texto, 'w') as archivo:
                                    archivo.write('')
                                print('Los datos del archivo de texto "resultados_verificaciones.txt" han sido borrados.')
                            else:
                                print('El archivo "resultados_verificaciones.txt" no existe.')

                        except Exception as e:
                            print(f'Error al borrar los datos: {e}')

                    elif opcion_usuario == '5':
                        print('Saliendo al menú inicial...')
                        break

                    else:
                        print('Opción no válida. Por favor, elija una opción entre 1 y 5.')

        elif respuesta == 'N':
            # Registrar nuevo usuario
            nombre = input('Ingrese su nombre: ').strip()
            carne = input('Ingrese su carné (9 dígitos): ').strip()

            if contiene_caracteres_especiales(nombre):
                print('El nombre no debe contener caracteres especiales.')
                continue

            if not carne.isdigit() or len(carne) != 9:
                print('El carné debe contener exactamente 9 dígitos numéricos.')
                continue

            cursor.execute("INSERT INTO usuario (nombre, carne) VALUES (%s, %s);", (nombre, carne))
            conn.commit()
            print('Usuario registrado correctamente. Ahora puedes iniciar sesión.')
        else:
            print('Respuesta no válida. Debes ingresar "Y" o "N".')

# Cerrar la conexión a la base de datos
cursor.close()
conn.close()
