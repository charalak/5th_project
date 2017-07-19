function comparisonPlot( Cmat, labels )
%comparisonPlot Visualize misclassification rate
addpath('~/Documents/MATLAB/subaxis/')
addpath('~/Documents/MATLAB/BrewerMap/')
% Copyright 2013 The MathWorks, Inc.

[nRows, nCols] = size(Cmat);

% Change shape of Cmat so that it is suitable for plotBarStackGroups
Cmat = reshape(Cmat,[nRows * 2, nCols / 2])';
Cmat = Cmat(:,[1 4 3 2]);
Cmat = reshape(Cmat,[nCols/2, 2, 2]);

% Use file submitted from a user at MATLAB Central to plot groups of
% stacked bars
% labels = {'NN','GLM','DA','KNN', 'NB'};

h = plotBarStackGroups(Cmat,labels);
% colors = 'bcrm';
[map,~,~] = brewermap(numel(h),'Accent');
 for i = 1:numel(h)
%      set(h(i),'FaceColor',colors(i));
 set(h(i),'FaceColor',map(i,:));
 end
ylabel('Percentage')
title({'Joule heating events vs. slow-burning currents','Misclassification Rate'},'FontWeight','bold')
ylim([0 101])
legend({'Event','Misclassified','Slow-burning','Misclassified'},'Location','EastOutside')
%xtickangle(60);
ax = gca;
xa = ax.XAxis; xa.TickLabelRotation = 60;
set(gca,'Unit','normalized','Position',[0.13 0.3 0.6 0.6])
set(gca,'Color','none','FontSize',18)

end

