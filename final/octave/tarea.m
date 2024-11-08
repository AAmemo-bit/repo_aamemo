if (exist('OCTAVE_VERSION', 'builtin') ~= 0)
    % Estamos en Octave
    pkg load database;  % Cargar el paquete para interactuar con bases de datos
end

% Inicialización de conexión con la base de datos
conn = pq_connect(setdbopts('dbname','usac','host','localhost', 'port','5432','user','postgres','password','A@merida'));

% Nombre del archivo de texto para guardar los resultados
archivo_texto = 'verificacion.txt';

% Verificar si el archivo de texto existe, si no, crearlo
if exist(archivo_texto, 'file') == 0
    fid = fopen(archivo_texto, 'w');
    fclose(fid);
    disp('El archivo de texto ha sido creado.');
else
    disp('El archivo de texto ya existe.');
end

% Menú inicial para ingresar usuario
while true
    disp('--- Menú Inicial ---');
    disp('1. Ingresar Usuario');
    disp('2. Salir');
    opcion_inicial = input('Ingrese su elección: ');

    if opcion_inicial == 2
        disp('Saliendo del programa...');
        break;
    elseif opcion_inicial == 1
        % Preguntar si ya tienes un usuario registrado
        respuesta = input('¿Ya tienes un usuario registrado? (Y/N): ', 's');

        if strcmpi(respuesta, 'Y')
            % Si ya tienes un usuario, pedir el nombre y carné para verificar
            nombre = input('Ingrese su nombre: ', 's');
            carne = input('Ingrese su carné: ', 's');

            % Verificar si el usuario existe en la base de datos
            result = pq_exec_params(conn, 'SELECT id FROM usuario WHERE nombre = $1 AND carne = $2;', {nombre, carne});

            if isempty(result.data)
                disp('Usuario no encontrado. Por favor, registre primero los datos del usuario.');
                continue;  % Volver al menú inicial
            else
                disp('¡Bienvenido de nuevo!');
            end
        elseif strcmpi(respuesta, 'N')
            % Si no tienes un usuario, crear uno nuevo
            nombre = input('Ingrese su nombre: ', 's');
            carne = input('Ingrese su carné: ', 's');

            % Verificación del nombre y carné
            if isempty(regexp(nombre, '^[a-zA-Z]+$', 'once'))
                disp('El nombre solo debe contener letras.');
                continue;  % Volver al menú inicial
            elseif length(carne) ~= 9 || isempty(regexp(carne, '^\d{9}$', 'once'))
                disp('El carné debe contener exactamente 9 números.');
                continue;  % Volver al menú inicial
            else
                % Insertar los datos del usuario en la base de datos
                pq_exec_params(conn, 'INSERT INTO usuario (nombre, carne) VALUES ($1, $2);', {nombre, carne});
                disp('Usuario registrado correctamente. Ahora puedes iniciar sesión.');
            end
        else
            disp('Respuesta no válida. Debes ingresar "Y" o "N".');
            continue;  % Volver al menú inicial
        end

        % Mostrar el segundo menú una vez que el usuario esté autenticado o registrado
        while true
            disp('--- Menú Principal ---');
            disp('1. Ingresar datos');
            disp('2. Ver historial de datos');
            disp('3. Borrar datos');
            disp('4. Salir');
            opcion = input('Ingrese su elección: ');

            switch opcion
                case 1
           % Verificar que ya hay un usuario registrado
            nombre = nombre;
            carne = carne;

            % Buscar al usuario en la base de datos
            result = pq_exec_params(conn, 'SELECT id FROM usuario WHERE nombre = $1 AND carne = $2;', {nombre, carne});

            if isempty(result.data)
                disp('Usuario no encontrado. Por favor, registre los datos del usuario primero.');
            else
                % Obtener el id del usuario registrado
                id_usuario = result.data{1};

                disp('Tipos de números');
                disp('1. Un número primo es aquel que solo tiene dos divisores: 1 y el mismo número.');
                disp('2. Un número perfecto es aquel que es igual a la suma de sus divisores propios (exceptuando el mismo número).');
                disp('3. Un número palíndromo es aquel que se lee igual de izquierda a derecha que de derecha a izquierda.');

                numero_str = input('Ingrese el dato que desea verificar (solo números): ', 's');

                % Verificar que el dato ingresado sea un número
                if isempty(regexp(numero_str, '^\d+$', 'once'))
                    disp('Por favor ingrese solo números.');
                else
                    numero = str2double(numero_str);

                    % Verificar si el número es primo
                    if numero <= 1
                        es_primo = false;
                        disp('El número no es primo.');
                    else
                        es_primo = true;
                        for i = 2:numero-1
                            if mod(numero, i) == 0
                                es_primo = false;  % Si es divisible por otro número, no es primo
                                break;
                            end
                        end

                        if es_primo
                            disp('El número es primo.');
                        else
                            disp('El número no es un número primo.');
                        end
                    end

                    % Verificar si el número es perfecto
                    suma_divisores = 0;
                    for i = 1:(numero - 1)
                        if mod(numero, i) == 0
                            suma_divisores = suma_divisores + i;
                        end
                    end

                    if suma_divisores == numero
                        es_perfecto = true;
                        disp('El número es un número perfecto.');
                    else
                        es_perfecto = false;
                        disp('El número no es un número perfecto.');
                    end

                    % Verificar si el número es palíndromo
                    num_str = num2str(numero);  % Convertir el número a cadena de texto
                    if strcmp(num_str, flip(num_str))
                        es_palindromo = true;
                        disp('El número es un número palíndromo.');
                    else
                        es_palindromo = false;
                        disp('El número no es un número palíndromo.');
                    end

                    % Insertar los resultados en la base de datos
                    pq_exec_params(conn, ['INSERT INTO verificaciones (id_usuario, numero, es_primo, es_perfecto, es_palindromo) ' ...
                                          'VALUES ($1, $2, $3, $4, $5);'], ...
                                          {id_usuario, numero, es_primo, es_perfecto, es_palindromo});
                    disp('Los resultados han sido guardados en la base de datos.');

                    % Guardar los resultados en el archivo de texto
                    fid = fopen(archivo_texto, 'a');  % Abrir el archivo en modo "append"
                    fprintf(fid, 'Usuario: %s (Carné: %s)\n', nombre, carne);
                    fprintf(fid, 'Número: %d\n', numero);
                    fprintf(fid, 'Es primo: %d\n', es_primo);
                    fprintf(fid, 'Es perfecto: %d\n', es_perfecto);
                    fprintf(fid, 'Es palíndromo: %d\n\n', es_palindromo);
                    fclose(fid);  % Cerrar el archivo
                    disp('Los resultados también han sido guardados en el archivo de texto.');
                end
            end
                case 2
   % Mostrar el historial de datos directamente desde la tabla 'verificaciones'
    result = pq_exec_params(conn, 'SELECT id_usuario, numero, es_primo, es_perfecto, es_palindromo FROM verificaciones;');

    if isempty(result.data)
        disp('No hay datos registrados.');
    else
        disp('----- Historial de verificaciones -----');
        disp('ID Usuario\tNúmero\tPrimo\tPerfecto\tPalíndromo');

        % Iterar sobre los resultados y mostrarlos de forma legible
        for i = 1:size(result.data, 1)
            id_usuario = result.data{i, 1};
            numero = result.data{i, 2};
            es_primo = result.data{i, 3};
            es_perfecto = result.data{i, 4};
            es_palindromo = result.data{i, 5};

            % Mostrar la información de manera formateada
            fprintf('%d\t\t%d\t%d\t%d\t\t%d\n', id_usuario, numero, es_primo, es_perfecto, es_palindromo);
        end
    end
                case 3
                    % Borrar todos los datos de la tabla 'verificaciones'
    try
        % Borrar los registros de la tabla 'verificaciones'
        pq_exec_params(conn, 'DELETE FROM verificaciones;');
        disp('Todos los datos de la tabla de verificaciones han sido borrados.');

        % Borrar los datos del archivo de texto 'verificacion.txt'
        if exist('verificacion.txt', 'file') == 2
            % Si el archivo existe, vaciarlo
            fclose(fopen('verificacion.txt', 'w'));
            disp('Los datos del archivo de texto "verificacion.txt" han sido borrados.');
        else
            disp('El archivo "verificacion.txt" no existe.');
        end
    catch
        disp('Error al borrar los datos.');
    end


                case 4
                    disp('Saliendo del menú principal...');
                    break;
                otherwise
                    disp('Opción no válida. Intente de nuevo.');
            end
        end
    else
        disp('Opción no válida. Intente de nuevo.');
    end
end
