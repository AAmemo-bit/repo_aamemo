
if(exist('OCTAVE_VERSION', 'builtin')~=0)
% estamos en octave
pkg load signal;
end

%menu principal
opcion = 0;
while opcion ~= 5
  % opcion = input('seleccione una opcion:\n 1. grabar audio\n 2. reproducir audio\n 3. graficar audio\n 4. salir\n ');
 %menu de opciones
disp('1. Grabar')
disp('2. Reproducir')
disp('3. Graficar')
disp('4. Graficar densidad')
disp('5. Salir')
opcion = input('Ingrese su eleccion: ');

switch opcion
  case 1
    %grabacion de audio
    try
      duracion = input('Ingrese la duracion de la grabacion en segundos: ');
      disp('Comenzando la grabacion...')
      recObj = audiorecorder; % 44100 Hz, 16 bits, 1 canal (mono)
      recordblocking(recObj, duracion);
      disp('Grabacion finalizada');
      data = getaudiodata(recObj);
      audiowrite('Alan.wav', data, recObj.SampleRate);
      disp('Archivo de audio grabado correctamente');
    catch
      disp('Errorr al grabar audio');
    end
   case 2
     %reprduccion de audio
     try
       [data, fs] = audioread('Alan.wav');
       sound(data, fs);
     catch
       disp('Error al reproducir el audio');
     end
    case 3
     %grafico de audio
     try
       [data, fs]=audioread('Alan.wav');
       tiempo = linspace(0, length(data)/fs, length(data));
       plot(tiempo, data);
       xlabel('Tiempo (s)');
       ylabel('Amplitud');
       title('Audio');
      catch
       disp('Error al graficar el audio.');
     end
    case 4
      %graficando espectro de frecuencia
      try
        disp('Graficando espectro de frecuencia...');
        [audio, Fs] = audioread('Alan.wav'); %lee la señal desde al archivo .wav
        N = length(audio); %numero de muestras de la señal
        f = linspace(0, Fs/2, N/2+1); %vector de frecuencias
        ventana = hann(N); %ventana de hann para reducir el efecto de las discontinuidades al calcular la FFT
        Sxx = pwelch(audio, ventana, 0, N, Fs); %densidad espectral de potencia
        plot(f, 10*log10(Sxx(1:N/2+1))); %grafica el espectro de frecuencia en dB
        xlabel('Frecuencia (Hz)');
        ylabel('Espectro de frecuencia de la señal grabada');
      catch
        disp('Error al graficar el audio');
      end
     case 5
      % salir
      disp('Saliendo del programa...');
    otherwise
      disp('Opcion no valida');
    end
   end


