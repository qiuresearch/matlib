function [scatlenden, scatlen, volume] = residuedb_calcscatlen(sequence)
% --- Usage:
%        scatlen = residuedb_calcscatlen(var)
%
% --- Purpose:
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: residuedb_calcscatlen.m,v 1.1 2008-11-04 19:20:20 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
scatlen = [0;0];
volume = [0;0];

global residuedb_isvalid residuedb_sym_short residuedb_sym_long ...
    residuedb_sym_full residuedb_sas
if isempty(residuedb_isvalid) || (residuedb_isvalid ~= 1)
   residuedb_initialize;
end


% lysozyme
sequence = 'KVFGRCELAAAMKRHGLDNYRGYSLGNWVCAAKFESNFNTQATNRNTDGSTDYGILQINSRWWCNDGRTPGSRNLCNIPCSALLSSDITASVNCAKKIVSDGNGMNAWVAWRNRCKGTDVQAWIRGCRL';

% lambda gpD protein
sequence = ['MTSKETFTHY QPQGNSDPAH TATAPGGLSA KAPAMTPLML DTSSRKLVAW ' ...
            'DGTTDGAAVG ILAVAADQTS TTLTFYKSGT FRYEDVLWPE AASDETKKRT ' ...
             'AFAGTAISIV']; 

% lambda gpE
sequence = ['MSMYTTAQLLAANEQKFKFDPLFLRLFFRESYPFTTEKVYLSQIPGLVNMALYVSPIVSG' ...
            'EVIRSRGGSTSEFTPGYVKPKHEVNPQMTLRRLPDEDPQNLADPAYRRRRIIMQNMRDEE' ...
            'LAIAQVEEMQAVSAVLKGKYTMTGEAFDPVEVDMGRSEENNITQSGGTEWSKRDKSTYDP' ...
            'TDDIEAYALNASGVVNIIVFDPKGWALFRSFKAVKEKLDTRRGSNSELETAVKDLGKAVS' ...
            'YKGMYGDVAIVVYSGQYVENGVKKNFLPDNTMVLGNTQARGLRTYGCIQDADAQREGINA' ...
            'SARYPKNWVTTGDPAREFTMIQSAPLMLLADPDEFVSVQLA'];

% lambda gpJ
sequence = ['MKFVIRDLVQQLCTKYNTTNPYELADYLKINVLTWDLHEEINGFYKYEKRNRFIVINNHL' ...
            'SPSMQRTVCAHELGHAILHTHANTPFLRKNTFFSVDKLEIEANTFAALLLIDKKTIQPGD' ...
            'TKACIAYKNDIPVELLEFYKPY'];

% the 20 amino acids
sequence = 'GGAVLIFYWDESTNQKRHMCP';


sequence = 'ISPLGSVTKKNQDSTAYNWTGNKTANGNWPVLGICAVHRKKDIGGSGNSPVIPFGTTLKTDKDIWLPDGVGYKSSFNVDDTGSGPKKTDYWIDIYYSKDTKAAINYGVVKLSYTYST';


for ii=1:length(sequence)
   jj = strmatch(sequence(ii), residuedb_sym_short);
   if isempty(jj)
      showinfo(['Residue "' sequence(ii) '" not found in database!']);
      continue
   end
   if (length(jj) > 1)
      showinfo([num2str(length(jj)) ' matches found for ' sequence(ii)]);
      jj = jj(1);
   end
   resname = lower(residuedb_sym_full{jj});
   scatlen = scatlen + residuedb_sas.(resname).scatlen([1,2],1);
   volume = volume + residuedb_sas.(resname).scatlen([1,2], 4);
   
%   residuedb_sas.(resname).scatlen(2,1)/residuedb_sas.(resname).scatlen(2,4)
end
scatlenden = scatlen./volume*100;
D2O_ratio = (scatlenden(1)+0.5702)/(6.403+0.5702-scatlenden(2)+scatlenden(1));
showinfo(['Scattering length density is (10^-6/A^2): ' num2str(scatlenden'), ...
         ' matched at ' num2str(D2O_ratio*100) '% D2O']);