if (exist('OCTAVE_VERSION', 'builtin') ~= 0)
    % Estamos en Octave
    pkg load database;  % Cargar el paquete para interactuar con bases de datos
end

Cprimera = 15.00;
Cotras = 20.00;

conn = pq_connect(setdbopts('dbname','usac','host','localhost',
'port','5432','user','postgres','password','A@merida123'));

% Variables para almacenar nombre y placa
nombre = '';
nit = '';
vehiculo = '';  % Placa del vehículo almacenada globalmente

% Menú principal
opcion = 0;
while opcion ~= 5

    disp('1. Ingresar datos para factura');
    disp('2. Cancelar el parqueo');
    disp('3. Imprimir Factura');
    disp('4. Borrar datos');
    disp('5. Salir');
    opcion = input('Ingrese su elección: ');

    switch opcion
        case 1
            try
                nombre = input('Ingrese su nombre: ', 's');
                nit = input('Ingrese su nit: ', 's');
                vehiculo = input('Ingrese la placa de su vehículo: ', 's');
                disp('Datos de usuario ingresados correctamente.');
            catch
                disp('Error al guardar los datos');
            end
        case 2
            % Verificar si los datos del cliente han sido ingresados
            if isempty(nombre) || isempty(nit) || isempty(vehiculo)
                disp('Primero ingrese datos para la facturación');
            else
                try
                    disp('Ingrese la hora de entrada y de salida.');
                    entrada = input('Hora de entrada (HH:MM): ', 's');
                    % Verificar formato HH:MM
                    [entrada_hora, entrada_minuto] = strtok(entrada, ':');
                    entrada_hora = str2double(entrada_hora);
                    entrada_minuto = str2double(entrada_minuto(2:end));

                    if isempty(entrada_hora) || isempty(entrada_minuto) || ...
                       entrada_hora < 0 || entrada_hora > 23 || ...
                       entrada_minuto < 0 || entrada_minuto > 59
                        error('Hora de entrada no válida. Debe estar en el formato HH:MM con horas entre 00 y 23 y minutos entre 00 y 59.');
                    end

                    salida = input('Hora de salida (HH:MM): ', 's');
                    % Verificar formato HH:MM
                    [salida_hora, salida_minuto] = strtok(salida, ':');
                    salida_hora = str2double(salida_hora);
                    salida_minuto = str2double(salida_minuto(2:end));

                    if isempty(salida_hora) || isempty(salida_minuto) || ...
                       salida_hora < 0 || salida_hora > 23 || ...
                       salida_minuto < 0 || salida_minuto > 59 || ...
                       (salida_hora < entrada_hora) || ...
                       (salida_hora == entrada_hora && salida_minuto < entrada_minuto)
                        error('Hora de salida no válida. Debe ser posterior a la hora de entrada y estar en el formato HH:MM con horas entre 00 y 23 y minutos entre 00 y 59.');
                    end

                    tiempo_total_minutos = (salida_hora * 60 + salida_minuto) - (entrada_hora * 60 + entrada_minuto);
                    tiempo_total_horas = ceil(tiempo_total_minutos / 60);

                    if tiempo_total_horas <= 1
                        monto_total = Cprimera;
                    else
                        monto_total = Cprimera + (tiempo_total_horas - 1) * Cotras;
                    end

                    % Crear la consulta SQL
                    nombre_escapado = strrep(nombre, '''', '''''');
                    nit_escapado = strrep(nit, '''', '''''');
                    vehiculo_escapado = strrep(vehiculo, '''', '''''');

                    query = sprintf('INSERT INTO registro_parqueo (nombre_del_cliente, nit, placa, hora_entrada, hora_salida, tiempo_total, monto_total) VALUES (''%s'', ''%s'', ''%s'', ''%s:%s'', ''%s:%s'', %d, %.2f);', ...
                        nombre_escapado, nit_escapado, vehiculo_escapado, num2str(entrada_hora, '%02d'), num2str(entrada_minuto, '%02d'), num2str(salida_hora, '%02d'), num2str(salida_minuto, '%02d'), tiempo_total_horas, monto_total);

                    % Ejecutar la consulta
                    N = pq_exec_params(conn, query);

                    % Guardar los datos en el archivo salida.txt
                    fileID = fopen('salida.txt', 'a');
                    fprintf(fileID, 'Nombre: %s\n', nombre);
                    fprintf(fileID, 'NIT: %s\n', nit);
                    fprintf(fileID, 'Placa: %s\n', vehiculo);
                    fprintf(fileID, 'Hora de Entrada: %02d:%02d\n', entrada_hora, entrada_minuto);
                    fprintf(fileID, 'Hora de Salida: %02d:%02d\n', salida_hora, salida_minuto);
                    fprintf(fileID, 'Tiempo Total: %d horas\n', tiempo_total_horas);
                    fprintf(fileID, 'Monto Total a Pagar: Q%.2f\n\n', monto_total);
                    fclose(fileID);

                    % Mostrar el monto total a pagar
                    fprintf('Monto Total a Pagar: Q%.2f\n', monto_total);

                catch
                    disp('Error en la compra. Datos no válidos.');
                end
            end

     case 3
    % Verificar si los datos del cliente han sido ingresados
    if isempty(nombre) || isempty(nit) || isempty(vehiculo)
        disp('No se han ingresado datos de cliente para imprimir la factura.');
    else
        % Imprimir la factura con los datos ingresados
        disp('----Factura----');
        fprintf('Nombre: %s\n', nombre);
        fprintf('NIT: %s\n', nit);
        fprintf('Placa: %s\n', vehiculo);
        fprintf('Hora de Entrada: %02d:%02d\n', entrada_hora, entrada_minuto);
        fprintf('Hora de Salida: %02d:%02d\n', salida_hora, salida_minuto);
        fprintf('Tiempo cobrado: %d horas\n', tiempo_total_horas);
        fprintf('Monto Total a Pagar: Q%.2f\n', monto_total);
        disp('---------------');
    end

case 4
    try
        % Borrar todos los datos de la base de datos
        query = 'DELETE FROM registro_parqueo;';
        N = pq_exec_params(conn, query);
        if N
            disp('Borrando...');
        else
            disp('No se encontraron datos para borrar en la base de datos.');
        end

        % Borrar el contenido del archivo salida.txt
        fileID = fopen('salida.txt', 'w');
        fclose(fileID); % Solo abrir el archivo en modo escritura lo vacía

        disp('Todos los datos han sido borrados.');
    catch
        disp('Error al borrar los datos.');
    end


        case 5
            disp('Gracias, vuelva pronto.');
        otherwise
            disp('Opción no válida. Intente de nuevo.');
    end
end



