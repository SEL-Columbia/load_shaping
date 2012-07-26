% Mitchell Lee
% Shared Solar 
% Create an Iso-reliability plot for publication
% Began Creating function on July 26, 2012

addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\LEGP_Optimization')

dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);
[r,c] = size(weather);
lats = 13.45;
demVec = fridgeDemandYear;
LEGPVec = 0.05; % LEGP = 0.05

sigma = lats;
phi_c = 0;
rho = 0.2;
I_C = resourceCalc (dates,sigma,phi_c,weather,lats,rho);

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


    demand = demVec;
    batMin = 0;
    batCap = 100*max(demVec);
    batPerDis = .50;
    % for near infinite battery capacity, decrement PV capacity until
    % desired LEGP is reached
    pvCap = 20000;
    LEGP = 0;
    while LEGP <= LEGPDesired(jx)
        [batChar, LEG, LEGP] = SuppDemSum(I_C, demand, pvCap, batCap, batMin);
        if LEGP <= LEGPDesired(jx)
            pvCap = pvCap - pvStep;
        end
    end
        %pvCap = pvCap - pvStep;
    % starting with PV capacity found in previous loop, trace out an
    % isoreliability curve and store in pvBatCurve
    pvBatCurve = zeros(100,2);
    for ix = 1:100
        [batCap, LEGP_ach] = batCapCal(I_C, demand, pvCap, LEGPDesired(jx), batStep, batMin);
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

pvBatCurve = pvBatCurve(find(pvBatCurve(:,2)<=min(pvBatCurve(:,2))*5),:);
cost_kW2 = cost_kW(find(pvBatCurve(:,2)<=min(pvBatCurve(:,2))*5));
pvBatCurve = pvBatCurve(find(pvBatCurve(:,1)<=min(pvBatCurve(:,1))*5),:);
cost_kW2 = cost_kW2(find(pvBatCurve(:,1)<=min(pvBatCurve(:,1))*5));

%% Plotting PV versus Battery Capacity
[ax, h1, h2]  = plotyy(pvBatCurve(:,1),pvBatCurve(:,2),pvBatCurve(:,1),cost_kW2);
set(get(ax(1),'Ylabel'),'String','PV Capacity (W)','FontSize',14)
set(get(ax(2),'Ylabel'),'String','Cost of Electricity (USD/kW-hr)','FontSize',14)
set(ax(1),'YLim',[0 7000],'YTick',0:1000:7000)
set(ax(2),'YLim',[0 5],'YTick',0:.5:5)
set(ax(1),'XLim',[6000 20000],'XTick',6000:2000:20000)
set(ax(2),'XLim',[6000 20000],'XTick',6000:2000:20000)
set(h1,'LineWidth',2,'LineStyle','-')
set(h2,'LineWidth',2,'LineStyle','--')
legend('PV Capacity', 'Cost')
%% Plotting Cost per kWhr versus Battery Capacity 
hold on
[minCost2, minRow2] = min(cost_kW2);
[AX, H1, H2] = plotyy(pvBatCurve(minRow2,1),pvBatCurve(minRow2,2),pvBatCurve(minRow2,1),cost_kW2(minRow2));
set(get(AX(1),'Ylabel'),'String','PV Capacity (W)','FontSize',14)
set(get(AX(2),'Ylabel'),'String','Cost of Electricity (USD/kW-hr)','FontSize',14)
set(AX(1),'YLim',[0 7000],'YTick',0:1000:7000)
set(AX(2),'YLim',[0 5],'YTick',0:.5:5)
set(AX(1),'XLim',[6000 20000],'XTick',6000:2000:20000)
set(AX(2),'XLim',[6000 20000],'XTick',6000:2000:20000)
set(H1,'MarkerSize',14,'Color','r','Marker','x','LineWidth',2)
set(H2,'MarkerSize',14,'Color','r','Marker','x','LineWidth',2)
xlabel('Battery Capacity (W-hr)','FontSize',14)


hold off