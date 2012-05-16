function [ k ] = findk( totalSolarResource,A,m )
% Compute Clearness index

a = 0.001;
b = 3;

while abs(b-a) > eps*abs(b)
    k= (a + b)/2;
    if sign(sum(A.*exp(-k.*m))-totalSolarResource) == sign(sum(A.*exp(-k.*m)-totalSolarResource))
        b = k;
    else
        a = k;
    end
    
end

end

