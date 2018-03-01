function gnom = gnom_loadout(file_gnomout)
% --- Usage:
%        gnom = gnom_loadout(file_gnomout)
% --- Purpose:
%        read the output file from program GNOM into a structure
% --- Parameter(s):
%        file_gnomout - the GNOM output file name
% --- Return(s):
%        gnom - a structure
%
% --- Example(s):
%
% $Id: gnom_loadout.m,v 1.10 2015/09/26 15:35:56 schowell Exp $
%

if (nargin < 1) || isempty(file_gnomout)
   help gnom_loadout
   return
end

% read file
fid = fopen(file_gnomout, 'r');
outdata = fread(fid);
fclose(fid);
% bindata
% \n: 10 \r: 13
% Remove the Carriage returns
outdata = strsplit(char(outdata'), sprintf('\n'));
outdata(:) = strtrim(outdata);

% get the title
index = strmatch('Run title:', outdata);
if (length(index) == 1)
   gnom.title = strtrim(outdata{index}(11:end));
end

% get the file name
% index = strmatch('******* ', outdata);
index = strmatch('*******    Input file(s)' ,outdata);
if (length(index) == 1)
   tokens = strsplit(outdata{index}, ': ');
   [gnom.filedir, gnom.filename, gnom.filesuffix] = fileparts(tokens{2});
end

% get parameters (the same structures are assumed)
index = strmatch('Parameter ', outdata);
if (length(index) == 1)
   gnom.parameter = strsplit(outdata{index}(10:end), ' ');
   gnom.weight = str2num(outdata{index+1}(7:end));
   gnom.simga = str2num(outdata{index+2}(6:end));
   gnom.ideal = str2num(outdata{index+3}(6:end));
   gnom.current = str2num(outdata{index+4}(8:end));
   gnom.estimate = str2num(outdata{index+6}(9:end));
   tokens = strsplit(outdata{index+9}, ' ');
   gnom.alpha_max = str2num(tokens{5});
   tokens = strsplit(outdata{index+10}, ' ');
   gnom.alpha = str2num(tokens{4});
   gnom.rg = str2num(tokens{7});
   gnom.i0 = str2num(tokens{10});
   tokens = strsplit(outdata{index+11}, ' ');
   gnom.total_estimate = str2num(tokens{4});
else
  warning('More than one matches, check it out!');
  index = index(end);
end

% get the I(S)
index = strmatch('S ', outdata);

if (length(index) ~= 1)
  warning('More than one matches, check it out!');
  index = index(end);
end

% also get the first several lines without experimental data
for k=(index+1):length(outdata)
   data = str2num(outdata{k});
   switch length(data)
      case 5
         iqdata(k-index,:) = data;
      case 2
         iqdata(k-index,1) = data(1);
         iqdata(k-index,2:4) = NaN;
         iqdata(k-index,5) = data(2);
      case 0
         break;
   end
end

% remove rows of data containing NaN
iqdata = iqdata(not(any(isnan(iqdata),2)),:);

gnom.iq_colnames = {'Q', 'IQ_exp', 'IQ_err', 'IQ_fit', 'IQ_fit2'};
gnom.iq = iqdata;
inans = find(isnan(iqdata(:,3)));
iqdata(inans,:) = [];
gnom.chi2 = sqrt(total(((iqdata(:,4)-iqdata(:,2))./iqdata(:,3)).^2)/ ...
                 (length(iqdata(:,1)) -1));

% get the P(R)

index = strmatch('R ', outdata);
if (length(index) ~= 1)
  warning('More than one matches, check it out!');
  index = index(end)
end

for i=(index+1):(length(outdata)-2)
  prdata(i-index,:) = str2num(outdata{i});
end
gnom.pr_colnames = {'r', 'Pr', 'Pr_err'};
gnom.pr = prdata;

% get the Rg and I0 from the last line 
tokens = strsplit(outdata{end}, ' ');
if length(tokens) > 10
   gnom.rg = [str2num(tokens{5}), str2num(tokens{7})];
   gnom.i0 = [str2num(tokens{end-2}), str2num(tokens{end})];
end

% normalize the area to one
factor = sum(gnom.pr(:,2))*(gnom.pr(2,1)- gnom.pr(1,1));
gnom.pr(:,2:end) = gnom.pr(:,2:end)/factor;
