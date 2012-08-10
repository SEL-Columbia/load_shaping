function [ LEGMap ] = makeLEGMap(LEG, Hours)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
days = floor(length(Hours)/24);
LEGMap = zeros(days,24);
for ix = 1:length(Hours)
    d = ceil(ix/24);
    if ix >= 24
        h = rem(ix,24)+1;
        if h == 1
            d = d + 1;
        end
    else
        h = ix;
    end
        
    LEGMap(d,h) = LEG(Hours(ix));
    
end

colormap('Autumn')
LEGMap = pcolor(LEGMap);
xlabel('Hour','FontSize',15)
ylabel('Day','FontSize',15)



end

