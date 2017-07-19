%% Feature Selection
% We will use the following methods: 
% (1) - PCA
% (2) - NCA = neighborhood component analysis
% (3) Random Trees

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
Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));

%% (1) - PCA
noo = height(TT)/2; % # of observations
% choose L==1 - EVENTS - data 
[wcoeff_e,score_e,latent_e,tsquared_e,explained_e] = pca(Xtest(1:noo,:),...
    'VariableWeights','variance');
coefforth_e = inv(diag(std(Xtest(1:noo,:))))*wcoeff_e;
% choose L==0 - SLOW-BURNING - data 
[wcoeff_sb,score_sb,latent_sb,tsquared_sb,explained_sb] = pca(Xtest(noo+1:end,:),...
    'VariableWeights','variance');
coefforth_sb = inv(diag(std(Xtest(noo+1:end,:))))*wcoeff_sb;

%% 
cs = cumsum(explained_sb);
[~,is95] = sort(abs(cs-95),'ascend');
i95 = is95(1);

plot(cumsum(explained_e),'o','MarkerSize',10)
hold on
plot(cumsum(explained_sb),'LineWidth',2)
plot([i95 i95], [explained_e(1) 100],'--','LineWidth',2)
legend('E','S-B','95% var.')
hold off
xlabel('# PC')
ylabel('Cumulative')
title('Cum. of percentage of total variance')
axis tight
set(gca,'FontSize', 16)

print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/cum_PC_tot_var.eps'] );

%% Feature importance in PCA
% We sum the coef. along the PCs but for those only that consists the 95%
% of the total variance 
feature_imp_e = sum(abs(coefforth_e(:,1:i95)),2);
feature_imp_sb = sum(abs(coefforth_sb(:,1:i95)),2);

[~,is_e]=sort(feature_imp_e,'descend');
fig = figure('position',[1 1 1000 700])  ;
% subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(feature_imp_e(is_e));
title('PCA Importance Estimates - EVENTS');
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(is_e);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/PCA_imp_est_events.eps'] );


[~,is_sb]=sort(feature_imp_sb,'descend');
fig = figure('position',[1 1 1000 700])  ;
% subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(feature_imp_sb(is_sb));
title('PCA Importance Estimates - SLOW BURNING');
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(is_sb);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/PCA_imp_est_slow_burning.eps'] );

%% (2) - Feature selection using neighborhood component analysis for classification
% NCA HAS A MAJOR CAVEAT: IT GIVES DIFFERENT FEATURES WHEN RANDOMLY CHOOSE
% DIFFERENT OBSERVATIONS
irandom = randperm(1e6,100000);
nca = fscnca(Xtest(irandom,:),Ytest(irandom),'Solver','sgd','Standardize',true);
plot(nca.FeatureWeights,'ro')
grid on
xlabel('Feature index')
ylabel('Feature weight')
[~,is_nca] = sort(nca.FeatureWeights, 'descend');

tol    = 0.05;
selidx = find(nca.FeatureWeights > tol*max(1,max(nca.FeatureWeights)));
[feature_weight_sort, isort_selidx] = sort(nca.FeatureWeights(selidx),'descend');

irandom2 = randperm(1e6,100000);
los =  loss(nca,Xtest(irandom2,:),Ytest(irandom2));
%  0.0777
%-----------------------------
% Generalization error
% nca = fscnca(Xtest(irandom,:),Ytest(irandom),'FitMethod','none','Solver','sgd','Standardize',true);
% 0.1080
%-----------------------------
fig = figure('position',[1 1 1000 700])  ;
% subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(feature_weight_sort);
title('NCA Importance Estimates');
ylabel('Feature Weight');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(selidx(isort_selidx));
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
% print(gcf, '-depsc', '-r300','-painters', [sourcefile...
%     'cb24ni/5th_project/figures/NCA_imp_est_test3.eps'] );

%% (3) - Random Trees
rng(1);
irandom = randperm(1e6,50000);
nTrees  = 100; 
method = 'AdaBoostM1';
t = templateTree('Surrogate','on');
TotalBoost = fitcensemble(Xtest(irandom,:),Ytest(irandom),'Method',method,...
    'NumLearningCycles',300,'Learners',t);
