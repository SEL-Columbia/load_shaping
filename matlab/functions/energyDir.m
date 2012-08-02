function [ enDir ] = energyDir( supply,demand )
%energyDir
%   calculates the about of generated energy goes directly into 
%   meeting demand. This is to assess the relative importance of the 
%   battery bank when comparing different systems. 
%   This is not 100 percent accurate because the simulation is conducted 
%   on an hourly time scale. However, this sould provide insight as to 
%   how much the system is relying on the batttery bank.

enDir = zeros(8760,1);
for ix = 1:8760
    if supply(ix) >= demand(ix)
        enDir(ix) = demand(ix);
    elseif supply(ix) < demand(ix)
        enDir(ix) = supply(ix);
    end
end

