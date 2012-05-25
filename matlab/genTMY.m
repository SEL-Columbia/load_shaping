% Mitchell Lee
% Shared Solar
% Create a Typical Meteorological Year (TMY) of solar data

n = 28;
years = 10;
X = zeros(n,12,years);
F = zeros(n,12,years);
delta = zeros(n,12,years);
FS = zeros(12,years);


Daily = zeros(365,2);
for ix = 1:years
    %find the sum of the solar energy for each day
    for jx = 1:365
        day = radMat((24*jx-23):(jx*24),ix);
        A = datevec(dateMat(((24*jx-23):(jx*24)),ix));
        Daily(jx,1) = datenum(A(1,1:3));
        Daily(jx,2) = sum(day);
    end
    B = datevec(Daily(:,1));
    kx = 1;
    %isolate a month from the data set
    for months = 1:12
        lx = 1;
        tempMonth = [];
        while B(kx,2) == months;
            tempMonth(lx) = Daily(kx,2);
            kx = kx+1;
            lx = lx+1;
            if kx >365
                break
            end
        end
        % Take a random sample of the daily measurements
        X(:,months,ix) = randsample(tempMonth,n);
    end
end
% sort randome samples within each month from least to greatest
for ix = 1:years
    for jx = 1:12
        X(:,jx,ix) = sort(X(:,jx,ix),'ascend');
        for kx = 1:n
            F(kx,jx,ix) = 1-exp(-X(kx,jx,ix)/mean(X(:,jx,ix)));
            delta(kx,jx,ix) = max([abs(F(kx,jx,ix)-(kx-1)/n),abs(F(kx,jx,ix)-kx/n)]);
        end
    end
end

for ix = 1:years
    for jx = 1:months
        FS(jx,ix) = 1/n*sum(delta(:,jx,ix));
    end
end
