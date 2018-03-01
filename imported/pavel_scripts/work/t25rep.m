%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%script for generating dielectric table for PSW25T Pn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files={
'psw25t1.ted';
'psw25t2s.ted';
'psw25t3.ted';
'psw25t4.ted';
'psw25t5.ted';
'psw25t6.ted'
};
ro=[1 6.5 8.08 8.04 7.99 7.59]';
ro25=pswtdens(.25);
fprintf('%-20s\t%-30s\tro\trro\tTmax\tKmax\tKnorm\tdTdiff\tdTdisp\n','file','desc');
for i=1:length(files)
    s=rted(files{i});
    j=find(s.desc==' '); j=j(1);
    desc = s.desc(j+1:end);
    rro=ro(i)/ro25;
    tmkm=dielpk(s,[5 1]);
    Tm=tmkm(1);
    Km=tmkm(2);
    Kmn=Km/rro;
    dTdif=dieldif(s,5);
    dTdisp=tmkm(1)-tmkm(2);
    fprintf('%-20s\t%-30s\t%.1f\t%.1f\t%.1f\t%.0f\t%.0f\t%.1f\t%.1f\n',...
	  s.fname, desc, ro(i), rro, Tm, Km, Kmn, dTdif, dTdisp);
end
