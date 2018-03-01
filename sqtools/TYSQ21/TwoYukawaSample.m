close all;
clear all;

warning off;

%Debug information
%
%global debugFlag
%debugFlag = 1

%Potential From: V(r)/(kB*T)=-K1*exp(-Z1*r)/r - K2*exp(-Z2*r)/r
%kB: Boltzman constant
%T: Absolute temperature
%The hardcore diameter is assumed to be one

Z1=10;
Z2=2;
K1=6;           %Attraction
K2=-1;          %Repulsion

%Volume Fraction
volF=0.2;

%Please give your Q range, the maximum Q should be larger than 700 to let
%the program to run.
%(The reason is : we have to use g(r) to select the right result. Therefore
%large Q range can make g(r) better.
Q=(0:0.005:16*10)*2*pi;

[calSk,rootCounter,calr,calGr,errorCode]=CalTYSk(Z1,Z2,K1,K2,volF,Q);

%Plot structure factor S(Q)
plot(Q,calSk,'bo');
axis([0,20,0,inf]);

%Plot the pair distribution function g(r)
figure
plot(calr, calGr,'bo-');
axis([0,10,-inf,inf]);
