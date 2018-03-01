function rdiary(FILENAME__)
%RDIARY    function for executing diary file
%   RDIARY MFILE  execute diary MFILE

FILEID__=fopen(FILENAME__, 'r');
STR__=char(fread(FILEID__, [1 Inf], 'char'));
fclose(FILEID__);
STR__(findstr(STR__, sprintf('\r')))='';
I__=[0 findstr(STR__, sprintf('\n'))];
for K__=1:length(I__)-1
   ES__=[STR__(I__(K__)+1 : I__(K__+1)-1) ';'];
   if length(ES__)>=4
      YES__=~all(ES__(1:4)=='help');
   end
   if ES__(1)~=9 & ES__(1)~=7 & YES__
      evalin('base', ES__, '');
   end
end
