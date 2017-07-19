%% Check predicet values
% This function load the models generated from  classification_events.m and
% predicts new values for other datasets.
% Results are presented as: 
%   Confusion Matrices plots
%   ROC plots
%   Comparison of models in barplots
close all;
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
%% Load models
MODELS = load([modelsfile 'models.mat']);
MODELS_REDUCED_on_DT = load([modelsfile 'MODELS_REDUCED_on_DT.mat']);
net = MODELS.net; % Decission Trees
DT = MODELS.DT; % Decission Trees
NB = MODELS.Nb; % Naive Bayes
DA = MODELS.da; % Discriminant Analysis
GLM = MODELS.glm; % Generalized Linear Model - Logistic Regression
KNN = MODELS.knn; % Nearest Neighbors
svm = MODELS.svm;
svm_std = MODELS.svm_std;
TB = MODELS.tb; % tree bagger
DTr = MODELS_REDUCED_on_DT.DTr;
tb_r = MODELS_REDUCED_on_DT.tb_r;
fs = MODELS_REDUCED_on_DT.fs;
% TBr = MODELS.tb_r; % tree bagger reduced

%% Load data 
TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;
num = height(TT);
% idx = randperm(height(TT),num);
% TT = TT(idx,:);
%% Response and features
Ytest = TT.L;
tabulate(Ytest)
% Predictor matrix
Xtest = double(table2array(TT(:,1:end-1)));

%% Predict responses
Y_nn = net(Xtest');
Y_nn = round(Y_nn');
Y_glm = GLM.predict(Xtest); Y_glm = round(Y_glm) ;
Y_da = DA.predict(Xtest);
Y_knn = KNN.predict(Xtest);
Y_Nb = NB.predict(Xtest);
Y_svm = predict(svm,Xtest);
Y_svm_std = predict(svm_std,Xtest);
Y_dt = DT.predict(Xtest);
[Y_tb, classifScore] = TB.predict(Xtest);

%% ROC
[FPnn,TPnn,~,AUCnn,OPTROCPTnn] = perfcurve(Ytest, Y_nn,1);
[FPglm,TPglm,~,AUCglm,OPTROCPTglm] = perfcurve(Ytest, Y_glm,1);
[FPda,TPda,~,AUCda,OPTROCPTda] = perfcurve(single(Ytest), single(Y_da),1);
[FPknn,TPknn,~,AUCknn,OPTROCPTknn] = perfcurve(single(Ytest), single(Y_knn),1);
[FPNb,TPNb,~,AUCNb,OPTROCPTNb] = perfcurve(single(Ytest), single(Y_Nb),1);
[FPsvm,TPsvm,~,AUCsvm,OPTROCPTsvm] = perfcurve(single(Ytest), single(Y_svm),1);
[FPsvm_std,TPsvm_std,~,AUCsvm_std,OPTROCPTsvm_std] = perfcurve(single(Ytest), single(Y_svm_std),1);
[FPdt,TPdt,~,AUCdt,OPTROCPTdt] = perfcurve(single(Ytest), single(Y_dt),1);
[FPtb,TPtb,~,AUCtb,OPTROCPTtb] = perfcurve(single(Ytest), single(cell2mat(Y_tb)=='1'),1);

%% PLOT ROC
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.1,'MR',0.02,'MT',0.05)
plot(FPglm,TPglm,'--','LineWidth',1.5)
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Curves')
set(gca,'FontSize', 18)

hold on
plot(FPnn,TPnn,'LineWidth',1.5)
plot(FPda,TPda,'LineWidth',1.5)
plot(FPknn,TPknn,'LineWidth',1.5)
plot(FPNb,TPNb,'LineWidth',1.5)
plot(FPsvm,TPsvm,'LineWidth',1.5)
plot(FPdt,TPdt,'LineWidth',1.5)
plot(FPtb,TPtb,'LineWidth',1.5)

lg = legend([num2str(AUCglm) '  GLM'],  [num2str(AUCnn) '  NN'], ...
    [num2str(AUCda)  '  DA'],...
    [num2str(AUCknn)  '  KNN'],[num2str(AUCNb)  '  NB'],[num2str(AUCsvm)  '  SVM'],...
    [num2str(AUCdt)  '  DT'],[num2str(AUCtb)  '  TB'],'Location','East');
title(lg,'AREA UNDER CURVE')
legend boxoff
hold off

outname = num2str(num);
print('-f1','-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/ROC_rand' outname '.eps'])

close(1)
%% Compute comfusion matrices
C_glm = confusionmat(Ytest,logical(Y_glm));
C_glm = bsxfun(@rdivide,C_glm,sum(C_glm,2)) * 100;

C_nn = confusionmat(double(Ytest),Y_nn);
C_nn = bsxfun(@rdivide,C_nn,sum(C_nn,2)) * 100; 

C_da = confusionmat(Ytest,Y_da);
C_da = bsxfun(@rdivide,C_da,sum(C_da,2)) * 100;

