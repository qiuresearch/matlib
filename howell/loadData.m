function [E2,counts,ncounts,livetime,realtime,dE] = loadData(filnam)
% filnam='C:\User\data10\1002\24Feb\Bk_73.spe'
% nfil=73;
% [E,C,Ctot,livetm,realtm] = asc_ortec_sdata(filnam);
%
% read formated ascii from gammavision  .txtu files
% create conts vs energy bin waveforms
% disp(['opening asc file ',filnam])
% clear; close all;clc;
% filnam='E:\User\HPGe\Data 10\1002\Checking Cal\Ba133calCheck.Spe';
origFile=filnam;e=exist(filnam);
k=1;
global Nfil
while e==0
    loc=findstr(filnam,[num2str(Nfil),'.']);
    sFilnam=size(filnam);
    filnam=[filnam(1:loc-1),'0',filnam(loc:sFilnam(2))];
    e=exist(filnam);k=k+1;
    if k>10;break;end
end
fid=fopen([filnam]);
if fid==-1
    disp('                                  ');
    disp('Could not find the file specified.')
    disp('There is an error in the filname.');
    disp('Either the file does not exist or the name is incorrect.');
    disp(['Matlab tried opening: ',origFile,]);
    disp([' through ',filnam]);
    disp('                                  ');
end

line=0;
n=0;
while line>=0
    n=n+1;
    line=fgetl(fid);
    if strcmp(line,'$SPEC_ID:')
        SpecID=fgetl(fid);
    elseif strcmp(line,'$DATE_MEA:')
        line=fgetl(fid);
        aqDate=line(1:10);
        aqTime=line(11:18);
    elseif strcmp(line,'$MEAS_TIM:')
        line=fgetl(fid);
        time_l_r= sscanf((line),'%i');
                livetime=time_l_r(1,1);
                realtime=time_l_r(2,1);
        deadtime=(time_l_r(2,1)-time_l_r(1,1))/time_l_r(2,1)*100;
        % disp(['...dead time  ',num2str(deadtime),' %'])
    elseif strcmp(line,'$DATA:')
        line=fgetl(fid);
        num_b_e= sscanf((line),'%i');
        counts=zeros(num_b_e(2)+1,1);
%         for i=1:num_b_e(2)+1
%             counts(i)=str2num(fgetl(fid));
%             E(i)=i;
%         end
        counts = fscanf(fid,'%i',num_b_e(2)+1);
        line=fgetl(fid);
        line=fgetl(fid);
        n=n+num_b_e(2);
    elseif strcmp(line,'$ROI:')
        numROI=str2num(fgetl(fid));
        ROIs=zeros(numROI,2);
        for R=1:numROI
            ROIs(R,:)=str2num(fgetl(fid));
        end
    elseif strcmp(line,'$ENER_FIT:')
        delta_e=str2num(fgetl(fid));
        E1 = ((1:length(counts)) * delta_e(2))+delta_e(1);
    elseif strcmp(line,'$MCA_CAL:')
        line=fgetl(fid);
        mcaCal=str2num(fgetl(fid));
        E2 = mcaCal(1)+mcaCal(2)*(1:length(counts))+mcaCal(3)*(1:length(counts)).^2;
    elseif strcmp(line,'$SHAPE_CAL:')
        line=fgetl(fid);
        shapeCal=str2num(fgetl(fid));
        E3 = shapeCal(1)+shapeCal(2)*(1:length(counts))+shapeCal(3)*(1:length(counts)).^2;
    end
end
fclose(fid);

dE=mcaCal(2);
%     dE= delta_e(2);  %If you get this error:
    %   "??? Attempted to access delta_e(2); index out of bounds because numel(delta_e)=0."
    %   Check that the last few lines of the data file has 14 lines.  If it
    %   does not then the loop in line 44-49 will be incorrect and delta_e
    %   doesn't have the right energy fit data.
    % disp(delta_e)

     %E=E*1000;

    %E(1:5)
    %disp([num2str(delta_e(1)),' ',num2str(delta_e(2))])
    %pause
    %   lf=length(filnam);disp(['...data red ',filnam(lf-18:lf-4)])

    ncounts=sum(counts);
    %     for i=1:num_b_e(2)+1
    %         ncounts=ncounts+counts(i);
    %     end
    %disp(['...total # counts = ',num2str(ncounts)])

    % figure
    %  semilogy(counts)
    %  ylabel('counts'),grid on
    %  title([' ',tit])
    %  xlabel('Energy(eV)')
% clear global Nfil