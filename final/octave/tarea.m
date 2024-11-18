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
            disp('2. Ingresar palabras');
            disp('3. Ver historial de datos');
            disp('4. Borrar datos');
            disp('5. Salir');
            opcion = input('Ingrese su elección: ');

            switch opcion
                case 1
                    % Verificar que el usuario esté registrado
                    nombre = nombre;
                    carne = carne;

                    % Buscar al usuario en la base de datos
                    result = pq_exec_params(conn, 'SELECT id FROM usuario WHERE nombre = $1 AND carne = $2;', {nombre, carne});

                    if isempty(result.data)
                        disp('Usuario no encontrado. Por favor, registre los datos del usuario primero.');
                    else
                        % Obtener el id del usuario registrado
                        id_usuario = result.data{1};

                        % Solicitar el número a verificar
                        numero_str = input('Ingrese el dato numérico a verificar: ', 's');

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

                            % Insertar los resultados en la base de datos
                            pq_exec_params(conn, ['INSERT INTO verificaciones (id_usuario, dato, es_primo, es_perfecto) ' ...
                                                  'VALUES ($1, $2, $3, $4);'], {id_usuario, numero, es_primo, es_perfecto});
                            disp('Los resultados han sido guardados en la base de datos.');

                            % Guardar los resultados en el archivo de texto
                            fid = fopen(archivo_texto, 'a');
                            fprintf(fid, 'Usuario: %s (Carné: %s)\n', nombre, carne);
                            fprintf(fid, 'Número: %d\n', numero);
                            fprintf(fid, 'Es primo: %d\n', es_primo);
                            fprintf(fid, 'Es perfecto: %d\n\n', es_perfecto);
                            fclose(fid);  % Cerrar el archivo
                            disp('Los resultados también han sido guardados en el archivo de texto.');
                        end
                    end

                case 2
                    % Verificar que el usuario esté registrado
                    nombre = nombre;
                    carne = carne;

                    % Buscar al usuario en la base de datos
                    result = pq_exec_params(conn, 'SELECT id FROM usuario WHERE nombre = $1 AND carne = $2;', {nombre, carne});

                    if isempty(result.data)
                        disp('Usuario no encontrado. Por favor, registre los datos del usuario primero.');
                    else
                        % Obtener el id del usuario registrado
                        id_usuario = result.data{1};

                        % Solicitar la palabra a verificar
                        palabra = input('Ingrese una palabra para verificar si es palíndromo: ', 's');

                        % Verificar que la palabra no contenga caracteres especiales ni números
                        if isempty(regexp(palabra, '^[A-Za-z]+$', 'once'))
                            disp('Por favor ingrese solo palabras sin caracteres especiales o números.');
                        else
                            % Verificar si la palabra es palíndromo
                            if strcmp(palabra, flip(palabra))
                                es_palindromo = true;
                                disp('La palabra es un palíndromo.');
                            else
                                es_palindromo = false;
                                disp('La palabra no es un palíndromo.');
                            end

                            % Guardar los resultados en la base de datos
                            pq_exec_params(conn, ['INSERT INTO verificaciones (id_usuario, dato, es_palindromo) ' ...
                                                  'VALUES ($1, $2, $3);'], {id_usuario, palabra, es_palindromo});
                            disp('El resultado de la palabra ha sido guardado en la base de datos.');

                            % Guardar en el archivo de texto
                            fid = fopen(archivo_texto, 'a');
                            fprintf(fid, 'Usuario: %s (Carné: %s)\n', nombre, carne);
                            fprintf(fid, 'Palabra: %s\n', palabra);
                            fprintf(fid, 'Es palíndromo: %d\n\n', es_palindromo);
                            fclose(fid);  % Cerrar el archivo
                            disp('Datos guardados correctamente en el archivo de texto.');
                        end
                    end

case 3
    % Consulta a la base de datos para obtener todas las verificaciones
    query = 'SELECT id_usuario, dato, es_primo, es_perfecto, es_palindromo FROM verificaciones;';

    % Ejecutar la consulta
    result = pq_exec_params(conn, query, {});

    if isempty(result.data)
        disp('No hay datos registrados.');
    else
        % Mostrar los resultados
        disp('----- Historial de verificaciones -----');
        disp('ID  | Dato  | Primo | Perfecto | Palíndromo');

        % Iterar sobre los resultados y mostrar los datos
        for i = 1:size(result.data, 1)
            % Acceder a cada columna del resultado correctamente
            id_usuario = result.data{i, 1};   % ID del usuario
            dato = result.data{i, 2};         % Número o palabra
            es_primo = result.data{i, 3};     % Es primo (booleano)
            es_perfecto = result.data{i, 4};  % Es perfecto (booleano)
            es_palindromo = result.data{i, 5};% Es palíndromo (booleano)

            % Mostrar los datos con formato
            fprintf('%d    | %s    | %d     | %d     | %d\n', id_usuario, dato, es_primo, es_perfecto, es_palindromo);
        end
    end


                case 4
                    % Borrar los datos de la base de datos
                    pq_exec_params(conn, 'DELETE FROM verificaciones;', {});
                    disp('Todos los datos han sido borrados de la base de datos.');

                case 5
                    disp('Saliendo del programa...');
                    break;

                otherwise
                    disp('Opción no válida.');
            end
        end
    end
end

% Cerrar la conexión a la base de datos
pq_disconnect(conn);