C_knn = confusionmat(Ytest,Y_knn); 
C_knn = bsxfun(@rdivide,C_knn,sum(C_knn,2)) * 100;

C_nb = confusionmat(Ytest,Y_Nb);
C_nb = bsxfun(@rdivide,C_nb,sum(C_nb,2)) * 100;

C_svm = confusionmat(Ytest,Y_svm);
C_svm = bsxfun(@rdivide,C_svm,sum(C_svm,2)) * 100;

C_svm_std = confusionmat(Ytest,Y_svm_std);
C_svm_std = bsxfun(@rdivide,C_svm_std,sum(C_svm_std,2)) * 100;

C_dt = confusionmat(Ytest,Y_dt);
C_dt = bsxfun(@rdivide,C_dt,sum(C_dt,2)) * 100;

C_tb = confusionmat(categorical(Ytest,[0 1]),categorical(Y_tb));
C_tb = bsxfun(@rdivide,C_tb,sum(C_tb,2)) * 100;

%%  Compare Models 

Cmat = [C_glm C_nn C_da C_knn C_nb C_svm C_svm_std C_dt C_tb];
labels = { 'Logistic Regression ', 'Neural Network' , 'Discriminant Analysis ',...
    'k-nearest Neighbors ', 'Naive Bayes ', 'Support VM' ,'STD Support VM' , ...
    'Decision Trees ', 'TreeBagger '};

comparisonPlot( Cmat, labels )

print('-f1','-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/Model_Comparison_rand' outname '.eps'])

%% Plot Confusion Matrices

plotconf(Ytest, Y_glm,{'E','S-B'}, 'GLM')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_glm.eps'] );
plotconf(Ytest, Y_nn,{'E','S-B'}, 'NN')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_nn.eps'] );
plotconf(Ytest, Y_da,{'E','S-B'}, 'DA')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_da.eps'] );
plotconf(Ytest, Y_knn,{'E','S-B'}, 'KNN')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_knn.eps'] );
plotconf(Ytest, Y_Nb,{'E','S-B'}, 'NB')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_nb.eps'] );
plotconf(Ytest, Y_svm,{'E','S-B'}, 'SVM')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_svm.eps'] );
plotconf(Ytest, Y_svm_std,{'E','S-B'}, 'SVM STD')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_svm_std.eps'] );
plotconf(Ytest, Y_dt,{'E','S-B'}, 'DT')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_dt.eps'] );
plotconf(Ytest, Y_tb,{'E','S-B'}, 'TB')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_tb.eps'] );

close all
%% Estimating a Good Ensemble Size of Trees
% Examining the out-of-bag error may give an insight into determining a
% good ensemble size. 

fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.1,'MR',0.02,'MT',0.05)
plot(oobError(TB),'k','LineWidth',2);
xlabel('Number of Grown Trees');
ylabel('OOB Classfic. Error/Misclassif. Prob.');
axis tight
set(gca,'FontSize',18)

print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Num_grown_trees.eps'] );

close(1)

if 0
%% Estimating Feature Importance: Using CART
% Feature importance measures the increase in prediction error if the
% values of that variable are permuted across the out-of-bag observations.
% This measure is computed for every tree, then averaged over the entire
% ensemble and divided by the standard deviation over the entire ensemble.
[oof_imp,idxvarimp]=sort(TB.OOBPermutedVarDeltaError,'descend');

fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(oof_imp,'k');
ylabel('Out-Of-Bag Feature Importance');
xlabel('# Feature')
axis tight;
set(gca,'XTickMode','manual');
set(gca,'XTick',1:numel(names)-1,'FontSize',18)
set(gca,'TickLabelInterpreter','none')
set(gca,'XTickLabel',names(idxvarimp),'FontSize',18)
ax = gca;
ax.XTickLabelRotation = 60;
[~,idxvarimp] = sort(TB.OOBPermutedVarDeltaError, 'descend');
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Feature_importance_TreeBagger.eps'] );

close(1)
end
%% Sequential Feature Selection
% Feature selection reduces the dimensionality of data by selecting only a
% subset of measured features (predictor variables) to create a model.
% Selection criteria involves the minimization of a specific measure of
% predictive error for models fit to different subsets.
% 
% Sequential feature selection can be computationally intensive. It can
% benefit significantly from paralcel computing.

