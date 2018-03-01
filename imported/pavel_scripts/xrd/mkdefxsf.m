function mkdefxsf
%this will generate a mat file with default scattering factors

names=dir('SFDATA\*.nff');
out='xsfdef.m';
fid=fopen(out, 'wt');
fprintf(fid, 'function f=xsfdef(element)\n');
fprintf(fid, '%%default scattering factors\n');
for a=1:length(names)
    cel=names(a).name;
    el=lower(cel(1:(find(cel=='.')-1)));
    ff=xsf(el);
    fprintf(fid, '%s=%.10e %+.10ei;\n', el, real(ff), imag(ff));
end
fprintf(fid, 'eval([''f='' lower(element) '';'']);\n');
fclose(fid);
