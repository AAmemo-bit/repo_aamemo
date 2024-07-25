x = 0:0.01:2*pi;
a = input("Ingrese la amplitud: ");
f = input("Ingrese la frecuencia: ");
y = a*sin(f*x);
plot(x,y);
grid on

