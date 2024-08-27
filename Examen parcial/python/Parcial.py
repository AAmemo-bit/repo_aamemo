import psycopg2

# Conectar a la base de datos
conn = psycopg2.connect(
    dbname='usac',
    user='postgres',
    password='A@merida123',
    host='localhost',
    port='5432'
)
cursor = conn.cursor()

# Precios del combustible
Cregular = 32.98
Cpremium = 34.68
Cdiesel = 30.49

# Variables para almacenar nombre y placa
nombre = ''
vehiculo = ''

def ingresar_datos_usuario():
    global nombre, vehiculo
    nombre = input('Ingrese su nombre: ')
    vehiculo = input('Ingrese la placa de su vehículo: ')
    print('Datos de usuario ingresados correctamente.')

def realizar_compra():
    global nombre, vehiculo
    if not nombre or not vehiculo:
        print('Debe ingresar primero los datos del usuario en la opción 1.')
        return

    print('Tipo de combustible:')
    print('1. Regular')
    print('2. Premium')
    print('3. Diesel')

    tipo = int(input('Indique el combustible que desea: '))
    if tipo == 1:
        precio = Cregular
        tipoCombustible = 'Regular'
    elif tipo == 2:
        precio = Cpremium
        tipoCombustible = 'Premium'
    elif tipo == 3:
        precio = Cdiesel
        tipoCombustible = 'Diesel'
    else:
        print('Opción no válida, intente de nuevo.')
        return

    print(f'Precio por litro de {tipoCombustible}: Q{precio:.2f}')
    cantidad = float(input('Ingrese la cantidad deseada (en litros): '))
    
    if cantidad <= 0:
        print('La cantidad debe ser un número positivo.')
        return
    
    monto_total = cantidad * precio
    print(f'El monto total es Q{monto_total:.2f}')

    # Guardar en archivo de texto
    with open('facturas.txt', 'a') as archivo:
        archivo.write(f'Nombre: {nombre}\n')
        archivo.write(f'Placa: {vehiculo}\n')
        archivo.write(f'Tipo de Combustible: {tipoCombustible}\n')
        archivo.write(f'Cantidad (L): {cantidad:.2f}\n')
        archivo.write(f'Precio por Litro: Q{precio:.2f}\n')
        archivo.write(f'Monto Total: Q{monto_total:.2f}\n\n')
    
    # Guardar en la base de datos
    query = """
    INSERT INTO Registro (nombre, vehiculo, tipo_combustible, cantidad, precio_por_litro, monto_total)
    VALUES (%s, %s, %s, %s, %s, %s);
    """
    cursor.execute(query, (nombre, vehiculo, tipoCombustible, cantidad, precio, monto_total))
    conn.commit()

    # Imprimir y borrar la factura
    with open('facturas.txt', 'r') as archivo:
        contenido = archivo.read()
        print('----- Factura -----')
        print(contenido)

    # Borrar el contenido del archivo
    with open('facturas.txt', 'w') as archivo:
        archivo.write('')

def mostrar_historial():
    try:
        query = 'SELECT * FROM Registro;'
        cursor.execute(query)
        rows = cursor.fetchall()
        if rows:
            print('Historial de datos:')
            for row in rows:
                print(row)
        else:
            print('No hay datos en la base de datos.')
    except Exception as e:
        print(f'Error al recuperar el historial de datos: {e}')

def borrar_datos():
    try:
        cursor.execute('DELETE FROM Registro;')
        conn.commit()
        # Borrar el archivo de texto
        open('facturas.txt', 'w').close()
        print('Todos los datos han sido borrados.')
    except Exception as e:
        print(f'Error al borrar los datos: {e}')

def main():
    while True:
        print('1. Ingreso de nombre de usuario')
        print('2. Compra de combustible')
        print('3. Registros')
        print('4. Borrar datos')
        print('5. Salir')

        opcion = int(input('Ingrese su elección: '))
        
        if opcion == 1:
            ingresar_datos_usuario()
        elif opcion == 2:
            realizar_compra()
        elif opcion == 3:
            mostrar_historial()
        elif opcion == 4:
            borrar_datos()
        elif opcion == 5:
            print('Gracias por su compra.')
            cursor.close()
            conn.close()
            break
        else:
            print('Opción no válida, intente de nuevo.')

if __name__ == '__main__':
    main()
