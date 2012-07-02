% Mitchell Lee
% Combine all data into single cell array

% FIRST DELETE THE FIRST ROW OF TEXTDATA

[r,c] = size(data);
dataCell = cell(r,c);
for ix = 1:r
    for jx = 1:c
        nanYN = isnan(data(ix,jx));
        if nanYN ~= 1
            dataCell{ix,jx} = data(ix,jx);
        else
            dataCell{ix,jx} = textdata{ix,jx};
        end
    end
end
for ix = 1:r
    dataCell{ix,18} = datenum(dataCell{ix,18});
end
UG06 = zeros(r,4);
for ix = 1:r
    UG06(ix,1) = dataCell{ix,14};
    UG06(ix,2) = dataCell{ix,18};
    emptyYN = isempty(dataCell{ix,3});
    if emptyYN == 0
        UG06(ix,3) = dataCell{ix,3};
    else
        UG06(ix,3) = -999;
    end
    UG06(ix,4) = dataCell{ix,25};
end
UG06 = sortrows(UG06,1);
UG0600 = UG06(find(UG06(:,1)==0),:);
UG0601 = UG06(find(UG06(:,1)==1),:);
UG0602 = UG06(find(UG06(:,1)==1),:);
UG0603 = UG06(find(UG06(:,1)==3),:);
UG0604 = UG06(find(UG06(:,1)==4),:);
UG0605 = UG06(find(UG06(:,1)==5),:);
UG0606 = UG06(find(UG06(:,1)==6),:);
UG0607 = UG06(find(UG06(:,1)==7),:);
UG0608 = UG06(find(UG06(:,1)==8),:);
UG0609 = UG06(find(UG06(:,1)==9),:);
UG0610 = UG06(find(UG06(:,1)==10),:);

