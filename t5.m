
if(exist('OCTAVE_VERSION', 'builtin')~=0)
% estamos en octave
pkg load signal;
end

bajopeso= 'Bajo peso';
pesoNormal= 'Peso normal';
sobrePeso = 'Sobre peso';
%menu principal
% Inicialización
continuar = true;

opcion = 0;
while opcion ~= 4
    % Menú de opciones
    disp('1. Calcular IMC');
    disp('2. Leer información del archivo');
    disp('3. Borrar información del archivo');
    disp('4. Salir');
    opcion = input('Ingrese su elección: ');

    switch opcion
        case 1
            % Calcular IMC
            try
                nombre = input('Ingrese su nombre: ', 's');
                peso = input('Ingrese su peso en kg: ');
                altura = input('Ingrese su altura en metros: ');

                imc = peso / (altura^2);
                disp(['Su IMC es: ', num2str(imc)]);

                % Categorizar IMC
                if imc < 18.5
                    categoria = bajopeso;
                elseif imc < 24.9
                    categoria = pesoNormal;
                elseif imc < 29.9
                    categoria = sobrePeso;
                else
                    categoria = 'Obesidad';
                end

                disp(['Categoría: ', categoria]);

                % Guardar en archivo de texto 'imc.txt'
                archivo = fopen('imc.txt', 'a'); % Abre el archivo en modo append
                fprintf(archivo, 'Nombre: %s, IMC: %.2f, Categoría: %s\n', nombre, imc, categoria);
                fclose(archivo);
                disp('Información guardada correctamente.');
            catch
                disp('Error al calcular y guardar el IMC.');
            end

        case 2
            % Leer información del archivo
            try
                archivo = fopen('imc.txt', 'r');
                if archivo == -1
                    disp('No se pudo abrir el archivo.');
                else
                    while ~feof(archivo)
                        linea = fgetl(archivo);
                        disp(linea);
                    end
                    fclose(archivo);
                end
            catch
                disp('Error al leer la información del archivo.');
            end

        case 3
            % Borrar información del archivo
            try
                delete('imc.txt');
                disp('El archivo ha sido borrado.');
            catch
                disp('Error al borrar el archivo.');
            end

        case 4
            % Salir
            disp('Gracias por usar el programa');

        otherwise
            disp('Opción no válida.');
    end
end
