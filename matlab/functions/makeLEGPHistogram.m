% Mitchell Lee
% Shared Solar 
% Script Began on 07162012
% Hourly LEGP Histogram Maker
format compact; format long g
close all
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\LEGP_Optimization')
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\Data') 

dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);%,LuxorNTS(:,5),KisanganiNTS(:,5),NouakchottNTS(:,5)];LEGPMonthly
[r,c] = size(weather);
lats = 13.45;%25.68,0.51,18.08];
demVec = fridgeDemandYear;
% Specify the Desired LEGP to Test At
LEGPVec = [0.01,0.05];
bestMultiLoc = zeros(length(LEGPVec),6,c);
sigma = lats;
phi_c = 0;
rho = 0.2;

% Test Compute the Best array for each LEGP
for ixx = 1:1%c
    I_C = resourceCalc (dates,sigma(ixx),phi_c,weather(:,ixx),lats(ixx),rho);
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,I_C,demVec,LEGPVec);
end
   
batChar1 = zeros(length(I_C),length(LEGPVec));
LEG1 = zeros(length(I_C),length(LEGPVec));
LEGP1 = zeros(length(LEGPVec),1);
% Energy Balance Algorithm for each LEGP, so that the LEP of each
% hour is known


for ix = 1:length(LEGPVec)                              %SuppDemSum (I_C,demand, pvCap, batCap, batMin)
    [batChar1(:,ix), LEG1(:,ix),LEGP1(ix)] = SuppDemSum(I_C,demVec,bestMultiLoc(ix,6),bestMultiLoc(ix,5),bestMultiLoc(ix,5)/2);
end
   
%Separate Out LEGP by Hour
LEGPHourly = zeros(24,length(LEGPVec));
LEGHourly = zeros(24,length(LEGPVec));

for ix = 1:length(LEGPVec)
    for jx = 1:24
        LEGHourly(jx,ix) = sum(LEG1(:,ix).*(dates(:,4)==jx));
        LEGPHourly(jx,ix) = LEGHourly(jx,ix)./sum(demVec.*(dates(:,4)==jx));
    end
end

aveDay = makeAveDay(demVec(1:168));
[ax, h1, h2] = plotyy(1:24,LEGPHourly,1:24,aveDay,@bar,@line);
xlabel('Hour','FontSize',18)
set(get(ax(1),'Ylabel'),'String','Hourly LEGP','FontSize',16)
set(get(ax(2),'Ylabel'),'String','Average Hourly Energy Demand (Whr)','FontSize',16)
colormap hot
set(ax(1),'FontSize',16)
set(ax(2),'FontSize',16)
set(h2,'LineWidth',2,'LineStyle','--')
legend('Hourly LEGP for Yearly LEGP = 0.01','Hourly LEGP for Yearly LEGP = 0.05', 'Average Hourly Energy Demand')

%Separate Out LEGP by Month
LEGPMonthly = zeros(12,length(LEGPVec));
LEGMonthly = zeros(12,length(LEGPVec));

for ix = 1:length(LEGPVec)
    for jx = 1:12
        LEGMonthly(jx,ix) = sum(LEG1(:,ix).*(dates(:,3)==jx));
        LEGPMonthly(jx,ix) = LEGMonthly(jx,ix)./sum(demVec.*(dates(:,3)==jx));
    end
end

I_monthly = makeMonthlyRad(dates, I_C);

figure
[Ax, H1, H2] = plotyy(1:12,LEGPMonthly,1:12,I_monthly,@bar,@line);
xlabel('Month','FontSize',14)
set(get(Ax(1),'Ylabel'),'String','Monthly LEGP','FontSize',14)
set(get(Ax(2),'Ylabel'),'String','Monthly Insolation on Collector (Whr/m^2)','FontSize',14)%\
colormap hot
set(Ax(1),'FontSize',14)
set(Ax(2),'FontSize',14)
set(H2,'LineWidth',2,'LineStyle','--')
legend('Monthly LEGP for Yearly LEGP = 0.01','Monthly LEGP for Yearly LEGP = 0.05', 'Insolation on Collector (Whr/m^2)')%\


