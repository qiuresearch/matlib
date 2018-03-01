function raw2gsas(rawfile, gsasfile)
%RAW2GSAS(RAWFILE, GSASFILE)  convert raw file to GSAS format

if nargin<2 | ~isstr(gsasfile)
    error('output file not specified');
end
r = rraw(rawfile);

ibank = 1;
nchan = length(r.y);
nrec  = ceil(nchan / 10);
bc(1) = r.th2(1)*100;
bc(2) = (r.th2(2) - r.th2(1))*100;
fo = fopen(gsasfile, 'wt');
fprintf(fo, '%-80s\n', r.desc);
fprintf(fo, '%-80s\n', 'Instrument parameter  inst_xry.prm');
s = sprintf('BANK %i %i %i CONST %.2f %.2f 0 0 STD', ibank, nchan, nrec, bc);
fprintf(fo, '%-80s\n', s);
%records 1:nrec-1
fprintf(fo, '%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f\n',...
    r.y(1 : 10*(nrec-1)));
s = sprintf('%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f%8.0f',...
    r.y(10*nrec-9 : nchan) );
fprintf(fo, '%-80s\n', s);
fclose(fo);
