function mergedata = data_merge(data1, data2, range)

imin1 = locate(data1(:,1), range(1));
imax1 = locate(data1(:,1), range(2));

imin2 = locate(data2(:,1), range(1));
imax2 = locate(data2(:,1), range(2));

%data2(:,2) = data2(:,2)/mean(data2(imin2:imax2,2))* mean(data1(imin1:imax1,2));
data2(imin2:imax2,2) = (data1(imin1:imax1,2)+data2(imin2:imax2,2))/ 2;

mergedata = [data1(1:imin1-1, :); data2(imin2:end,:)];
