function plotconf(Ytest, Ypred,labels, name_title)
% Plot confusion matrix function using heatmap
% the first two diagonal cells show the number and percentage of correct 
% classifications by the trained network. 

% the red diagonal represent the incorrectly classifications

% 1st row 3rd column = out of total class 1 predictions there are x % correct
% predictions and the residual is wrong predictions
% 2nd row 3rd column = out of total class 2 predictions there are x %
% correct predictions and the residual is wrong predictions

% 1nd column 3rd row = out of total classs 1 cases x % are correctly
% classified and the residual is misclassified as class 2
% 2nd column 3rd row = out of total class 2 cases x %  is correctly
% classified and the resifual is misclassified as class 2

% 3rd column and row = overal % of correct predictions, the residual is
% overal miscalssification %
%--------------------------------------------------------------------------
addpath('~/Documents/MATLAB/BrewerMap/')
cm = brewermap(10,'Set2');
f1 = cm(8,:);
f4 = cm(3,:);
f9 = cm(4,:);
f14 = cm(1,:);

if nargin<4
    name_title = '';
end
Yt=zeros(2,numel(Ytest),'single');
Yp=Yt;

Yt(1,:)=Ytest>0;  % even
Yt(2,:)=Ytest==0; % no event
Yt = single(Yt);
if iscell(Ypred)
    Ypred = single(cell2mat(Ypred) =='1');
end

Yp(1,:)=Ypred>0;  % event
Yp(2,:)=Ypred==0; % no event
Yp = single(Yp);

% plot
plotconfusion(Yt,Yp,name_title)
set(gca,'fontsize',16)
set(findobj(gca,'type','text'),'fontsize',16) 
set(gca,'xticklabel',{labels{1} labels{2} ''})
set(gca,'yticklabel',{labels{1} labels{2} ''})
% set colors
 set(findobj(gca,'color',[0,102,0]./255),'color',[0, 0, 0])
 set(findobj(gca,'color',[102,0,0]./255),'color',[220,20,60]/255)
set(findobj(gcf,'facecolor',[120,230,180]./255),'facecolor',f4)
set(findobj(gcf,'facecolor',[230,140,140]./255),'facecolor',f9)
set(findobj(gcf,'facecolor',[0.5,0.5,0.5]),'facecolor',f1)
set(findobj(gcf,'facecolor',[120,150,230]./255),'facecolor',f14)
end

