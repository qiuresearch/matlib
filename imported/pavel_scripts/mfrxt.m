function mfrxt
fileroot=input('Enter file name: ', 's');
fileext=input('your favorite extension: ','s');
fileext(fileext=='.')='';
args=input('optional rxsweep arguments: ', 's');
ts1=input('initial soaking time (min): ');
ts2=input('normal soaking time (min): ');
tmeas=input('list measurement temperatures: ', 's');
tmeas=eval(tmeas);
tmeas=tmeas(:)';
ts=0*tmeas+ts2;
ts(1)=ts1;

for n=1:length(tmeas)
    tm=tmeas(n);
    fprintf('Setting T to %.1f C\n', tm);
    dos(sprintf('sett %.1f', tm));
    if tm~=tmeas(end);
	fprintf('Waiting %.1f min\n', ts(n));
	mindelay(ts(n));
    end
    fname=sprintf('%s%.0f.%s', fileroot, tm, fileext);
    cmd=['rxsweep -q ' args ' ' fname ' > NUL'];
    fprintf('\nMeasurement %i of %i at %.0f C\nfilename: %s\n', ...
	n, length(tmeas), tm, fname);
    dos(cmd);
end
fprintf('Finished!!!\n');
dos('sett > NUL');

function mindelay(tmin)
timestart=clock;
n=1;
while etime(clock, timestart)<60*tmin
    pause(1);
    n=n+1;
    if rem(n, 30)==0
	fprintf('elapsed time: %.1f min\n', etime(clock, timestart)/60);
    end
end
