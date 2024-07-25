import matplotlib.pyplot as plt 
import numpy as np 

eje_x = np.arange(0, 2*np.pi, 0.01)
eje_y = np.sin(eje_x)

plt.title("Tarea 1")
plt.xlabel("0 a 2*pi")
plt.ylabel("sin(x)")
plt.plot(eje_x, eje_y)
plt.grid(True, linestyle='--')
plt.show()