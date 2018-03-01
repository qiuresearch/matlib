function const = fl_cell2struct(fl_const)
% --- Usage:
%        result = conv_gauss(y, width_gauss)
% --- Purpose:
%        convert a femlab style cell to a sturcture
%

if (nargin < 1) || isempty(fl_const)
   help fl_cell2struct
   return
end

% 
const = [];
for i=1:2:length(fl_const)
   const = setfield(const, fl_const{i}, str2num(fl_const{i+1}));
end
