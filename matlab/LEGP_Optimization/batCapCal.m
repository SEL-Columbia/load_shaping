function [batCap, LEGP_ach] = batCapCal( I_C,demand, pvCap, LEGP, batStep, batMin)

supply = I_C/1000*pvCap;%W
batChar = zeros(length(demand),1);
LEGPTemp = 1;
batCap = 0;
x = 0;

while LEGPTemp >= LEGP
    
    for ix = 1:(length(demand)-1);
        batChar(ix+1) = batChar(ix)+supply(ix)-demand(ix);
        if batChar(ix+1) > batCap
            batChar(ix+1) = batCap;
        end
        if batChar(ix+1) < batMin
            batChar(ix+1) = batMin;
        end
    end
    batCap = batCap + batStep;
    
    LEG = zeros(length(demand),1);
    for ix = 1:(length(demand)-1);
        LEG(ix+1) = demand(ix+1)-(supply(ix+1)+batChar(ix)-batMin);
        if LEG(ix+1) <0
            LEG(ix+1) = 0;
        end
    end
    LEGPTemp = sum(LEG)/sum(demand);
    if batCap >=100000
        LEGP_ach = -999;
        x = 1;
        break
    end
end
batCap = batCap -100;
LEGP_ach = LEGPTemp;