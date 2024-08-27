if (exist('OCTAVE_VERSION', 'builtin') ~= 0)
    % estamos en octave
    pkg load database;  % Cargar el paquete para interactuar con bases de datos
end

% Conectar a la base de datos PostgreSQL
conn = pq_connect(setdbopts('dbname', 'usac', 'host', 'localhost', 'port', '5432', 'user', 'postgres', 'password', 'A@merida123'));

Cregular = 32.98;
Cpremium = 34.68;
Cdiesel = 30.49;

% Menu principal
opcion = 0;
while opcion ~= 5

    disp('1. Nueva compra');
    disp('2. Imprimir Factura');
    disp('3. Salir');
    opcion = input('Ingrese su eleccion: ');

    switch opcion
        case 1
            try
                nombre = input('Ingrese su nombre: ', 's');
                vehiculo = input('Ingrese la placa de su vehículo: ', 's');

                disp('Tipo de combustible');
                disp('1. Regular');
                disp('2. Premium');
                disp('3. Diesel');
                tipo = input('Indique el combustible que desea: ');

                switch tipo
                    case 1
                        precio = Cregular;
                        tipoCombustible = 'Regular';
                    case 2
                        precio = Cpremium;
                        tipoCombustible = 'Premium';
                    case 3
                        precio = Cdiesel;
                        tipoCombustible = 'Diesel';
                    otherwise
                        disp('Opción no válida, intente de nuevo.');
                        continue;
                end

                cantidad = input('Ingrese la cantidad deseada (en litros): ');
                if (cantidad > 0)
                    MT = cantidad * precio;
                    disp(['El monto total es Q', num2str(MT)]);

                    % Guardar los datos en el archivo de texto
                    archivo = fopen('facturas.txt', 'a');
                    fprintf(archivo, 'Nombre: %s\n', nombre);
                    fprintf(archivo, 'Placa: %s\n', vehiculo);
                    fprintf(archivo, 'Tipo de Combustible: %s\n', tipoCombustible);
                    fprintf(archivo, 'Cantidad (L): %.2f\n', cantidad);
                    fprintf(archivo, 'Precio por Litro: Q%.2f\n', precio);
                    fprintf(archivo, 'Monto Total: Q%.2f\n\n', MT);
                    fclose(archivo);

                    % Insertar datos en la base de datos PostgreSQL
                    query = sprintf("INSERT INTO Ventas (Combustible, Litros_Vendidos, Precio_Por_Litro, Total) VALUES ('%s', %.2f, %.2f, %.2f);", tipoCombustible, cantidad, precio, MT);
                    pq_exec(conn, query);
                else
                    disp('Solo pueden ser números positivos');
                end
            catch
                disp('Error en la compra. Datos no válidos');
            end

        case 2
            % Leer y mostrar el contenido del archivo
            archivo = fopen('facturas.txt', 'r');
            if archivo ~= -1
                disp('----- Factura -----');
                contenido = fread(archivo, '*char')';
                fclose(archivo);
                disp(contenido);

                % Borrar el contenido del archivo
                archivo = fopen('facturas.txt', 'w');
                fclose(archivo);
            else
                disp('No hay facturas para mostrar.');
            end

        case 3
            disp('Saliendo del sistema...');
            opcion = 5;

        otherwise
            disp('Opción no válida, intente de nuevo.');
    end
end

% Cerrar la conexión a la base de datos
pq_close(conn);

