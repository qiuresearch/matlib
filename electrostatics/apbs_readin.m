function sAPBS = apbs_readin(fname, varargin)
% --- Usage:
%        sAPBS = apbs_readin(fname, varargin)
% --- Purpose:
%        read the APBS input file to get some relevant information:
%        a) PQR file name, b) ions, c) dielectric constants, d)
%        temperature, etc
% --- Parameter(s):
%
% --- Return(s): 
%        sAPBS - the APBS data structure
%
% --- Example(s):
%
% $Id: apbs_readin.m,v 1.2 2012/06/16 16:43:24 xqiu Exp $
%

% 1) default settings and initialize some fields
verbose = 1;
parse_varargin(varargin)
if ~exist('fname', 'var')
   fname = 'apbs';
end
sAPBS.name = 'apbs';
sAPBS.mode = 'mg-auto';
sAPBS.mol = [];
sAPBS.ion = [];
sAPBS.dime = [1,1,1];

% 2) read it to cell array
showinfo(['read .in file: ' fname]);
apbsdata = cellarr_readascii(fname);

% remove comments and patch a space behind
i_pound = strfind(apbsdata, '#');
for i=1:length(i_pound)
   if ~isempty(i_pound{i})
      ip = i_pound{i};
      data = apbsdata{i};
      apbsdata{i} = data(1:ip(1)-1);
   end
   apbsdata{i} = [apbsdata{i} ' ']; % add a blank
end

% generate tokens
tokens = strsplit([apbsdata{:}], ' ');

% 3) parse the tokens
read_mode = 0;
elec_mode = 0;
prin_mode = 0;

ip = 1; % pointer to the current index
while (ip < length(tokens))
   % switch mode
   if (read_mode == 0) && (elec_mode == 0) && (prin_mode ==0)
      switch tokens{ip}
         case 'read'
            read_mode = 1;
         case 'elec'
            elec_mode = 1;
            % just case  "name" field is missing
            sAPBS.mode = tokens{ip+1}; 
         case 'print'
            prin_mode = 1;
         otherwise
      end
   end % if (read_mode == 0) && (elec_mode == 0) && (prin_mode ==0)
   
   if (read_mode == 1)
      switch tokens{ip}
         case 'mol'
            sAPBS.mol = [sAPBS.mol, struct('format', tokens{ip+1}, ...
                                           'fname', tokens{ip+2})];
            ip = ip + 2;
         case 'end'
            read_mode = 0;
         otherwise
      end
   end

   if (elec_mode == 1)
      switch tokens{ip}
         case 'name'   % NOTE: assuming mg mode just follows!!!
            sAPBS.name = tokens{ip+1};
            sAPBS.mode = tokens{ip+2};
            ip = ip + 2;
         case 'mol'
            sAPBS.mol_use = [];
            while ~isempty(str2num(tokens{ip+1}))
               sAPBS.mol_use = [ sAPBS.mol_use, str2num(tokens{ip+ 1})];
               ip = ip +1;
            end
         case 'dime'
            sAPBS.dime = [str2num(tokens{ip+1}), str2num(tokens{ip+2}), ...
                          str2num(tokens{ip+3})];
            ip = ip + 3;
         case 'grid'
            sAPBS.grid =  [str2num(tokens{ip+1}), str2num(tokens{ip+2}), ...
                           str2num(tokens{ip+3})];
            sAPBS.delta = diag(sAPBS.grid./(sAPBS.dime-1));
            sAPBS.volume = prod(sAPBS.grid);
            ip = ip + 3;
            
            sAPBS.mg_auto = 0;
         case 'fglen'
            sAPBS.fglen =  [str2num(tokens{ip+1}), str2num(tokens{ip+2}), ...
                            str2num(tokens{ip+3})];
            sAPBS.delta = diag(sAPBS.fglen./(sAPBS.dime-1));
            sAPBS.volume = prod(sAPBS.fglen);
            ip = ip + 3;
         case 'fgcent'
            if strcmpi(tokens{ip+1}, 'mol')
               sAPBS.fgcent = str2num(tokens{ip+2});
               ip = ip + 2;
            else
               sAPBS.fgcent =  [str2num(tokens{ip+1}), ...
                                str2num(tokens{ip+2}), str2num(tokens{ip+3})];
               ip = ip + 3;
            end
         case 'cglen'
            sAPBS.cglen =  [str2num(tokens{ip+1}), str2num(tokens{ip+2}), ...
                            str2num(tokens{ip+3})];
            ip = ip + 3;
         case 'cgcent'
            if strcmpi(tokens{ip+1}, 'mol')
               sAPBS.cgcent = str2num(tokens{ip+2});
               ip = ip + 2;
            else
               sAPBS.cgcent =  [str2num(tokens{ip+1}), ...
                                str2num(tokens{ip+2}), str2num(tokens{ip+3})];
               ip = ip + 3;
            end
         case 'npbe'
            sAPBS.npbe = 1;
         case 'lpbe'
            sAPBS.npbe = 0;
         case 'bcfl'
            sAPBS.bcfl = tokens{ip+1};
            ip = ip + 1;
         case 'ion'
            ion_names = {'RB', 'SR','NA', 'MG', 'CL'};
            if strcmpi('charge', tokens{ip+1})
               sAPBS.ion = [sAPBS.ion, struct('name', ion_names{end- ...
                                length(sAPBS.ion)}, 'z', ...
                                           str2num(tokens{ip+2}), ...
                                           'n', str2num(tokens{ip+4}), ...
                                           'r', str2num(tokens{ip+6}))];
               ip = ip+6;
            else
               sAPBS.ion = [sAPBS.ion, struct('name', ion_names{end- ...
                                length(sAPBS.ion)}, 'z', ...
                                           str2num(tokens{ip+1}), ...
                                           'n', str2num(tokens{ip+2}), ...
                                           'r', str2num(tokens{ip+3}))];
               ip = ip + 3;
            end
         case 'pdie'
            sAPBS.pdie = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'sdie'
            sAPBS.sdie = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'chgm'
            sAPBS.chgm = tokens{ip+1};
            ip = ip + 1;
         case 'srfm'
            sAPBS.srfm = tokens{ip+1};
            ip = ip + 1;
         case 'srad'
            sAPBS.srad = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'swin'
            sAPBS.swin = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'sdens'
            sAPBS.sdens = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'temp'
            sAPBS.T = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'gamma'
            sAPBS.gamma = str2num(tokens{ip+1});
            ip = ip + 1;
         case 'calcenergy'
            sAPBS.calcenergy = tokens{ip+1};
            ip = ip + 1;
         case 'calcforce'
            sAPBS.calcforce = tokens{ip+1};
            ip = ip + 1;
         case 'end'
            elec_mode = 0;
         otherwise
      end % switch tokens{ip}
   end
   ip = ip + 1;
end

return
