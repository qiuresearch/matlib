function minmax_install
% function minmax_install
% Installation by building the C-mex files for min/max selection package
%
% Author Bruno Luong <brunoluong@yahoo.com>
% Last update: 29-Jun-2009 built inplace functions

arch=computer('arch');
mexopts = {'-v' '-O' ['-' arch]};
% 64-bit platform
if ~isempty(strfind(computer(),'64'))
    mexopts(end+1) = {'-largeArrayDims'};
end

if ispc()
    compiler = getmexopts('COMPILER');
    islcc = strcmpi(compiler,'lcc');
    % Define the C-symbol for LCC compiler
    if islcc
        mexopts(end+1) = {'-D_LCC'};
    end
end

% Internal representation of mxArray
buildInternal_mxArrayDef('Internal_mxArray.h');

% Inplace tool
mex(mexopts{:},'inplacecolumnmex.c');
mex(mexopts{:},'releaseinplace.c');

% Mex MIN/MAX functions
mex(mexopts{:},'minkmex.c');
mex(mexopts{:},'maxkmex.c');
