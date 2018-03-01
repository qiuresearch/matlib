function [myRd1Root,myRd2Root]=CalRealRoot()

global z
global k
global phi

global Ecoefficient

%tic

%z(1)=1.8;
%z(2)=3.0;
%k(1)=1.5*exp(z(1));
%k(2)=-1.5*exp(z(2));
%phi=0.2;

%CalCoeff;

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


d2Coeff=[polyd2_25,polyd2_24,polyd2_23,polyd2_22,polyd2_21,polyd2_20, ...
         polyd2_19,polyd2_18,polyd2_17,polyd2_16,polyd2_15,polyd2_14,polyd2_13,polyd2_12,polyd2_11,polyd2_10,...
         polyd2_09,polyd2_08,polyd2_07,polyd2_06,polyd2_05,polyd2_04,polyd2_03,polyd2_02];
%d2Coeff=fliplr(d2Coeff);

N=length(d2Coeff);

Factor = 1;%20;
FactorArray=zeros(1,N);
for i=1:N

    FactorArray=FactorArray*Factor;
    FactorArray(i)=1;
end

d2Coeff_factor=d2Coeff.*FactorArray;

myd2Root_factor=roots(d2Coeff_factor);

myd2Root=myd2Root_factor.*Factor;

kk=1;
for i=1:length(myd2Root)
    if imag(myd2Root(i))==0
        
        d2=myd2Root(i);
        
        %Coeff of Equation 2
        ycoe22=gE2d31.*d2+gE2d33.*d2.^3;
        ycoe21=gE2d20+gE2d21.*d2+gE2d22.*d2.^2+gE2d23.*d2.^3+gE2d24.*d2.^4;
        ycoe20=gE2d11.*d2+gE2d13*d2.^3;

        if ycoe22==0
            temp(1)=0;
            temp(2)=NaN;
            
        else
            temp(1)=(-ycoe21+sqrt(ycoe21.^2-4*ycoe22.*ycoe20))./(2*ycoe22);
            temp(2)=(-ycoe21-sqrt(ycoe21.^2-4*ycoe22.*ycoe20))./(2*ycoe22);
        end


        if imag(temp(1))==0 %& temp(1)~=0
           myRd2Root(kk)=myd2Root(i);  
           myRd1Root(kk,1)=NaN;
           myRd1Root(kk,2)=NaN;
           j=1;
           for i=1:2
                
                d2=myRd2Root(kk);
                
                d1=temp(i);
                
            %Coeff of Equation 1
                ycoe14=gE1d42.*d2;
                ycoe13=gE1d31+gE1d32.*d2+gE1d33.*d2.^2;
                ycoe12=gE1d22.*d2;
                ycoe11=gE1d11+gE1d12.*d2+gE1d13.*d2.^2;
                ycoe10=gE1d02.*d2;
               
                %if abs(ycoe14*d1.^4+ycoe13*d1.^3+ycoe12*d1.^2+ycoe11*d1+ycoe10) < 1e-5
                %ycoe14*d1.^2+ycoe13*d1.^1+ycoe12+ycoe11/d1+ycoe10/d1.^2
                if abs(ycoe14*d1.^2+ycoe13*d1.^1+ycoe12+ycoe11/d1+ycoe10/d1.^2) < 1e-5
                    myRd1Root(kk,j)=d1;
                    j=j+1;
                end
            end
            kk=kk+1;
        end
    end
end

myRd1Root=myRd1Root';

%Check the roots
resi=0;
testRoot=myRd2Root(1);
for i=N:1
    resi=resi*testRoot+d2coeff(i);
end