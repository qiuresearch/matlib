function p = pl (Qmin, Qmax)
 x = Qmin:0.1:Qmax;
 y = ones(1,length(x));
 z = ones(1,length(x));
 for i = 1:length(x)
  tmp = test_1(x(i));
  y(i) = tmp.sigma_1;
  z(i) = tmp.sigma_2;
 end
plot(x,y,x,z)
title('\sigma_1,\sigma_2 vs q')
grid on;
xlabel('q');
ylabel('\sigma');
text(3.8,0.017,'\sigma_2');
text(3,0.0075,'\sigma_1');