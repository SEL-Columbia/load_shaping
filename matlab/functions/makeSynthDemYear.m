% Mitchell Lee 
% Shared Solar 
% July 6, 2012
% Create Synthetic Demand Data Synilar to the Mali
% data with freezer and the Mali data without freezer

%% Fridge Demand

fridgeDemandYearSyn = ones(8760,1)*250;
jx = 1;
for ix = 1:8760
    if (jx==1) || (jx>=18)
        fridgeDemandYearSyn(ix) = 400;
    end
    jx = jx +1;
    if jx == 25
        jx = 1;
    end
end

%% Light Demand
lightDemandYearSyn = zeros(8760,1);
jx = 1;
for ix = 1:8760
    if (jx==1)|| (jx>=18)
        lightDemandYearSyn(ix) = 150;
    end
    jx = jx + 1;
    if jx == 25
        jx = 1;
    end
end