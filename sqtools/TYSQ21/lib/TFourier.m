function [w,Yw]=TFourier(x,y,deltaX)

%deltaX must be positve
deltaX = abs(deltaX);

Ntemp =( x( length(x) ) - x(1) ) / deltaX;

N=2^ceil(log2(Ntemp));

X = (0:1:N-1)*(x( length(x) ) - x(1))/N + x(1);
Y = interp1(x,y,X);

R_x = (X(length(X))-X(1))*N/(N-1);
deltaX = R_x /N;
w_min = -1 * pi / deltaX;
w_max = pi/deltaX;
R_w = 2*pi/deltaX;
x_min = x(1);

i = sqrt(-1);
Y =  Y .* exp(- i * w_min *((1:1:N)-1)*R_x/N);
Yw = fft(Y) * deltaX;
Yw = Yw * exp( - i * w_min * x_min);
Yw = Yw .* exp( -i*x_min*R_w*((1:1:N)-1)/N);

w = w_min + R_w * ((1:1:N)-1)/N;
%Yw(k) = sum_1^N x(j)* exp( -2*pi*i*(j-1)(k-1)/N )