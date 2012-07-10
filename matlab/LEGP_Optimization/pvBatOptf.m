function [ best ] = pvBatOptf(dates, weathVec,lats,demVec,LEGPVec)
% Mitchell Lee
% Shared Solar
% Find mimimum cost battery/PV soluation for a Specified LEGP
LEGPDesired = LEGPVec;
best = zeros(length(LEGPDesired),6);

% call upon SuppDem Sum
% loop over vector of LEGP values
% this constructs the cost vs LEGP plot
for jx = 1:length(LEGPDesired);
    

    pvStep = 100;     % fineness by which PV size can be changed (Watts)
    batStep = 100;    % finess by which Batter size may be changed (W-hr)
    pvCost = 0.1762;  % Annual Payment for pv ($/Watt-yr)
    batCost = 0.0804; % Annual Payment for battery capacity ($/W-hr-yr)
    resource = weathVec;


    demand = demVec;
    batMin = 0;
    batCap = 100*max(demVec);
    batPerDis = .50;
    % for near infinite battery capacity, decrement PV capacity until
    % desired LEGP is reached
    pvCap = 20000;
    LEGP = 0;
    while LEGP <= LEGPDesired(jx)
        [batChar, LEG, LEGP] = SuppDemSum(dates,lats, resource, demand, pvCap, batCap, batMin);
        if LEGP <= LEGPDesired(jx)
            pvCap = pvCap - pvStep;
        end
    end
    
    % starting with PV capacity found in previous loop, trace out an
    % isoreliability curve and store in pvBatCurve
    pvBatCurve = zeros(100,2);
    for ix = 1:100
        [batCap, LEGP_ach] = batCapCal(dates, lats, resource, demand, pvCap, LEGPDesired(jx), batStep, batMin);
        pvBatCurve(ix,:) = [batCap, pvCap];
        pvCap = pvCap +pvStep;
    end

    % Correct for depth of discharge of battery
    pvBatCurve(:,1) = pvBatCurve(:,1) / batPerDis; 
    % determine Yearly Payment Cost from isoreliability curve and find
    % minimum
    totCost = pvBatCurve(:,1) * batCost + pvBatCurve(:,2) * pvCost;
    [minCost, minRow] = min(totCost);
    batMinCost = pvBatCurve(minRow,1) * batCost; 
    pvMinCost = pvBatCurve(minRow,2) * pvCost;
    
    % Cost Per kWh based on Yearly Payment Cost
  kWh_supp = sum(demand)*(1-LEGP_ach)/1000;        
  cost_kW = (pvBatCurve(:,1)*batCost+pvBatCurve(:,2)*pvCost)/kWh_supp;
  [minCost, minRow] = min(cost_kW);
  % assemble matrix of results
  best(jx,:) = [LEGPDesired(jx),minCost,batMinCost,pvMinCost,pvBatCurve(minRow,:)];
end


end

