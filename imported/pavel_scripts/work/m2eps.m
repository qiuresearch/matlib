function m2eps(mfile)

dev = '-deps';
[ignore, out] = fileparts(mfile);
out = [out '.eps'];
echo on
eval(mfile)
print(dev, out)
