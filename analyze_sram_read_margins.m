function [noiseMarginMatrix] = readmargin_plot_v2(data1, data2, curveSets)

% readmargin_plot_v2
% Author: Mark Gottscho
% UCLA NanoCAD Lab
%
%
%
% data1: Qbar vs Q
% data2: Q vs Qbar
% curveSets: Number of matched curves for each data set.
%
% Returns noiseMarginMatrix, is an array of calculated noise margins for
% each data set.
%
%
% I suggest loading data1 and data2 as follows:
% data1 = csvread('FILENAME_QBAR.csv',1,0);
% data2 = csvread('FILENAME_Q.csv',1,0);

noiseMarginMatrix = NaN(curveSets,1);

identityLine = [0:0.01:0.99];
identityLine = [identityLine(:), identityLine(:)];

figure(1);
hold on;
set(gca, 'FontSize', 12);
grid minor;
axis equal;
title 'Static Read Margin, 6T SRAM Cell (IBM 45nm SOI)';
xlabel 'VIN (V)';
ylabel 'VOUT (V)';
axis([0 1 0 1]);

for m = 1 : curveSets
    maxSpreadUp = 0;
    maxSpreadDown = 0;
    maxSpreadLineUp = 0;
    maxSpreadLineDown = 0;
    spread = 0;
    x1 = 0;
    y1 = 0;
    x2 = 0;
    y2 = 0;
    maxSpreadLine = 0;
    
    % Get the two curves on the same axes, with x increasing with the row
    % indices
    curve1 = [data1(:,m*2-1) data1(:,m*2)];
    curve2 = [data2(:,m*2) data2(:,m*2-1)];
    curve2 = flipud(curve2);
    
    b = curve2(:,2)-curve2(:,1); % Compute b (intercept coordinates) for the 45-degree line corresponding to each point in curve2, b=y-x
    
    for i = 1 : size(b,1) % For each y-intercept value
        % Generate the corresponding y=x+b line
        interceptLine = [curve1(:,1) curve1(:,1)+b(i)]; % x values are same as curve1, y values are simply x values + current b intercept
        y2 = curve2(i,2);
        x2 = curve2(i,1);
        
        % Compute the approximate crossover point of intercept line with
        % curve1
        for j = 1 : size(curve1,1)
           if curve1(j,2) <= interceptLine(j,2) % As soon as intercept y-value is higher than curve1 y-value, save this intercept coordinate
              y1 = interceptLine(j,2);
              x1 = interceptLine(j,1);
              break;
           end
        end
        
        spread = sqrt((abs(y2-y1))^2+(abs(x2-x1))^2);
        if y1 >= y2 && spread > maxSpreadUp % Max spread for upper half of butterfly (curve 1 >= curve 2)
            maxSpreadUp = spread;
            maxSpreadLineUp = interceptLine;
        elseif y1 < y2 && spread > maxSpreadDown % Max spread for bottom half of butterfly (curve 1 < curve 2)
            maxSpreadDown = spread;
            maxSpreadLineDown = interceptLine;
        end
    end
    
    
    % Take min of two margins
    noiseMarginUp = maxSpreadUp/sqrt(2);
    noiseMarginDown = maxSpreadDown/sqrt(2);
    noiseMarginMatrix(m) = min(noiseMarginUp, noiseMarginDown);
    if noiseMarginUp >= noiseMarginDown
        maxSpreadLine = maxSpreadLineDown;
    else
        maxSpreadLine = maxSpreadLineUp;
    end
 
    plot(curve1(:,1), curve1(:,2), 'k', curve2(:,1), curve2(:,2), 'k');
  %  plot(maxSpreadLine(:,1), maxSpreadLine(:,2), 'k--');
end

plot(identityLine(:,1), identityLine(:,2), 'k--');

figure(2);
hold off;
set(gca, 'FontSize', 12);
hist(noiseMarginMatrix,25);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
xlabel 'Static Noise Margin (V)';
ylabel 'Occurrences'
title 'Histogram of Static Read Margins, 6T SRAM Cell (IBM 45nm SOI)';