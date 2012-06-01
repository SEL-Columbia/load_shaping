% Mitchell Lee
% Shared Solar
% Find mimimum cost battery/PV soluation for a Specified LEGP

pvStep = 100; % fineness by which PV size can be changed (Watts)
batStep = 100; % finess by which Batter size may be changed (W-hr)
pvCost = 3;% cost of pv ($/Watt)
batCost = 5;% cost of battery capacity ($/W-hr)
LEGPDesired = [0.10];%,0.1,0.15,0.20,0.25,0.3,0.35,.4];
best = zeros(length(LEGPDesired),4);
% call upon SuppDem Sum
dates = MaliNTSData2005(:,1:4);
resource = MaliNTSData2005(:,5);
demand = fridgeDemandYear;
batMin = 0;
batCap = 100*max(fridgeDemandYear);
pvCap = 20000;
LEGP = 0;

for jx = 1:length(LEGPDesired);
    
    while LEGP <= LEGPDesired(jx)
        [batChar, LOLP, LEGP] = SuppDemSum (dates,resource,demand, pvCap, batCap, batMin);
        if LEGP<= LEGPDesired(jx)
            pvCap = pvCap -pvStep;
        end
    end
    
    pvBatCurve = zeros(100,2);
    
    
    for ix = 1:100
        [batCap, LEGP_ach] = batCapCal(dates,resource,demand, pvCap, LEGPDesired(jx),batStep, batMin);
        pvBatCurve(ix,:) = [batCap, pvCap];
        pvCap = pvCap +100;
    end
    
    pvBatCurve = pvBatCurve(pvBatCurve(:,1)<10000,:);
    cost = pvBatCurve(:,1)*batCost+pvBatCurve(:,2)*pvCost;
    [minCost, minRow] = min(cost);
    best(jx,:) = [LEGPDesired(jx),minCost,pvBatCurve(minRow,:)];
end