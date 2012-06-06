% Mitchell Lee
% Shared Solar 
% Tease Out Hourly Data From Five Minute Data
% Began on June 6, 2012

[r, c] = size(UG0800);
dates = datevec(UG0800(:,2));
ixs = find(dates(:,5)==5);
UG0800hr = UG0800(ixs,[1,2,4]);
dateshr = datevec(UG0800hr(:,2));
[r2,c2] = size(dateshr);
k=0;
for ix = 2:r2
    if (dateshr(ix,4)~= (dateshr(ix-1,4)+1)) && ((dateshr(ix,4)~=0 && dateshr(ix-1,4)==23)&&(dateshr(ix,4)==0 && dateshr(ix-1,4)~=23))
        k = k+1;
    end
end