if 0
    opts = statset('UseParallel',true);
    critfun = @(Xtr,Ytr,Xte,Yte)featureImp(Xtr,Ytr,Xte,Yte,'ClassificationTree');
    % The top 5 features determined in the previous step have been included,
    % to reduce the number of combinations to be tried by sequentialfs
    [fs,history] = sequentialfs(critfun,Xtest,Ytest,'options',opts,'keepin',idxvarimp(1:10));
    disp('Included features:');
    disp(names(fs)');
end
% without the t =  fitctree(Xtrain,Ytrain, 'MinLeafSize',1,...
%     'MaxNumSplits', 807,...
%     'SplitCriterion', 'gdi',...
%     'NumVariablesToSample', 54);

% 'bh'
% 'divb'
% 'etaohm'
% 'jdb'
% 'man'
% 'pressure'
% 'qgenrad'
% 'qjoule'
% 'r'
% 'tg'
% 'max_bbaroxyz'
% 'btlor'
% 'max_gradpxyz'

%% reduced DT
% DTr = fitctree(Xtrain(:,fs),Ytrain, 'MinLeafSize',1,...
%     'MaxNumSplits', 807,...
%     'SplitCriterion', 'gdi',...
%     'NumVariablesToSample', 54);

Y_dtR = DTr.predict(Xtest(:,fs));
C_dtR = confusionmat(Ytest,Y_dtR); 
C_dtR = bsxfun(@rdivide,C_dtR,sum(C_dtR,2)) * 100

[FPdtr,TPdtr,~,AUCdtr,OPTROCPTdtr] = perfcurve(Ytest, double(Y_dtR),1);


plotconf(Ytest, Y_dtR,{'E','S-B'}, 'Reduced DT')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_dtreduced.eps'] );

close all

%% reduce TB
[Y_tbr, classifScore_r] = tb_r.predict(Xtest(:,fs));
C_tbr = confusionmat(single(Ytest),single(cell2mat(Y_tbr)=='1')); 
C_tbr = bsxfun(@rdivide,C_tbr,sum(C_tbr,2)) * 100

[FPtbr,TPtbr,~,AUCtbr,OPTROCPTtbr] = perfcurve(single(Ytest), single(cell2mat(Y_tbr)=='1'),1);

plotconf(Ytest, Y_tbr,{'E','S-B'}, 'Reduced TB')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_tbreduced_on_optimalDT.eps'] );

%%  Compare Models with reduced

Cmat = [C_glm C_nn C_da C_knn C_nb C_svm C_svm_std C_dt C_tb C_dtR C_tbr];
labels = { 'Logistic Regression ', 'Neural Network' , 'Discriminant Analysis ',...
    'k-nearest Neighbors ', 'Naive Bayes ', 'Support VM' , 'STD Support VM' ,...
    'Decision Trees ', 'TreeBagger ',...
    'Dec Trees Red. ', 'TreeBagger Red. '};

comparisonPlot( Cmat, labels )

print('-f1','-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/Model_Comparison_rand_all' outname '.eps'])

%% PLOT ROC with reduced DT
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.1,'MR',0.02,'MT',0.05)
plot(FPglm,TPglm,'--','LineWidth',1.5)
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Curves')
set(gca,'FontSize', 18)

hold on
plot(FPnn,TPnn,'LineWidth',1.5)
plot(FPda,TPda,'LineWidth',1.5)
plot(FPknn,TPknn,'LineWidth',1.5)
plot(FPNb,TPNb,'LineWidth',1.5)
plot(FPsvm,TPsvm,'LineWidth',1.5)
plot(FPsvm_std,TPsvm_std,'--','LineWidth',1.5)
plot(FPdt,TPdt,'LineWidth',1.5)
plot(FPdtr,TPdtr,'LineWidth',1.5)
plot(FPtb,TPtb,'LineWidth',1.5)
plot(FPtbr,TPtbr,'LineWidth',1.5)


lg = legend([num2str(AUCglm) '  GLM'], [num2str(AUCnn) '  NN'], ...
    [num2str(AUCda)  '  DA'],...
    [num2str(AUCknn)  '  KNN'],[num2str(AUCNb)  '  NB'],[num2str(AUCsvm)  '  SVM'],...
    [num2str(AUCsvm_std)  '  SVM STD'],[num2str(AUCdt)  '  DT'], [num2str(AUCdtr)  '  DTr'],...
    [num2str(AUCtb)  '  TB'],[num2str(AUCtbr)  '  TBr'],'Location','East');
title(lg,'AREA UNDER CURVE')
legend boxoff
hold off

outname = num2str(num);
print('-f1','-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/ROC_rand_all' outname '.eps'])
FGFG
close(1)
%% Importance of features in Decision Trees
DT = fitctree(Xtrain,Ytrain, 'PredictorSelection','curvature',...
    'Surrogate','on');
imp = predictorImportance(DT);
[~,is]=sort(imp,'descend');
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(imp(is));
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(is);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Feature_importance_DT.eps'] );


%% Importance of features in TreeBagger
TB_imp = TreeBagger(120, Xtest,Ytest,'method','classification','Options',opts,...
   'PredictorSelection','curvature','OOBPredictorImportance','on');

imp = TB_imp.OOBPermutedPredictorDeltaError;
[~,is]=sort(imp,'descend');
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.24,'MR',0.02,'MT',0.05)
bar(imp(is));
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
axis tight;
h = gca;
set(gca,'XTick',1:numel(names)-1,'FontSize',14)
set(gca,'FontSize',18)
h.XTickLabel = names(is);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Feature_importance_TB.eps'] );
