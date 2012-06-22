% Mitchell Lee
% Shared Solar
% Find mimimum cost battery/PV soluation for a Specified LEGP
LEGPDesired = linspace(.01,.2,40);
best = zeros(length(LEGPDesired),6);
% call upon SuppDem Sum

for jx = 1:length(LEGPDesired);
    
    pvStep = 100; % fineness by which PV size can be changed (Watts)
    batStep = 100; % finess by which Batter size may be changed (W-hr)
    pvCost = 0.1762;% Annual Payment for pv ($/Watt-yr)
    batCost = 0.0804;% Annual Payment for battery capacity ($/W-hr-yr)
    dates = LuxorNTSData2005(:,1:4);
    resource = LuxorNTSData2005(:,5);
    demand = fridgeDemandYear;
    batMin = 0;
    batCap = 100*max(fridgeDemandYear);
    batPerDis = .50;
    pvCap = 20000;
    LEGP = 0;
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
    %Correct for only allowable discharge of battery
    pvBatCurve(:,1) = pvBatCurve(:,1)/batPerDis; 
    % Yearly Payment Cost
    totCost = pvBatCurve(:,1)*batCost+pvBatCurve(:,2)*pvCost;
    [minCost, minRow] = min(totCost);
    batMinCost = pvBatCurve(minRow,1)*batCost; 
    pvMinCost = pvBatCurve(minRow,2)*pvCost;
    
    % Cost Per kWh based on Yearly Payment Cost
  kWh_supp = sum(demand)*(1-LEGP_ach)/1000;        
  cost_kW = (pvBatCurve(:,1)*batCost+pvBatCurve(:,2)*pvCost)/kWh_supp;
  [minCost, minRow] = min(cost_kW);
  best(jx,:) = [LEGPDesired(jx),minCost,batMinCost,pvMinCost,pvBatCurve(minRow,:)];
end