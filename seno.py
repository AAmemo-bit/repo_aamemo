import matplotlib.pyplot as plt 
import numpy as np 

x = np.arange(0, 2*np.pi, 0.01)
y = np.sin(x)

plt.plot(x, y, 'r')
plt.title("Función Seno")
plt.xlabel("x")
plt.ylabel("y")
plt.grid(True, linestyle='--')
plt.show()
