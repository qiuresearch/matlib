function data=polyd2_15()

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

data=(gE1d42.^2.*gE2d13.^4.*gE2d31.^3 - gE1d33.*gE1d42.*gE2d13.^3.*gE2d22.*gE2d31.^3 -  ... 
    gE1d32.*gE1d42.*gE2d13.^3.*gE2d23.*gE2d31.^3 +  ... 
    gE1d22.*gE1d42.*gE2d13.^2.*gE2d23.^2.*gE2d31.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d22.*gE2d23.^2.*gE2d31.^3 -  ... 
    gE1d12.*gE1d42.*gE2d13.*gE2d23.^3.*gE2d31.^3 +  ... 
    gE1d02.*gE1d42.*gE2d23.^4.*gE2d31.^3 -  ... 
    3.*gE1d33.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d24.*gE2d31.^3 -  ... 
    gE1d31.*gE1d42.*gE2d13.^3.*gE2d24.*gE2d31.^3 +  ... 
    2.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d22.*gE2d24.*gE2d31.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d22.^2.*gE2d24.*gE2d31.^3 -  ... 
    6.*gE1d13.*gE1d42.*gE2d13.*gE2d21.*gE2d23.*gE2d24.*gE2d31.^3 -  ... 
    6.*gE1d12.*gE1d42.*gE2d13.*gE2d22.*gE2d23.*gE2d24.*gE2d31.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d23.^2.*gE2d24.*gE2d31.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d23.^2.*gE2d24.*gE2d31.^3 +  ... 
    12.*gE1d02.*gE1d42.*gE2d22.*gE2d23.^2.*gE2d24.*gE2d31.^3 +  ... 
    2.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d24.^2.*gE2d31.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d24.^2.*gE2d31.^3 -  ... 
    3.*gE1d12.*gE1d42.*gE2d13.*gE2d21.*gE2d24.^2.*gE2d31.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d22.*gE2d24.^2.*gE2d31.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d22.*gE2d24.^2.*gE2d31.^3 +  ... 
    6.*gE1d02.*gE1d42.*gE2d22.^2.*gE2d24.^2.*gE2d31.^3 -  ... 
    3.*gE1d12.*gE1d42.*gE2d11.*gE2d23.*gE2d24.^2.*gE2d31.^3 +  ... 
    12.*gE1d02.*gE1d42.*gE2d21.*gE2d23.*gE2d24.^2.*gE2d31.^3 -  ... 
    gE1d11.*gE1d42.*gE2d11.*gE2d24.^3.*gE2d31.^3 +  ... 
    4.*gE1d02.*gE1d42.*gE2d20.*gE2d24.^3.*gE2d31.^3 +  ... 
    gE1d33.^2.*gE2d13.^3.*gE2d31.^4 + gE1d13.*gE1d33.*gE2d13.*gE2d23.^2.*gE2d31.^4 -  ... 
    gE1d22.*gE1d33.*gE2d13.^2.*gE2d24.*gE2d31.^4 +  ... 
    3.*gE1d13.*gE1d42.*gE2d13.^2.*gE2d24.*gE2d31.^4 +  ... 
    2.*gE1d13.*gE1d33.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^4 +  ... 
    2.*gE1d13.*gE1d32.*gE2d13.*gE2d23.*gE2d24.*gE2d31.^4 +  ... 
    2.*gE1d12.*gE1d33.*gE2d13.*gE2d23.*gE2d24.*gE2d31.^4 -  ... 
    3.*gE1d02.*gE1d33.*gE2d23.^2.*gE2d24.*gE2d31.^4 +  ... 
    gE1d13.*gE1d33.*gE2d11.*gE2d24.^2.*gE2d31.^4 +  ... 
    gE1d13.*gE1d31.*gE2d13.*gE2d24.^2.*gE2d31.^4 +  ... 
    gE1d12.*gE1d32.*gE2d13.*gE2d24.^2.*gE2d31.^4 +  ... 
    gE1d11.*gE1d33.*gE2d13.*gE2d24.^2.*gE2d31.^4 -  ... 
    4.*gE1d02.*gE1d42.*gE2d13.*gE2d24.^2.*gE2d31.^4 -  ... 
    3.*gE1d02.*gE1d33.*gE2d22.*gE2d24.^2.*gE2d31.^4 -  ... 
    3.*gE1d02.*gE1d32.*gE2d23.*gE2d24.^2.*gE2d31.^4 -  ... 
    gE1d02.*gE1d31.*gE2d24.^3.*gE2d31.^4 +  ... 
    12.*gE1d42.^2.*gE2d11.*gE2d13.^3.*gE2d31.^2.*gE2d33 -  ... 
    3.*gE1d33.*gE1d42.*gE2d13.^3.*gE2d20.*gE2d31.^2.*gE2d33 -  ... 
    3.*gE1d32.*gE1d42.*gE2d13.^3.*gE2d21.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d33.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d22.*gE2d31.^2.*gE2d33 -  ... 
    3.*gE1d31.*gE1d42.*gE2d13.^3.*gE2d22.*gE2d31.^2.*gE2d33 +  ... 
    3.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d22.^2.*gE2d31.^2.*gE2d33 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d22.^3.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d32.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d23.*gE2d31.^2.*gE2d33 +  ... 
    6.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d13.*gE1d42.*gE2d13.*gE2d21.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d12.*gE1d42.*gE2d13.*gE2d22.^2.*gE2d23.*gE2d31.^2.*gE2d33 +  ... 
    6.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d23.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d23.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d12.*gE1d42.*gE2d13.*gE2d21.*gE2d23.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d13.*gE1d42.*gE2d11.*gE2d22.*gE2d23.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d11.*gE1d42.*gE2d13.*gE2d22.*gE2d23.^2.*gE2d31.^2.*gE2d33 +  ... 
    18.*gE1d02.*gE1d42.*gE2d22.^2.*gE2d23.^2.*gE2d31.^2.*gE2d33 -  ... 
    3.*gE1d12.*gE1d42.*gE2d11.*gE2d23.^3.*gE2d31.^2.*gE2d33 +  ... 
    12.*gE1d02.*gE1d42.*gE2d21.*gE2d23.^3.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d33.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d31.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    6.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d13.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    12.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d12.*gE1d42.*gE2d13.*gE2d21.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d13.*gE1d42.*gE2d11.*gE2d22.^2.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d11.*gE1d42.*gE2d13.*gE2d22.^2.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    12.*gE1d02.*gE1d42.*gE2d22.^3.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d12.*gE1d42.*gE2d13.*gE2d20.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d13.*gE1d42.*gE2d11.*gE2d21.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d11.*gE1d42.*gE2d13.*gE2d21.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    18.*gE1d12.*gE1d42.*gE2d11.*gE2d22.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    72.*gE1d02.*gE1d42.*gE2d21.*gE2d22.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d11.*gE1d42.*gE2d11.*gE2d23.^2.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    36.*gE1d02.*gE1d42.*gE2d20.*gE2d23.^2.*gE2d24.*gE2d31.^2.*gE2d33 +  ... 
    3.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d24.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d13.*gE1d42.*gE2d11.*gE2d20.*gE2d24.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d11.*gE1d42.*gE2d13.*gE2d20.*gE2d24.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d12.*gE1d42.*gE2d11.*gE2d21.*gE2d24.^2.*gE2d31.^2.*gE2d33 +  ... 
    18.*gE1d02.*gE1d42.*gE2d21.^2.*gE2d24.^2.*gE2d31.^2.*gE2d33 -  ... 
    9.*gE1d11.*gE1d42.*gE2d11.*gE2d22.*gE2d24.^2.*gE2d31.^2.*gE2d33 +  ... 
    36.*gE1d02.*gE1d42.*gE2d20.*gE2d22.*gE2d24.^2.*gE2d31.^2.*gE2d33 +  ... 
    12.*gE1d33.^2.*gE2d11.*gE2d13.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d32.^2.*gE2d13.^3.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d31.*gE1d33.*gE2d13.^3.*gE2d31.^3.*gE2d33 -  ... 
    8.*gE1d22.*gE1d42.*gE2d13.^3.*gE2d31.^3.*gE2d33 -  ... 
    4.*gE1d22.*gE1d33.*gE2d13.^2.*gE2d22.*gE2d31.^3.*gE2d33 +  ... 
    12.*gE1d13.*gE1d42.*gE2d13.^2.*gE2d22.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d13.*gE1d33.*gE2d13.*gE2d22.^2.*gE2d31.^3.*gE2d33 -  ... 
    4.*gE1d22.*gE1d32.*gE2d13.^2.*gE2d23.*gE2d31.^3.*gE2d33 +  ... 
    12.*gE1d12.*gE1d42.*gE2d13.^2.*gE2d23.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d33.*gE2d13.*gE2d21.*gE2d23.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d32.*gE2d13.*gE2d22.*gE2d23.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d12.*gE1d33.*gE2d13.*gE2d22.*gE2d23.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d13.*gE1d33.*gE2d11.*gE2d23.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d13.*gE1d31.*gE2d13.*gE2d23.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d12.*gE1d32.*gE2d13.*gE2d23.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d11.*gE1d33.*gE2d13.*gE2d23.^2.*gE2d31.^3.*gE2d33 -  ... 
    16.*gE1d02.*gE1d42.*gE2d13.*gE2d23.^2.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d33.*gE2d22.*gE2d23.^2.*gE2d31.^3.*gE2d33 -  ... 
    4.*gE1d02.*gE1d32.*gE2d23.^3.*gE2d31.^3.*gE2d33 -  ... 
    8.*gE1d22.*gE1d33.*gE2d11.*gE2d13.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    24.*gE1d13.*gE1d42.*gE2d11.*gE2d13.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    4.*gE1d22.*gE1d31.*gE2d13.^2.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    12.*gE1d11.*gE1d42.*gE2d13.^2.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d33.*gE2d13.*gE2d20.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d32.*gE2d13.*gE2d21.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d12.*gE1d33.*gE2d13.*gE2d21.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d33.*gE2d11.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d31.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d12.*gE1d32.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d11.*gE1d33.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    32.*gE1d02.*gE1d42.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d33.*gE2d22.^2.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d13.*gE1d32.*gE2d11.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d12.*gE1d33.*gE2d11.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d12.*gE1d31.*gE2d13.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    8.*gE1d11.*gE1d32.*gE2d13.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    24.*gE1d02.*gE1d33.*gE2d21.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    24.*gE1d02.*gE1d32.*gE2d22.*gE2d23.*gE2d24.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d31.*gE2d23.^2.*gE2d24.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d13.*gE1d31.*gE2d11.*gE2d24.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d12.*gE1d32.*gE2d11.*gE2d24.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d11.*gE1d33.*gE2d11.*gE2d24.^2.*gE2d31.^3.*gE2d33 -  ... 
    16.*gE1d02.*gE1d42.*gE2d11.*gE2d24.^2.*gE2d31.^3.*gE2d33 +  ... 
    4.*gE1d11.*gE1d31.*gE2d13.*gE2d24.^2.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d33.*gE2d20.*gE2d24.^2.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d32.*gE2d21.*gE2d24.^2.*gE2d31.^3.*gE2d33 -  ... 
    12.*gE1d02.*gE1d31.*gE2d22.*gE2d24.^2.*gE2d31.^3.*gE2d33 -  ... 
    10.*gE1d13.*gE1d33.*gE2d13.^2.*gE2d31.^4.*gE2d33 -  ... 
    5.*gE1d13.*gE1d22.*gE2d13.*gE2d24.*gE2d31.^4.*gE2d33 +  ... 
    15.*gE1d02.*gE1d33.*gE2d13.*gE2d24.*gE2d31.^4.*gE2d33 +  ... 
    5.*gE1d02.*gE1d22.*gE2d24.^2.*gE2d31.^4.*gE2d33 +  ... 
    18.*gE1d42.^2.*gE2d11.^2.*gE2d13.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d33.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d20.*gE2d31.*gE2d33.^2 -  ... 
    3.*gE1d31.*gE1d42.*gE2d13.^3.*gE2d20.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d32.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d21.*gE2d31.*gE2d33.^2 +  ... 
    3.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d21.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d33.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d22.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d31.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d22.*gE2d31.*gE2d33.^2 +  ... 
    6.*gE1d22.*gE1d42.*gE2d13.^2.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d13.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d22.*gE2d31.*gE2d33.^2 +  ... 
    6.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d22.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d22.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d12.*gE1d42.*gE2d13.*gE2d21.*gE2d22.^2.*gE2d31.*gE2d33.^2 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d22.^3.*gE2d31.*gE2d33.^2 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d22.^3.*gE2d31.*gE2d33.^2 +  ... 
    3.*gE1d02.*gE1d42.*gE2d22.^4.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d32.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d23.*gE2d31.*gE2d33.^2 +  ... 
    12.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d12.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d12.*gE1d42.*gE2d13.*gE2d20.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d13.*gE1d42.*gE2d11.*gE2d21.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d11.*gE1d42.*gE2d13.*gE2d21.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d12.*gE1d42.*gE2d11.*gE2d22.^2.*gE2d23.*gE2d31.*gE2d33.^2 +  ... 
    36.*gE1d02.*gE1d42.*gE2d21.*gE2d22.^2.*gE2d23.*gE2d31.*gE2d33.^2 +  ... 
    3.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d23.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d13.*gE1d42.*gE2d11.*gE2d20.*gE2d23.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d11.*gE1d42.*gE2d13.*gE2d20.*gE2d23.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d12.*gE1d42.*gE2d11.*gE2d21.*gE2d23.^2.*gE2d31.*gE2d33.^2 +  ... 
    18.*gE1d02.*gE1d42.*gE2d21.^2.*gE2d23.^2.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d11.*gE1d42.*gE2d11.*gE2d22.*gE2d23.^2.*gE2d31.*gE2d33.^2 +  ... 
    36.*gE1d02.*gE1d42.*gE2d20.*gE2d22.*gE2d23.^2.*gE2d31.*gE2d33.^2 -  ... 
    3.*gE1d33.*gE1d42.*gE2d11.^3.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d31.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d24.*gE2d31.*gE2d33.^2 +  ... 
    12.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d13.*gE1d42.*gE2d13.*gE2d20.^2.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d12.*gE1d42.*gE2d13.*gE2d20.*gE2d21.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d13.*gE1d42.*gE2d11.*gE2d21.^2.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d11.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d24.*gE2d31.*gE2d33.^2 +  ... 
    6.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d13.*gE1d42.*gE2d11.*gE2d20.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d11.*gE1d42.*gE2d13.*gE2d20.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d12.*gE1d42.*gE2d11.*gE2d21.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^2 +  ... 
    36.*gE1d02.*gE1d42.*gE2d21.^2.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d11.*gE1d42.*gE2d11.*gE2d22.^2.*gE2d24.*gE2d31.*gE2d33.^2 +  ... 
    36.*gE1d02.*gE1d42.*gE2d20.*gE2d22.^2.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d12.*gE1d42.*gE2d11.*gE2d20.*gE2d23.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    18.*gE1d11.*gE1d42.*gE2d11.*gE2d21.*gE2d23.*gE2d24.*gE2d31.*gE2d33.^2 +  ... 
    72.*gE1d02.*gE1d42.*gE2d20.*gE2d21.*gE2d23.*gE2d24.*gE2d31.*gE2d33.^2 -  ... 
    9.*gE1d11.*gE1d42.*gE2d11.*gE2d20.*gE2d24.^2.*gE2d31.*gE2d33.^2 +  ... 
    18.*gE1d02.*gE1d42.*gE2d20.^2.*gE2d24.^2.*gE2d31.*gE2d33.^2 +  ... 
    18.*gE1d33.^2.*gE2d11.^2.*gE2d13.*gE2d31.^2.*gE2d33.^2 +  ... 
    18.*gE1d32.^2.*gE2d11.*gE2d13.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    36.*gE1d31.*gE1d33.*gE2d11.*gE2d13.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d22.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d31.^2.*gE2d13.^3.*gE2d31.^2.*gE2d33.^2 -  ... 
    6.*gE1d22.*gE1d33.*gE2d13.^2.*gE2d20.*gE2d31.^2.*gE2d33.^2 +  ... 
    18.*gE1d13.*gE1d42.*gE2d13.^2.*gE2d20.*gE2d31.^2.*gE2d33.^2 -  ... 
    6.*gE1d22.*gE1d32.*gE2d13.^2.*gE2d21.*gE2d31.^2.*gE2d33.^2 +  ... 
    18.*gE1d12.*gE1d42.*gE2d13.^2.*gE2d21.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d13.*gE1d33.*gE2d13.*gE2d21.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    12.*gE1d22.*gE1d33.*gE2d11.*gE2d13.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    36.*gE1d13.*gE1d42.*gE2d11.*gE2d13.*gE2d22.*gE2d31.^2.*gE2d33.^2 -  ... 
    6.*gE1d22.*gE1d31.*gE2d13.^2.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    18.*gE1d11.*gE1d42.*gE2d13.^2.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d33.*gE2d13.*gE2d20.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d32.*gE2d13.*gE2d21.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d33.*gE2d13.*gE2d21.*gE2d22.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d13.*gE1d33.*gE2d11.*gE2d22.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d13.*gE1d31.*gE2d13.*gE2d22.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d12.*gE1d32.*gE2d13.*gE2d22.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d11.*gE1d33.*gE2d13.*gE2d22.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    24.*gE1d02.*gE1d42.*gE2d13.*gE2d22.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    6.*gE1d02.*gE1d33.*gE2d22.^3.*gE2d31.^2.*gE2d33.^2 -  ... 
    12.*gE1d22.*gE1d32.*gE2d11.*gE2d13.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    36.*gE1d12.*gE1d42.*gE2d11.*gE2d13.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d32.*gE2d13.*gE2d20.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d33.*gE2d13.*gE2d20.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d33.*gE2d11.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d31.*gE2d13.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d32.*gE2d13.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d33.*gE2d13.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^2 -  ... 
    48.*gE1d02.*gE1d42.*gE2d13.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d32.*gE2d11.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d33.*gE2d11.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d31.*gE2d13.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d32.*gE2d13.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d02.*gE1d33.*gE2d21.*gE2d22.*gE2d23.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d32.*gE2d22.^2.*gE2d23.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d13.*gE1d31.*gE2d11.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d12.*gE1d32.*gE2d11.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d11.*gE1d33.*gE2d11.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    24.*gE1d02.*gE1d42.*gE2d11.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d11.*gE1d31.*gE2d13.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d33.*gE2d20.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d32.*gE2d21.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d31.*gE2d22.*gE2d23.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    6.*gE1d22.*gE1d33.*gE2d11.^2.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    18.*gE1d13.*gE1d42.*gE2d11.^2.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    12.*gE1d22.*gE1d31.*gE2d11.*gE2d13.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    36.*gE1d11.*gE1d42.*gE2d11.*gE2d13.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d33.*gE2d11.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d31.*gE2d13.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d32.*gE2d13.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d33.*gE2d13.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    48.*gE1d02.*gE1d42.*gE2d13.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d32.*gE2d11.*gE2d21.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d33.*gE2d11.*gE2d21.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d31.*gE2d13.*gE2d21.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d32.*gE2d13.*gE2d21.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d33.*gE2d21.^2.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d13.*gE1d31.*gE2d11.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d32.*gE2d11.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d33.*gE2d11.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    48.*gE1d02.*gE1d42.*gE2d11.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d31.*gE2d13.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d02.*gE1d33.*gE2d20.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d02.*gE1d32.*gE2d21.*gE2d22.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d31.*gE2d22.^2.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d12.*gE1d31.*gE2d11.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    12.*gE1d11.*gE1d32.*gE2d11.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d02.*gE1d32.*gE2d20.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33.^2 -  ... 
    36.*gE1d02.*gE1d31.*gE2d21.*gE2d23.*gE2d24.*gE2d31.^2.*gE2d33.^2 +  ... 
    6.*gE1d11.*gE1d31.*gE2d11.*gE2d24.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    18.*gE1d02.*gE1d31.*gE2d20.*gE2d24.^2.*gE2d31.^2.*gE2d33.^2 -  ... 
    40.*gE1d13.*gE1d33.*gE2d11.*gE2d13.*gE2d31.^3.*gE2d33.^2 +  ... 
    10.*gE1d22.^2.*gE2d13.^2.*gE2d31.^3.*gE2d33.^2 -  ... 
    20.*gE1d13.*gE1d31.*gE2d13.^2.*gE2d31.^3.*gE2d33.^2 -  ... 
    20.*gE1d12.*gE1d32.*gE2d13.^2.*gE2d31.^3.*gE2d33.^2 -  ... 
    20.*gE1d11.*gE1d33.*gE2d13.^2.*gE2d31.^3.*gE2d33.^2 +  ... 
    20.*gE1d02.*gE1d42.*gE2d13.^2.*gE2d31.^3.*gE2d33.^2 -  ... 
    10.*gE1d13.*gE1d22.*gE2d13.*gE2d22.*gE2d31.^3.*gE2d33.^2 +  ... 
    30.*gE1d02.*gE1d33.*gE2d13.*gE2d22.*gE2d31.^3.*gE2d33.^2 -  ... 
    10.*gE1d12.*gE1d22.*gE2d13.*gE2d23.*gE2d31.^3.*gE2d33.^2 +  ... 
    30.*gE1d02.*gE1d32.*gE2d13.*gE2d23.*gE2d31.^3.*gE2d33.^2 +  ... 
    10.*gE1d02.*gE1d22.*gE2d23.^2.*gE2d31.^3.*gE2d33.^2 -  ... 
    10.*gE1d13.*gE1d22.*gE2d11.*gE2d24.*gE2d31.^3.*gE2d33.^2 +  ... 
    30.*gE1d02.*gE1d33.*gE2d11.*gE2d24.*gE2d31.^3.*gE2d33.^2 -  ... 
    10.*gE1d11.*gE1d22.*gE2d13.*gE2d24.*gE2d31.^3.*gE2d33.^2 +  ... 
    30.*gE1d02.*gE1d31.*gE2d13.*gE2d24.*gE2d31.^3.*gE2d33.^2 +  ... 
    20.*gE1d02.*gE1d22.*gE2d22.*gE2d24.*gE2d31.^3.*gE2d33.^2 +  ... 
    15.*gE1d13.^2.*gE2d13.*gE2d31.^4.*gE2d33.^2 -  ... 
    15.*gE1d02.*gE1d13.*gE2d24.*gE2d31.^4.*gE2d33.^2 +  ... 
    4.*gE1d42.^2.*gE2d11.^3.*gE2d13.*gE2d33.^3 -  ... 
    3.*gE1d33.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d20.*gE2d33.^3 -  ... 
    3.*gE1d31.*gE1d42.*gE2d11.*gE2d13.^2.*gE2d20.*gE2d33.^3 +  ... 
    gE1d22.*gE1d42.*gE2d13.^2.*gE2d20.^2.*gE2d33.^3 -  ... 
    3.*gE1d32.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d21.*gE2d33.^3 +  ... 
    2.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d21.^2.*gE2d33.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d20.*gE2d21.^2.*gE2d33.^3 -  ... 
    gE1d12.*gE1d42.*gE2d13.*gE2d21.^3.*gE2d33.^3 -  ... 
    gE1d33.*gE1d42.*gE2d11.^3.*gE2d22.*gE2d33.^3 -  ... 
    3.*gE1d31.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d22.*gE2d33.^3 +  ... 
    4.*gE1d22.*gE1d42.*gE2d11.*gE2d13.*gE2d20.*gE2d22.*gE2d33.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d13.*gE2d20.^2.*gE2d22.*gE2d33.^3 -  ... 
    6.*gE1d12.*gE1d42.*gE2d13.*gE2d20.*gE2d21.*gE2d22.*gE2d33.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d21.^2.*gE2d22.*gE2d33.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d22.*gE2d33.^3 +  ... 
    gE1d22.*gE1d42.*gE2d11.^2.*gE2d22.^2.*gE2d33.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d20.*gE2d22.^2.*gE2d33.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d20.*gE2d22.^2.*gE2d33.^3 -  ... 
    3.*gE1d12.*gE1d42.*gE2d11.*gE2d21.*gE2d22.^2.*gE2d33.^3 +  ... 
    6.*gE1d02.*gE1d42.*gE2d21.^2.*gE2d22.^2.*gE2d33.^3 -  ... 
    gE1d11.*gE1d42.*gE2d11.*gE2d22.^3.*gE2d33.^3 +  ... 
    4.*gE1d02.*gE1d42.*gE2d20.*gE2d22.^3.*gE2d33.^3 -  ... 
    gE1d32.*gE1d42.*gE2d11.^3.*gE2d23.*gE2d33.^3 -  ... 
    3.*gE1d12.*gE1d42.*gE2d13.*gE2d20.^2.*gE2d23.*gE2d33.^3 +  ... 
    2.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d21.*gE2d23.*gE2d33.^3 -  ... 
    6.*gE1d13.*gE1d42.*gE2d11.*gE2d20.*gE2d21.*gE2d23.*gE2d33.^3 -  ... 
    6.*gE1d11.*gE1d42.*gE2d13.*gE2d20.*gE2d21.*gE2d23.*gE2d33.^3 -  ... 
    3.*gE1d12.*gE1d42.*gE2d11.*gE2d21.^2.*gE2d23.*gE2d33.^3 +  ... 
    4.*gE1d02.*gE1d42.*gE2d21.^3.*gE2d23.*gE2d33.^3 -  ... 
    6.*gE1d12.*gE1d42.*gE2d11.*gE2d20.*gE2d22.*gE2d23.*gE2d33.^3 -  ... 
    6.*gE1d11.*gE1d42.*gE2d11.*gE2d21.*gE2d22.*gE2d23.*gE2d33.^3 +  ... 
    24.*gE1d02.*gE1d42.*gE2d20.*gE2d21.*gE2d22.*gE2d23.*gE2d33.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d11.*gE2d20.*gE2d23.^2.*gE2d33.^3 +  ... 
    6.*gE1d02.*gE1d42.*gE2d20.^2.*gE2d23.^2.*gE2d33.^3 -  ... 
    gE1d31.*gE1d42.*gE2d11.^3.*gE2d24.*gE2d33.^3 +  ... 
    2.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d20.*gE2d24.*gE2d33.^3 -  ... 
    3.*gE1d13.*gE1d42.*gE2d11.*gE2d20.^2.*gE2d24.*gE2d33.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d13.*gE2d20.^2.*gE2d24.*gE2d33.^3 -  ... 
    6.*gE1d12.*gE1d42.*gE2d11.*gE2d20.*gE2d21.*gE2d24.*gE2d33.^3 -  ... 
    3.*gE1d11.*gE1d42.*gE2d11.*gE2d21.^2.*gE2d24.*gE2d33.^3 +  ... 
    12.*gE1d02.*gE1d42.*gE2d20.*gE2d21.^2.*gE2d24.*gE2d33.^3 -  ... 
    6.*gE1d11.*gE1d42.*gE2d11.*gE2d20.*gE2d22.*gE2d24.*gE2d33.^3 +  ... 
    12.*gE1d02.*gE1d42.*gE2d20.^2.*gE2d22.*gE2d24.*gE2d33.^3 +  ... 
    4.*gE1d33.^2.*gE2d11.^3.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d32.^2.*gE2d11.^2.*gE2d13.*gE2d31.*gE2d33.^3 +  ... 
    24.*gE1d31.*gE1d33.*gE2d11.^2.*gE2d13.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d22.*gE1d42.*gE2d11.^2.*gE2d13.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d31.^2.*gE2d11.*gE2d13.^2.*gE2d31.*gE2d33.^3 -  ... 
    8.*gE1d22.*gE1d33.*gE2d11.*gE2d13.*gE2d20.*gE2d31.*gE2d33.^3 +  ... 
    24.*gE1d13.*gE1d42.*gE2d11.*gE2d13.*gE2d20.*gE2d31.*gE2d33.^3 -  ... 
    4.*gE1d22.*gE1d31.*gE2d13.^2.*gE2d20.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d11.*gE1d42.*gE2d13.^2.*gE2d20.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d13.*gE1d33.*gE2d13.*gE2d20.^2.*gE2d31.*gE2d33.^3 -  ... 
    8.*gE1d22.*gE1d32.*gE2d11.*gE2d13.*gE2d21.*gE2d31.*gE2d33.^3 +  ... 
    24.*gE1d12.*gE1d42.*gE2d11.*gE2d13.*gE2d21.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d32.*gE2d13.*gE2d20.*gE2d21.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d33.*gE2d13.*gE2d20.*gE2d21.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d13.*gE1d33.*gE2d11.*gE2d21.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d13.*gE1d31.*gE2d13.*gE2d21.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d12.*gE1d32.*gE2d13.*gE2d21.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d11.*gE1d33.*gE2d13.*gE2d21.^2.*gE2d31.*gE2d33.^3 -  ... 
    16.*gE1d02.*gE1d42.*gE2d13.*gE2d21.^2.*gE2d31.*gE2d33.^3 -  ... 
    4.*gE1d22.*gE1d33.*gE2d11.^2.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d13.*gE1d42.*gE2d11.^2.*gE2d22.*gE2d31.*gE2d33.^3 -  ... 
    8.*gE1d22.*gE1d31.*gE2d11.*gE2d13.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    24.*gE1d11.*gE1d42.*gE2d11.*gE2d13.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d33.*gE2d11.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d31.*gE2d13.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d32.*gE2d13.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d33.*gE2d13.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^3 -  ... 
    32.*gE1d02.*gE1d42.*gE2d13.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d32.*gE2d11.*gE2d21.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d33.*gE2d11.*gE2d21.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d31.*gE2d13.*gE2d21.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d32.*gE2d13.*gE2d21.*gE2d22.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d33.*gE2d21.^2.*gE2d22.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d13.*gE1d31.*gE2d11.*gE2d22.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d12.*gE1d32.*gE2d11.*gE2d22.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d11.*gE1d33.*gE2d11.*gE2d22.^2.*gE2d31.*gE2d33.^3 -  ... 
    16.*gE1d02.*gE1d42.*gE2d11.*gE2d22.^2.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d11.*gE1d31.*gE2d13.*gE2d22.^2.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d33.*gE2d20.*gE2d22.^2.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d32.*gE2d21.*gE2d22.^2.*gE2d31.*gE2d33.^3 -  ... 
    4.*gE1d02.*gE1d31.*gE2d22.^3.*gE2d31.*gE2d33.^3 -  ... 
    4.*gE1d22.*gE1d32.*gE2d11.^2.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d12.*gE1d42.*gE2d11.^2.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d32.*gE2d11.*gE2d20.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d33.*gE2d11.*gE2d20.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d31.*gE2d13.*gE2d20.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d32.*gE2d13.*gE2d20.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d31.*gE2d11.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d32.*gE2d11.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d33.*gE2d11.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 -  ... 
    32.*gE1d02.*gE1d42.*gE2d11.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d31.*gE2d13.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d02.*gE1d33.*gE2d20.*gE2d21.*gE2d23.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d32.*gE2d21.^2.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d31.*gE2d11.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d32.*gE2d11.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d02.*gE1d32.*gE2d20.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d02.*gE1d31.*gE2d21.*gE2d22.*gE2d23.*gE2d31.*gE2d33.^3 +  ... 
    4.*gE1d11.*gE1d31.*gE2d11.*gE2d23.^2.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d31.*gE2d20.*gE2d23.^2.*gE2d31.*gE2d33.^3 -  ... 
    4.*gE1d22.*gE1d31.*gE2d11.^2.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    12.*gE1d11.*gE1d42.*gE2d11.^2.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d13.*gE1d31.*gE2d11.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d32.*gE2d11.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d33.*gE2d11.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    32.*gE1d02.*gE1d42.*gE2d11.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d31.*gE2d13.*gE2d20.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d33.*gE2d20.^2.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d12.*gE1d31.*gE2d11.*gE2d21.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d32.*gE2d11.*gE2d21.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d02.*gE1d32.*gE2d20.*gE2d21.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    12.*gE1d02.*gE1d31.*gE2d21.^2.*gE2d24.*gE2d31.*gE2d33.^3 +  ... 
    8.*gE1d11.*gE1d31.*gE2d11.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    24.*gE1d02.*gE1d31.*gE2d20.*gE2d22.*gE2d24.*gE2d31.*gE2d33.^3 -  ... 
    20.*gE1d13.*gE1d33.*gE2d11.^2.*gE2d31.^2.*gE2d33.^3 +  ... 
    20.*gE1d22.^2.*gE2d11.*gE2d13.*gE2d31.^2.*gE2d33.^3 -  ... 
    40.*gE1d13.*gE1d31.*gE2d11.*gE2d13.*gE2d31.^2.*gE2d33.^3 -  ... 
    40.*gE1d12.*gE1d32.*gE2d11.*gE2d13.*gE2d31.^2.*gE2d33.^3 -  ... 
    40.*gE1d11.*gE1d33.*gE2d11.*gE2d13.*gE2d31.^2.*gE2d33.^3 +  ... 
    40.*gE1d02.*gE1d42.*gE2d11.*gE2d13.*gE2d31.^2.*gE2d33.^3 -  ... 
    20.*gE1d11.*gE1d31.*gE2d13.^2.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d13.*gE1d22.*gE2d13.*gE2d20.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d33.*gE2d13.*gE2d20.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d12.*gE1d22.*gE2d13.*gE2d21.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d32.*gE2d13.*gE2d21.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d13.*gE1d22.*gE2d11.*gE2d22.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d33.*gE2d11.*gE2d22.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d11.*gE1d22.*gE2d13.*gE2d22.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d31.*gE2d13.*gE2d22.*gE2d31.^2.*gE2d33.^3 +  ... 
    10.*gE1d02.*gE1d22.*gE2d22.^2.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d12.*gE1d22.*gE2d11.*gE2d23.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d32.*gE2d11.*gE2d23.*gE2d31.^2.*gE2d33.^3 +  ... 
    20.*gE1d02.*gE1d22.*gE2d21.*gE2d23.*gE2d31.^2.*gE2d33.^3 -  ... 
    10.*gE1d11.*gE1d22.*gE2d11.*gE2d24.*gE2d31.^2.*gE2d33.^3 +  ... 
    30.*gE1d02.*gE1d31.*gE2d11.*gE2d24.*gE2d31.^2.*gE2d33.^3 +  ... 
    20.*gE1d02.*gE1d22.*gE2d20.*gE2d24.*gE2d31.^2.*gE2d33.^3 +  ... 
    20.*gE1d13.^2.*gE2d11.*gE2d31.^3.*gE2d33.^3 +  ... 
    20.*gE1d12.^2.*gE2d13.*gE2d31.^3.*gE2d33.^3 +  ... 
    40.*gE1d11.*gE1d13.*gE2d13.*gE2d31.^3.*gE2d33.^3 -  ... 
    40.*gE1d02.*gE1d22.*gE2d13.*gE2d31.^3.*gE2d33.^3 -  ... 
    20.*gE1d02.*gE1d13.*gE2d22.*gE2d31.^3.*gE2d33.^3 -  ... 
    20.*gE1d02.*gE1d12.*gE2d23.*gE2d31.^3.*gE2d33.^3 -  ... 
    20.*gE1d02.*gE1d11.*gE2d24.*gE2d31.^3.*gE2d33.^3 +  ... 
    gE1d32.^2.*gE2d11.^3.*gE2d33.^4 + 2.*gE1d31.*gE1d33.*gE2d11.^3.*gE2d33.^4 -  ... 
    2.*gE1d22.*gE1d42.*gE2d11.^3.*gE2d33.^4 +  ... 
    3.*gE1d31.^2.*gE2d11.^2.*gE2d13.*gE2d33.^4 -  ... 
    gE1d22.*gE1d33.*gE2d11.^2.*gE2d20.*gE2d33.^4 +  ... 
    3.*gE1d13.*gE1d42.*gE2d11.^2.*gE2d20.*gE2d33.^4 -  ... 
    2.*gE1d22.*gE1d31.*gE2d11.*gE2d13.*gE2d20.*gE2d33.^4 +  ... 
    6.*gE1d11.*gE1d42.*gE2d11.*gE2d13.*gE2d20.*gE2d33.^4 +  ... 
    gE1d13.*gE1d33.*gE2d11.*gE2d20.^2.*gE2d33.^4 +  ... 
    gE1d13.*gE1d31.*gE2d13.*gE2d20.^2.*gE2d33.^4 +  ... 
    gE1d12.*gE1d32.*gE2d13.*gE2d20.^2.*gE2d33.^4 +  ... 
    gE1d11.*gE1d33.*gE2d13.*gE2d20.^2.*gE2d33.^4 -  ... 
    4.*gE1d02.*gE1d42.*gE2d13.*gE2d20.^2.*gE2d33.^4 -  ... 
    gE1d22.*gE1d32.*gE2d11.^2.*gE2d21.*gE2d33.^4 +  ... 
    3.*gE1d12.*gE1d42.*gE2d11.^2.*gE2d21.*gE2d33.^4 +  ... 
    2.*gE1d13.*gE1d32.*gE2d11.*gE2d20.*gE2d21.*gE2d33.^4 +  ... 
    2.*gE1d12.*gE1d33.*gE2d11.*gE2d20.*gE2d21.*gE2d33.^4 +  ... 
    2.*gE1d12.*gE1d31.*gE2d13.*gE2d20.*gE2d21.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d32.*gE2d13.*gE2d20.*gE2d21.*gE2d33.^4 +  ... 
    gE1d13.*gE1d31.*gE2d11.*gE2d21.^2.*gE2d33.^4 +  ... 
    gE1d12.*gE1d32.*gE2d11.*gE2d21.^2.*gE2d33.^4 +  ... 
    gE1d11.*gE1d33.*gE2d11.*gE2d21.^2.*gE2d33.^4 -  ... 
    4.*gE1d02.*gE1d42.*gE2d11.*gE2d21.^2.*gE2d33.^4 +  ... 
    gE1d11.*gE1d31.*gE2d13.*gE2d21.^2.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d33.*gE2d20.*gE2d21.^2.*gE2d33.^4 -  ... 
    gE1d02.*gE1d32.*gE2d21.^3.*gE2d33.^4 -  ... 
    gE1d22.*gE1d31.*gE2d11.^2.*gE2d22.*gE2d33.^4 +  ... 
    3.*gE1d11.*gE1d42.*gE2d11.^2.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d13.*gE1d31.*gE2d11.*gE2d20.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d12.*gE1d32.*gE2d11.*gE2d20.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d33.*gE2d11.*gE2d20.*gE2d22.*gE2d33.^4 -  ... 
    8.*gE1d02.*gE1d42.*gE2d11.*gE2d20.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d31.*gE2d13.*gE2d20.*gE2d22.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d33.*gE2d20.^2.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d12.*gE1d31.*gE2d11.*gE2d21.*gE2d22.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d32.*gE2d11.*gE2d21.*gE2d22.*gE2d33.^4 -  ... 
    6.*gE1d02.*gE1d32.*gE2d20.*gE2d21.*gE2d22.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d31.*gE2d21.^2.*gE2d22.*gE2d33.^4 +  ... 
    gE1d11.*gE1d31.*gE2d11.*gE2d22.^2.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d31.*gE2d20.*gE2d22.^2.*gE2d33.^4 +  ... 
    2.*gE1d12.*gE1d31.*gE2d11.*gE2d20.*gE2d23.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d32.*gE2d11.*gE2d20.*gE2d23.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d32.*gE2d20.^2.*gE2d23.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d31.*gE2d11.*gE2d21.*gE2d23.*gE2d33.^4 -  ... 
    6.*gE1d02.*gE1d31.*gE2d20.*gE2d21.*gE2d23.*gE2d33.^4 +  ... 
    2.*gE1d11.*gE1d31.*gE2d11.*gE2d20.*gE2d24.*gE2d33.^4 -  ... 
    3.*gE1d02.*gE1d31.*gE2d20.^2.*gE2d24.*gE2d33.^4 +  ... 
    5.*gE1d22.^2.*gE2d11.^2.*gE2d31.*gE2d33.^4 -  ... 
    10.*gE1d13.*gE1d31.*gE2d11.^2.*gE2d31.*gE2d33.^4 -  ... 
    10.*gE1d12.*gE1d32.*gE2d11.^2.*gE2d31.*gE2d33.^4 -  ... 
    10.*gE1d11.*gE1d33.*gE2d11.^2.*gE2d31.*gE2d33.^4 +  ... 
    10.*gE1d02.*gE1d42.*gE2d11.^2.*gE2d31.*gE2d33.^4 -  ... 
    20.*gE1d11.*gE1d31.*gE2d11.*gE2d13.*gE2d31.*gE2d33.^4 -  ... 
    5.*gE1d13.*gE1d22.*gE2d11.*gE2d20.*gE2d31.*gE2d33.^4 +  ... 
    15.*gE1d02.*gE1d33.*gE2d11.*gE2d20.*gE2d31.*gE2d33.^4 -  ... 
    5.*gE1d11.*gE1d22.*gE2d13.*gE2d20.*gE2d31.*gE2d33.^4 +  ... 
    15.*gE1d02.*gE1d31.*gE2d13.*gE2d20.*gE2d31.*gE2d33.^4 -  ... 
    5.*gE1d12.*gE1d22.*gE2d11.*gE2d21.*gE2d31.*gE2d33.^4 +  ... 
    15.*gE1d02.*gE1d32.*gE2d11.*gE2d21.*gE2d31.*gE2d33.^4 +  ... 
    5.*gE1d02.*gE1d22.*gE2d21.^2.*gE2d31.*gE2d33.^4 -  ... 
    5.*gE1d11.*gE1d22.*gE2d11.*gE2d22.*gE2d31.*gE2d33.^4 +  ... 
    15.*gE1d02.*gE1d31.*gE2d11.*gE2d22.*gE2d31.*gE2d33.^4 +  ... 
    10.*gE1d02.*gE1d22.*gE2d20.*gE2d22.*gE2d31.*gE2d33.^4 +  ... 
    15.*gE1d12.^2.*gE2d11.*gE2d31.^2.*gE2d33.^4 +  ... 
    30.*gE1d11.*gE1d13.*gE2d11.*gE2d31.^2.*gE2d33.^4 -  ... 
    30.*gE1d02.*gE1d22.*gE2d11.*gE2d31.^2.*gE2d33.^4 +  ... 
    15.*gE1d11.^2.*gE2d13.*gE2d31.^2.*gE2d33.^4 -  ... 
    15.*gE1d02.*gE1d13.*gE2d20.*gE2d31.^2.*gE2d33.^4 -  ... 
    15.*gE1d02.*gE1d12.*gE2d21.*gE2d31.^2.*gE2d33.^4 -  ... 
    15.*gE1d02.*gE1d11.*gE2d22.*gE2d31.^2.*gE2d33.^4 +  ... 
    35.*gE1d02.^2.*gE2d31.^3.*gE2d33.^4 - 2.*gE1d11.*gE1d31.*gE2d11.^2.*gE2d33.^5 -  ... 
    gE1d11.*gE1d22.*gE2d11.*gE2d20.*gE2d33.^5 +  ... 
    3.*gE1d02.*gE1d31.*gE2d11.*gE2d20.*gE2d33.^5 +  ... 
    gE1d02.*gE1d22.*gE2d20.^2.*gE2d33.^5 + 6.*gE1d11.^2.*gE2d11.*gE2d31.*gE2d33.^5 -  ... 
    6.*gE1d02.*gE1d11.*gE2d20.*gE2d31.*gE2d33.^5) ; 
