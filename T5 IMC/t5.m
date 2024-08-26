if(exist('OCTAVE_VERSION', 'builtin')~=0)
    % Estamos en Octave
    pkg load signal;
end

bajopeso = 'Bajo peso';
pesoNormal = 'Peso normal';
sobrePeso = 'Sobre peso';
if(exist('OCTAVE_VERSION', 'builtin')~=0)
    % Estamos en Octave
    pkg load signal;
end

bajopeso = 'Bajo peso';
pesoNormal = 'Peso normal';
sobrePeso = 'Sobre peso';

% Menú principal
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
            try
                nombre = input('Ingrese su nombre: ', 's');
                peso = input('Ingrese su peso en kg: ');
                altura = input('Ingrese su altura en metros: ');

                if peso == 0 || altura == 0
                  imc = peso / (altura^2);
                    disp(['Su IMC es: ', num2str(imc)]);
                    display('Datos erróneos: el peso y la altura deben ser mayores que 0.');


                else
                    imc = peso / (altura^2);
                    disp(['Su IMC es: ', num2str(imc)]);

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

                    archivo = fopen('imc.txt', 'a');
                    fprintf(archivo, 'Nombre: %s, IMC: %.2f, Categoría: %s\n', nombre, imc, categoria);
                    fclose(archivo);
                    disp('Información guardada correctamente.');
                end
            catch
                disp('Error al calcular y guardar el IMC.');
            end

        case 2
            try
                archivo = fopen('imc.txt', 'r');
                if archivo == -1
                    disp('No se pudo abrir el archivo.');
                else
                    contenido = fread(archivo, '*char')';
                    if isempty(contenido)
                        disp('El archivo está vacío.');
                    else
                        fseek(archivo, 0, 'bof');
                        while ~feof(archivo)
                            linea = fgetl(archivo);
                            disp(linea);
                        end
                    end
                    fclose(archivo);
                end
            catch
                disp('Error al leer la información del archivo.');
            end

        case 3
            try
                delete('imc.txt');
                disp('El archivo ha sido borrado.');
            catch
                disp('Error al borrar el archivo.');
            end

        case 4
            disp('Gracias por usar el programa.');

        otherwise
            disp('Opción no válida.');
    end
end


