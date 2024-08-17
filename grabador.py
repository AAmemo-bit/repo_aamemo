import numpy as np
import matplotlib.pyplot as plt
import sounddevice as sd
import wavio
from scipy.io import wavfile
from scipy.signal import get_window, welch

# Función principal
def main():
    opcion = 0
    while opcion != 5:
        # Menú de opciones
        print('1. Grabar')
        print('2. Reproducir')
        print('3. Graficar')
        print('4. Graficar densidad')
        print('5. Salir')
        opcion = int(input('Ingrese su elección: '))

        if opcion == 1:
            try:
                # Grabación de audio
                duracion = int(input('Ingrese la duración de la grabación en segundos: '))
                print('Comenzando la grabación...')
                fs = 44100  # Frecuencia de muestreo
                data = sd.rec(int(duracion * fs), samplerate=fs, channels=1, dtype='float64')
                sd.wait()
                print('Grabación finalizada')
                wavio.write('Alan_python.wav', data, fs, sampwidth=2)
                print('Archivo de audio grabado correctamente')
            except Exception as e:
                print(f'Error al grabar audio: {e}')

        elif opcion == 2:
            try:
                # Reproducción de audio
                fs, data = wavfile.read('Alan_python.wav')
                sd.play(data, fs)
                sd.wait()
            except Exception as e:
                print(f'Error al reproducir el audio: {e}')

        elif opcion == 3:
            try:
                # Gráfico de audio
                fs, data = wavfile.read('Alan_python.wav')
                tiempo = np.linspace(0, len(data) / fs, len(data))
                plt.plot(tiempo, data)
                plt.xlabel('Tiempo (s)')
                plt.ylabel('Amplitud')
                plt.title('Audio')
                plt.show()
            except Exception as e:
                print(f'Error al graficar el audio: {e}')

        elif opcion == 4:
            try:
                # Graficando espectro de frecuencia
                print('Graficando espectro de frecuencia...')
                fs, audio = wavfile.read('Alan_python.wav')
                N = len(audio)
                f = np.linspace(0, fs/2, N//2+1)
                ventana = get_window('hann', N)
                f, Sxx = welch(audio, fs, window=ventana, nperseg=N)
                plt.plot(f, 10 * np.log10(Sxx))
                plt.xlabel('Frecuencia (Hz)')
                plt.ylabel('Espectro de frecuencia de la señal grabada (dB)')
                plt.show()
            except Exception as e:
                print(f'Error al graficar la densidad espectral: {e}')

        elif opcion == 5:
            print('Saliendo del programa...')
        else:
            print('Opción no válida')

if __name__ == "__main__":
    main()
