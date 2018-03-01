function [t,Yt]=TInvFourier(x,y,deltaX)

deltaX = abs(deltaX);

Ntemp =( x( length(x) ) - x(1) ) / deltaX;

N=2^ceil(log2(Ntemp));

X = (0:1:N-1)*(x( length(x) ) - x(1))/N + x(1);
Y = interp1(x,y,X);

R_x = (X(length(X))-X(1))*N/(N-1);
deltaX = R_x /N;
x_min = x(1);

t_min = 0;%-pi/deltaX;
t_max = 2*pi/deltaX;
R_t = 2*pi/deltaX;


i = sqrt(-1);
Y =  Y .* exp( -i * t_min *((1:1:N)-1)*R_x/N);
Yt = fft(Y) * deltaX;
Yt = Yt * exp(  -i * t_min * x_min);
Yt = Yt .* exp( -i * x_min*R_t*((1:1:N)-1)/N)/(2*pi);

t = t_min + R_t * ((1:1:N)-1)/N;

%t = fliplr(t);
%Yw(k) = sum_1^N x(j)* exp( -2*pi*i*(j-1)(k-1)/N )