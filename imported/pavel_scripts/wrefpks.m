function wrefpks(sref)
%WREFPKS   save refined pks structure to ../pavol/data/ref_pks.mat
%   Usage: WREFPKS(S) or WREFPKS S
%   retrieve the data through RPKS(file, 'ref');
%
%See also REFPKS, RPKS

%   2001 by Pavol

matname=[pjtbxdir('data') '/ref_pks.mat'];
if isstr(sref)
    sref=evalin('caller', sref);
end

%double check
if ~isfield(sref, 'icps') | ~isfield(sref, 'fwhm')
    error('Input argument is not PKS structure')
end

%build the variable name
[ignore, vn]=fileparts(sref.fname);
vn=['fp' lower(vn)];
eval([vn '=sref;'])
if exist(matname, 'file')
    save(matname, vn, '-append')
else
    save(matname, vn)
end
