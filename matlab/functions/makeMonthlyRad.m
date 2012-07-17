function [ I_monthly] = makeMonthlyRad(dates, I_C)
% makeMonthlyRad
    % imports I_C and the dates. Outputs the sum of insolation
    % in each month
    
    
I_monthly = zeros(12,1);

for ix = 1:12
    I_monthly(ix) = sum((dates(:,2)==ix).*I_C);
end

end

