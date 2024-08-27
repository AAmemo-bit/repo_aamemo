if (exist('OCTAVE_VERSION', 'builtin') ~= 0)
    % Estamos en Octave
    pkg load database;  % Cargar el paquete para interactuar con bases de datos
end

Cregular = 32.98;
Cpremium = 34.68;
Cdiesel = 30.49;

conn = pq_connect(setdbopts('dbname','usac','host','localhost',
'port','5432','user','postgres','password','A@merida123'));

% Variables para almacenar nombre y placa
nombre = '';
vehiculo = '';

% Menú principal
opcion = 0;
while opcion ~= 5

    disp('1. Ingreso de nombre de usuario');
    disp('2. Compra de combustible');
    disp('3. Registros');
    disp('4. Borrar datos');
    disp('5. Salir');
    opcion = input('Ingrese su elección: ');

    switch opcion
        case 1
            nombre = input('Ingrese su nombre: ', 's');
            vehiculo = input('Ingrese la placa de su vehículo: ', 's');
            disp('Datos de usuario ingresados correctamente.');

        case 2
            if isempty(nombre) || isempty(vehiculo)
                disp('Debe ingresar primero los datos del usuario en la opción 1.');
            else
                try
                    disp('Tipo de combustible');
                    disp('1. Regular');
                    disp('2. Premium ');
                    disp('3. Diesel ');
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

                    % Mostrar el precio por litro seleccionado
                    disp(['El precio por litro de ', tipoCombustible, ' es Q', num2str(precio)]);

                    cantidad = input('Ingrese la cantidad deseada (en litros): ');
                    if cantidad > 0
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

                        % Guardar los datos en la base de datos
                        query = ['insert into Registro (nombre, vehiculo, tipo_combustible, cantidad, precio_por_litro, monto_total) values (''', nombre, ''', ''', vehiculo, ''', ''', tipoCombustible, ''', ', num2str(cantidad), ', ', num2str(precio), ', ', num2str(MT), ');'];
                        N = pq_exec_params(conn, query);

                        % Imprimir y borrar la factura
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
                    else
                        disp('La cantidad debe ser un número positivo.');
                    end
                catch
                    disp('Error en la compra. Datos no válidos.');
                end
            end

        case 3
    % Historial de datos
    try
        query = [
            "SELECT nombre, vehiculo, tipo_combustible, ", ...
            "CAST(cantidad AS VARCHAR), ", ...
            "CAST(precio_por_litro AS VARCHAR), ", ...
            "CAST(monto_total AS VARCHAR) ", ...
            "FROM Registro;"
        ];
        N = pq_exec_params(conn, query);
        disp(N);
    catch
        disp('Error al recuperar el historial de datos.');
    end


        case 4
            % Borrado de datos
            try
                pq_exec_params(conn, 'delete from Registro;');
                archivo = fopen('facturas.txt', 'w');
                fclose(archivo);
                disp('Todos los datos han sido borrados.');
            catch
                disp('Error al borrar los datos.');
            end

        case 5
            disp('Gracias por su compra');
            pq_close(conn);
            opcion = 5;

        otherwise
            disp('Opción no válida, intente de nuevo.');
    end
end

