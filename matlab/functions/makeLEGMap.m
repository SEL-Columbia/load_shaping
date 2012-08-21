function [ LEGMap ] = makeLEGMap(LEG, Hours)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[r1,c1] = size(LEG);
ax = zeros(1,c1);
for jx = 1:c1
    ax(jx) = subplot(1,c1,jx);
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

        LEGMap(d,h) = LEG(Hours(ix),jx);
    end

    colormap('Autumn')
    LEGMap = pcolor(LEGMap);
    caxis([0 300])
    xlabel('Hour','FontSize',15)
    ylabel('Day','FontSize',15) 
    subplot(1,c1,jx)
    titleNames = {'Annual LEGP = 0.01','Annual LEGP = 0.03','Annual LEGP = 0.05'};
    title(titleNames{jx},'FontSize',16)
end
       cb = colorbar('peer',gca,'location','southoutside');
       caxis([0 300])
       %set(cb,'Position',[0.05 0.1 0.05 0.5]);
       set(get(cb,'xlabel'),'string','LEG (W)','FontSize',15)
       set(cb, 'Position', [.14 .23 .75 .05])
       
    for kx=1:3
        pos=get(ax(kx), 'Position');
        set(ax(kx), 'Position', [pos(1), .25 + pos(2), pos(3), pos(4)*.5],'FontSize',14); 
    end
end