% 'AdaBoostM1'	Adaptive boosting	Binary only
% 'Bag'	Bootstrap aggregating (e.g., random forest)	Binary and multiclass

predImp_rt = predictorImportance(TotalBoost);
[~,is_rt]=sort(predImp_rt,'descend');

fig = figure('position',[1 1 1000 700])  ;
% subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(predImp_rt(is_rt));
title([method ' - Importance Estimates']);
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(is_rt);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
%%
print('-f8','-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/Feature_imp_fitcensemble_TotalBoost.eps'])

save('feature_selection_tree_models.mat','AdaBoostM1','GentleBoost','Bag',...
    'LogitBoost','RUSBoost','RobustBoost','LPBoost','TotalBoost')
%% Compare accuracies of two classification models by repeated cross validation
% Essemble-Aggregation Methods:
% https://se.mathworks.com/help/stats/fitcensemble.html?s_tid=doc_ta#bvcj_s6-14
% AdaBoost : https://en.wikipedia.org/wiki/AdaBoost
%             https://en.wikipedia.org/wiki/AdaBoost#Real_AdaBoost
% Bagging: https://en.wikipedia.org/wiki/Ensembles_of_classifiers#Boosting
% LogitBoost : https://en.wikipedia.org/wiki/AdaBoost#LogitBoost
% GentleBoost : https://en.wikipedia.org/wiki/AdaBoost#Gentle_AdaBoost
% LPBoost : https://en.wikipedia.org/wiki/LPBoost
%             suited for applications of joint classification and feature selection in structured domains
% RobustBoost :
% RUSBoost : 
% TotalBoost :
% 

[h, p, e1, e2] = testckfold(AdaBoostM1,RUSBoost,Xtest(irandom,:),Xtest(irandom,:),Ytest(irandom) ,...
    'Alternative', 'unequal', 'Test', '5x2t',  'Options', ...
    statset('UseParallel',true));

% AdaBoostM1, RUSBoost : unequal : h = 1 , p=0.0072; misclas mean: 0.1465, 0.1731 respectively
% AdaBoostM1,RobustBoost: unequal: h = 1 , p=0.07 ; misclas mean: 0.1469, 0.1644
% AdaBoostM1,LPBoost    : unequal: h = 1 , p=7e-5 ; misclas mean: 0.1447, 0.2302
% AdaBoostM1,TotalBoost : unequal: h = 1 , p=0.014 ; misclas mean: 0.1468,0.1732
% AdaBoostM1,GentleBoost: unequal: h = 0 , p=0.12 ; misclas mean: 0.1474, 0.1572
% AdaBoostM1,Bagging : unequal   : h = 0 , p=0.41 ; misclas mean: 0.1468, 0.1452
% AdaBoostM1,LogitBoost : unequal: h = 0 , p=0.66 ; misclas mean: 0.1471, 0.1521

% is_rt = [17 22 9];

% Accuracies between 2 models shows that:
% 1) AdaBoostM1 has the same accuracy as
%       - GentleBoost
%       - Bagging
%       - LogitBoost
% 2) AdaBoostM1 has different accuracy in respect with:
%       - RUSBoost
%       - RobustBoost
%       - LPBoost
%       - TotalBoost

% Choose top 10 features for each of the (1) groups. 
AdaBoostM1_nam = {'qjoule', 'j2', 'z', 'etaohm', 'cs',     'b2', 'qvisc', 'bh', 'jb', 'man'};
GentleBoost_nam = {'qjoule', 'z', 'j2b', 'etaohm', 'cs',   'bh', 'divb', 'jb', 'gradp', 'divu'};
Bagging_nam= {'qjoule', 'max_jxyz', 'j', 'job', 'etaohm',  'j2b', 'z', 'qvisc', 'min_jxyz', 'jdb'};
LogitBoost_nam= {'qjoule', 'z', 'j2b', 'etaohm', 'man',    'bh', 'jdb', 'gradp', 'max_btolxyz', 'qgenrad'};

clas4 = [AdaBoostM1_nam GentleBoost_nam Bagging_nam LogitBoost_nam];
names2num = grp2idx(clas4);
names2num2 = reshape(names2num,[],4)