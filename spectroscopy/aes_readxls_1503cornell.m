function xlsdata = aes_readxls_1503cornell(xlsfile, varargin)
%
% Note that much of the data format is assumed, and a structure is
% returned. Default parameters are:
%     row_atomnames = 1;
%     row_datastart = 3;
%     col_samnames = 5;
%     col_samx = 6;
%     col_datastart = 7;
%
% It appears that the following ions are usable:
% 1) Co 228.616; Co 230.786 (about the same)
% 2) K 404.721
% 3) Na 589.592; Na 588.995
% 4) Cl 136.345
% 5) P 178.287; P 177.495; P 213.618; P 214.914
% 6) Mg 285.213; Mg 279.079
% 7) 
%   
%   i_Co = find(strncmpi('Co 228', ionnames, 6),1)
%   i_K = find(strncmpi('K 404', ionnames, 5),1)
%   i_Na = find(strncmpi('Na 589', ionnames, 6),1)
%   i_Cl = find(strncmpi('Cl 136', ionnames, 6),1)
%   i_P = find(strncmpi('P 178', ionnames, 5),1)
%   i_Mg = find(strncmpi('Mg 279', ionnames, 6),1)

row_atomnames = 1;
row_datastart = 3;
col_samnames = 5;
col_samx = 6;
col_datastart = 7;
verbose = 0;

parse_varargin(varargin);

[numeric, xlstxt, raw] = xlsread(xlsfile);
%
xlsdata.atomnames = strtrim(xlstxt(row_atomnames, col_datastart: end));
for i=1:length(xlsdata.atomnames)
    showinfo(['Processing atom name: ' xlsdata.atomnames{i}]);
    if isempty(xlsdata.atomnames{i})
        showinfo(['No atom name found for col: ' num2str(i+col_datastart-1)]);
        continue
    end
    
    xlsdata.atoms{i} = strtrim(strrep(xlsdata.atomnames{i}(1:2), '_', ''));
    xlsdata.wavenum(i) = str2num(strrep(xlsdata.atomnames{i}(3:end), ...
                                        '_', '0'));
end

atomprop = atomdb_getproperty(xlsdata.atoms, 'sas',0, 'const',1);
xlsdata.atommass = [atomprop.mass];

xlsdata.samnames = xlstxt(row_datastart:end,col_samnames);
xlsdata.samx = cell2mat(raw(row_datastart:end,col_samx));
xlsdata.data = cell2mat(raw(row_datastart:end,col_datastart:end));

% this gives the concentration in mM (assuming the solvent density is
% 1kg/liter.
xlsdata.concen = xlsdata.data ./ repmat(xlsdata.atommass, ...
                                        length(xlsdata.samnames),1);
