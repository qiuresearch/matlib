function [o_d,o_I,o_hkl] = raids(file);
%RAIDS     reads AIDS format of the PDF card
%   [D,I,HKL] = RAIDS(FILE)   reads data to vectors
%   raids -l	lists pdfcards in the current directory
%   S = RAIDS(file)   reads all data to a structure S with these fields:
%       d         d spacing
%       th2       2theta
%       irel      relative intensity
%       hkl       h k l
%       ID        PDF number
%       name      compound name
%       formula   chemical formula
%       CS        crystal system code
%       SG        space group
%       SGn       space group or aspect number
%       abcABG    cell parameters
%       V         volume of crystal data cell
%       MW        molecular weight
%       Dx        calculated density
%       Dm        measured density
%
%See also LAIDS

%   2001 by Pavol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initial values:
d_d=[];				%d spacing
d_th2=[];			%2theta
d_irel=[];         		%relative intensity
d_hkl=[];			%h k l
d_ID=[];			%PDF number
d_name=[];			%compound name
d_formula=[];			%chemical formula
d_CS=[]; 			%crystal system code
d_SG=[];			%space group
d_SGn=[];			%space group or aspect number
d_abcABG=[0 0 0 90 90 90];	%cell parameters
d_V=[];				%volume of crystal data cell
d_MW=[];			%molecular weight
d_Dx=[];			%calculated density
d_Dm=[];			%measured density

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(file)
    file=sprintf('%06i.aid', file);
end
if ~exist(file, 'file')
    if strcmpi(file, '-l')
	fprintf('PDF cards in %s\n', curdir);
	if length(dir('*aid'))
	    !datdesc *aid
	else
	    fprintf('not found');
	end
	return;
    end
    file = [pjtbxdir('pdf') '/' file];
end
fid = fopen(file);
sf = char(fread(fid))';
fclose(fid);
inul = find(sf==0);
if ~isempty(inul)
    fprintf('Warning: %s contains nul characters, check the last line\n', file)
    sf(inul(1):end)='';
end
sf(sf==sprintf('\r'))='';
inl = find(sf==sprintf('\n'));
if any(rem(inl,81))
    error(sprintf('every line in %s should be 80 characters long', file))
end
sf(inl)='';
fr=char(zeros(80, length(sf)/80));
fr(:)=sf(:);
fr=fr';
for r_i=1:size(fr,1)
    r=fr(r_i,:);	%current row
    switch(r(80))
    %card 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case '1',
	a=sscanf(r(1:9), '%f', 1);
	b=sscanf(r(10:18), '%f', 1);
	c=sscanf(r(19:27), '%f', 1);
	A=sscanf(r(28:35), '%f', 1);
	B=sscanf(r(36:43), '%f', 1);
	G=sscanf(r(44:51), '%f', 1);
	d_ID=deblank(r(73:78));			%PDF number
	d_CS=r(79); 				%crystal system code
	switch(d_CS)
	case 'A',
	    d_abcABG=[a b c A B G];
	case 'M',
	    d_abcABG=[a b c sum([A B G])];
	case 'O',
	    d_abcABG=[a b c ];
	case 'T',
	    d_abcABG=[a c ];
	case 'H',
	    d_abcABG=[a a c 90 90 60];
	case 'R',
	    if isempty(A)
		d_abcABG=[a a c 90 90 120];
	    else
		d_abcABG=[a a a A A A];
	    end
	case 'C',
	    d_abcABG=[a ];
	end
    %card 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case '3',
	d_Dm=sscanf(r(30:35), '%f', 1);		%measured density
	d_Dx=sscanf(r(38:43), '%f', 1);		%calculated density
    %card 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case  '4',
	d_SG=deblank(r(1:8));			%space group
	d_SGn=sscanf(r(12:14), '%i', 1);	%space group or aspect number
	d_MW=sscanf(r(51:58), '%f', 1);		%molecular weight
	d_V=sscanf(r(61:69), '%f', 1);		%volume of crystal data cell
    %card 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case  '6',
	if isempty(d_name)
	    d_name=deblank(r(1:67));
	end
    %card 7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case  '7',
	d_formula=deblank(r(1:67));
    %card I %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case  'I',
        q=[ r(1:7) ' ' r(8:10) ' ' r(12:14) ' ' r(15:17) ' ' r(18:20) ' ' ...
          r(24:30) ' ' r(31:33) ' ' r(35:37) ' ' r(38:40) ' ' r(41:43) ' ' ...
          r(47:53) ' ' r(54:56) ' ' r(58:60) ' ' r(61:63) ' ' r(64:66) ];
	x=sscanf(q, '%f%i%i%i%i', [5,3])';
	d_d=[d_d; x(:,1)];			%d spacing
	d_irel=[d_irel; x(:,2)];		%relative intensity
	d_hkl=[d_hkl; x(:,3:5)];		%h k l
    end
end
d_th2=d2th2(d_d);

if nargout<2
    o_d=struct(...
        'd', d_d, 'th2', d_th2, 'irel', d_irel, ...
        'hkl', d_hkl, 'ID', d_ID, 'name', d_name, ...
        'formula', d_formula, 'CS', d_CS, 'SG', d_SG, ...
        'SGn', d_SGn, 'abcABG', d_abcABG, 'V', d_V, 'MW', d_MW, ...
        'Dx', d_Dx, 'Dm', d_Dm ...
        );
else
    o_d=d_d;
    o_I=d_irel;
    o_hkl=d_hkl;
end
