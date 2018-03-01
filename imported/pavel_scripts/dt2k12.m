function dt2=dt2k12(th2)
%DT2K12    calculates CuK1, CuK2 dublet distance in 2 TH
%    DTH2=DT2K12(TH2)

Ka1=phconst('cuka1');
Ka2=phconst('cuka2');
dl=Ka2-Ka1;
dt2=2*180/pi*tan(th2/2*pi/180)*dl/Ka1;
