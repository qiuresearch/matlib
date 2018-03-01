function CalCoeff()

global Ecoefficient
global d1Factor
global d2Factor

Ecoefficient(1)=E1d20   * 0;
Ecoefficient(2)=E1d11;
Ecoefficient(3)=E1d21   * 0;
Ecoefficient(4)=E1d31;
Ecoefficient(5)=E1d02;
Ecoefficient(6)=E1d12;
Ecoefficient(23)=E1d22;
Ecoefficient(24)=E1d32;
Ecoefficient(7)=E1d42;
Ecoefficient(8)=E1d13;
Ecoefficient(9)=E1d23   * 0;
Ecoefficient(10)=E1d33;
Ecoefficient(11)=E1d24  * 0;

Ecoefficient(12)=E2d20;
Ecoefficient(13)=E2d11;
Ecoefficient(14)=E2d21;
Ecoefficient(15)=E2d31;
Ecoefficient(16)=E2d02  * 0;
Ecoefficient(17)=E2d12  * 0;
Ecoefficient(25)=E2d22;
Ecoefficient(26)=E2d32  * 0;
Ecoefficient(18)=E2d42  * 0;
Ecoefficient(19)=E2d13;
Ecoefficient(20)=E2d23;
Ecoefficient(21)=E2d33;
Ecoefficient(22)=E2d24;

Ecoefficient(1)=Ecoefficient(1) .* d1Factor^2 * 1;
Ecoefficient(2)=Ecoefficient(2) .* d1Factor .* d2Factor;
Ecoefficient(3)=Ecoefficient(3) .* d1Factor^2 .* d2Factor;
Ecoefficient(4)=Ecoefficient(4) .* d1Factor^3 .* d2Factor;
Ecoefficient(5)=Ecoefficient(5) .* 1 .* d2Factor^2;
Ecoefficient(6)=Ecoefficient(6) .* d1Factor^1 .* d2Factor^2;
Ecoefficient(23)=Ecoefficient(23).* d1Factor^2 .* d2Factor^2;
Ecoefficient(24)=Ecoefficient(24).* d1Factor^3 .* d2Factor^2;
Ecoefficient(7)=Ecoefficient(7) .* d1Factor^4 .* d2Factor^2;
Ecoefficient(8)=Ecoefficient(8) .* d1Factor^1 .* d2Factor^3;
Ecoefficient(9)=Ecoefficient(9) .* d1Factor^2 .* d2Factor^3;
Ecoefficient(10)=Ecoefficient(10).* d1Factor^3 .* d2Factor^3;
Ecoefficient(11)=Ecoefficient(11).* d1Factor^2 .* d2Factor^4;

Ecoefficient(12)=Ecoefficient(12).* d1Factor^2 .* 1;
Ecoefficient(13)=Ecoefficient(13).* d1Factor^1 .* d2Factor^1;
Ecoefficient(14)=Ecoefficient(14).* d1Factor^2 .* d2Factor^1;
Ecoefficient(15)=Ecoefficient(15).* d1Factor^3 .* d2Factor^1;
Ecoefficient(16)=Ecoefficient(16).* 1 .* d2Factor^2;
Ecoefficient(17)=Ecoefficient(17).* d1Factor^1 .* d2Factor^2;
Ecoefficient(25)=Ecoefficient(25).* d1Factor^2 .* d2Factor^2;
Ecoefficient(26)=Ecoefficient(26).* d1Factor^3 .* d2Factor^2;
Ecoefficient(18)=Ecoefficient(18).* d1Factor^4 .* d2Factor^2;
Ecoefficient(19)=Ecoefficient(19).* d1Factor^1 .* d2Factor^3;
Ecoefficient(20)=Ecoefficient(20).* d1Factor^2 .* d2Factor^3;
Ecoefficient(21)=Ecoefficient(21).* d1Factor^3 .* d2Factor^3;
Ecoefficient(22)=Ecoefficient(22).* d1Factor^2 .* d2Factor^4;

