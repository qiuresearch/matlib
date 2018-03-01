function pc=whichpc
%WHICHPC   returns name of the current PC, which can be
%          'COMPAQ315', 'DELL325' or 'GATEWAY325'

%pc='COMPAQ315';
if ispc
    pc=getenv('COMPUTERNAME');
elseif isunix
    pc=getenv('HOSTNAME');
end
