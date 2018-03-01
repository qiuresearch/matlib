function y=EF31(d1,d2,choice)

global Ecoefficient

gE1d20=Ecoefficient(1);
gE1d11=Ecoefficient(2);
gE1d21=Ecoefficient(3);
gE1d31=Ecoefficient(4);
gE1d02=Ecoefficient(5);
gE1d12=Ecoefficient(6);
gE1d22=Ecoefficient(23);
gE1d32=Ecoefficient(24);
gE1d42=Ecoefficient(7);
gE1d13=Ecoefficient(8);
gE1d23=Ecoefficient(9);
gE1d33=Ecoefficient(10);
gE1d24=Ecoefficient(11);

gE2d20=Ecoefficient(12);
gE2d11=Ecoefficient(13);
gE2d21=Ecoefficient(14);
gE2d31=Ecoefficient(15);
gE2d02=Ecoefficient(16);
gE2d12=Ecoefficient(17);
gE2d22=Ecoefficient(25);
gE2d32=Ecoefficient(26);
gE2d42=Ecoefficient(18);
gE2d13=Ecoefficient(19);
gE2d23=Ecoefficient(20);
gE2d33=Ecoefficient(21);
gE2d24=Ecoefficient(22);


%Theorectically, E2d32=0,E2d42=0,E2d12=0,E2d02=0
%                E1d23=0,E1d24=0,E1d21=0,E1d20=0

gE2d32=0;
gE2d42=0;
gE2d12=0;
gE2d02=0;
gE1d23=0;
gE1d24=0;
gE1d21=0;
gE1d20=0;

if choice == 1
    y=gE1d20.*d1.^2 + gE1d11.*d1.*d2 + gE1d21.*d1.^2.*d2 +  ... 
      gE1d31.*d1.^3.*d2 + gE1d02.*d2.^2 + gE1d12.*d1.*d2.^2 +  ... 
      gE1d22.*d1.^2.*d2.^2 + gE1d32.*d1.^3.*d2.^2 +  ... 
      gE1d42.*d1.^4.*d2.^2 + gE1d13.*d1.*d2.^3 +  ... 
      gE1d23.*d1.^2.*d2.^3 + gE1d33.*d1.^3.*d2.^3 +  ... 
      gE1d24.*d1.^2.*d2.^4 ;
end

if choice == 2
    y=gE2d20.*d1.^2 + gE2d11.*d1.*d2 + gE2d21.*d1.^2.*d2 +  ... 
      gE2d31.*d1.^3.*d2 + gE2d42.*d1.^4.*d2.^2 + gE2d02.*d2.^2 +  ... 
      gE2d12.*d1.*d2.^2 + gE2d22.*d1.^2.*d2.^2 +  ... 
      gE2d32.*d1.^3.*d2.^2 + gE2d13.*d1.*d2.^3 +  ... 
      gE2d23.*d1.^2.*d2.^3 + gE2d33.*d1.^3.*d2.^3 +  ... 
      gE2d24.*d1.^2.*d2.^4 ;
end

if choice == 3
    y1=gE1d20.*d1.^2 + gE1d11.*d1.*d2 + gE1d21.*d1.^2.*d2 +  ... 
      gE1d31.*d1.^3.*d2 + gE1d02.*d2.^2 + gE1d12.*d1.*d2.^2 +  ... 
      gE1d22.*d1.^2.*d2.^2 + gE1d32.*d1.^3.*d2.^2 +  ... 
      gE1d42.*d1.^4.*d2.^2 + gE1d13.*d1.*d2.^3 +  ... 
      gE1d23.*d1.^2.*d2.^3 + gE1d33.*d1.^3.*d2.^3 +  ... 
      gE1d24.*d1.^2.*d2.^4 ;
    y2=gE2d20.*d1.^2 + gE2d11.*d1.*d2 + gE2d21.*d1.^2.*d2 +  ... 
      gE2d31.*d1.^3.*d2 + gE2d42.*d1.^4.*d2.^2 + gE2d02.*d2.^2 +  ... 
      gE2d12.*d1.*d2.^2 + gE2d22.*d1.^2.*d2.^2 +  ... 
      gE2d32.*d1.^3.*d2.^2 + gE2d13.*d1.*d2.^3 +  ... 
      gE2d23.*d1.^2.*d2.^3 + gE2d33.*d1.^3.*d2.^3 +  ... 
      gE2d24.*d1.^2.*d2.^4 ;
    y=[y1;y2];
end
 