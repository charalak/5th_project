%% Feature associsation using Ensemble trees
% This script uses the surrogate keyword of the fitcensemple (tree) in
% combination with the predictorImportance. We then plot a square map of
% the features. The diagonal has the maximum values because it is somehting
% like autocorrelation. The off-diagonal values must be the objects of
% interest.

%% Set paths
if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
end
addpath('~/Documents/MATLAB/subaxis/')

TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;

% Responses and features
% Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));
clearvars TT

%% Train surrogated & Pruned trees
rng(1);
irandom = randperm(1e6,50000);
method = 'AdaBoostM1';
prunkey = 'On';
surrogatekey = 'On';
t = templateTree('Surrogate',surrogatekey,'Prune',prunkey);
Mdl = fitcensemble(Xtest(irandom,:),Ytest(irandom),'Method',method,...
    'NumLearningCycles',500,'Learners',t);
% 'AdaBoostM1'	Adaptive boosting	Binary only
% 'Bag'	Bootstrap aggregating (e.g., random forest)	Binary and multiclass

[impGain,predAssociation]  = predictorImportance(Mdl);
[sor,isor]=sort(predAssociation(:),'descend');
[so,iso]=sort(impGain(:),'descend');


%% Feature Association
idx = find((sor<1) & (sor>0.3));

for i=1:numel(idx)
    [i1,i2] = ind2sub([numel(impGain), numel(impGain)], isor(idx(i))); 
    display(['Pair of associated features : ' cell2mat(names(i1)) '  -  ' cell2mat(names(i2))...
        '  val =  ' num2str(sor(idx(i))) ])
end

%%
predAssociation2 = predAssociation;
predAssociation2(predAssociation<0.3) = 0;
predAssociation2(predAssociation>0.3) = 1;
% predAssociation2 = predAssociation2*1;
imagesc(predAssociation2);
title('Predictor Association Estimates');
% colorbar;
colormap('gray')
% caxis([0.3, 1.1])
% caxis auto
% shading interp;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',12)
set(gca,'YTick',1:numel(names)-1,'FontSize',12)
h.XTickLabel = names;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
h.YTickLabel = names;
% set(gca, 'FontSize',18)

print('-f1', '-depsc','-opengl', [sourcefile...
     'cb24ni/5th_project/figures/Feat_Assoc_' method '_Surrogate' surrogatekey...
     '_Prun' prunkey '.eps'] );

% close all
%% --------------------------------

%% Feature Importance
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(so);
title([method ' - Importance Estimates']);
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(iso); 
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

print(gcf, '-depsc' , '-r300','-opengl',[sourcefile...
    'cb24ni/5th_project/figures/Feature_imp_fitcensemble_'  method 'Prun' prunkey '.eps'])
save([Mdl '_Surrogate' surrogatekey '_Prun' prunkey '.mat'],'Mdl')
