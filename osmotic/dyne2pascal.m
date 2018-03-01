function data = dyne2pascal(osmofiles)

if ischar(osmofiles)
    osmofiles = {osmofiles}
end

for i=1:length(osmofiles)
    data = specdata_readfile(osmofiles{i});
    data.data(:,2) = data.data(:,2)-1;
    specdata_savefile(data, osmofiles{i});
end
