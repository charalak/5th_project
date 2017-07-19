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

%%
TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;

% Responses and features
Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));

rng(1);
irandom = randperm(1e6,100000);

%%

fsAD = [17 10 22 9 4];% 1 19 3];
fsB = [17 43 44 13 9];
fsGB = [17 22 10 9 4];
fsLB = [17 22 10 9 14];
fsLPB = [17 10 22 9 3];
fsRB = [17 22 9 2 10];
fsRUSB = [17 22  10 2 9];
fsTB = [17 22 4 9 15];

fs  = [fsAD fsB fsGB fsLB fsLPB fsRB fsRUSB fsTB];
fs = unique(fs(:));

%%

% disp('AdaBoostM1')
% AdaBoostM1 = fitcensemble(Xtest(irandom,fsAD),Ytest(irandom),'Method','AdaBoostM1',...
%     'NumLearningCycles',300,'Learners','tree');
% disp('Bag')
% Bag = fitcensemble(Xtest(irandom,fsB),Ytest(irandom),'Method','Bag',...
%     'NumLearningCycles',300,'Learners','tree');
disp('GentleBoost')
GentleBoost = fitcensemble(Xtest(irandom,fsB),Ytest(irandom),'Method','Bag',...
    'NumLearningCycles',500,'Learners','tree');
% disp('LogitBoost')
% LogitBoost = fitcensemble(Xtest(irandom,fsLB),Ytest(irandom),'Method','LogitBoost',...
%     'NumLearningCycles',300,'Learners','tree');

%%
% disp('LPBoost')
% LPBoost = fitcensemble(Xtest(irandom,fsLPB),Ytest(irandom),'Method','LPBoost',...
%     'NumLearningCycles',300,'Learners','tree');
% disp('RobustBoost')
% RobustBoost = fitcensemble(Xtest(irandom,fsRB),Ytest(irandom),'Method','RobustBoost',...
%     'NumLearningCycles',300,'Learners','tree');
% disp('RUSBoost')
% RUSBoost = fitcensemble(Xtest(irandom,fsRUSB),Ytest(irandom),'Method','RUSBoost',...
%     'NumLearningCycles',300,'Learners','tree');
% disp('TotalBoost')
% TotalBoost = fitcensemble(Xtest(irandom,fsTB),Ytest(irandom),'Method','TotalBoost',...
%     'NumLearningCycles',300,'Learners','tree');

% save('MODELS_ENSEMBLE_TREES.mat','AdaBoostM1','Bag','GentleBoost',...
%     'GentleBoost','RobustBoost','RUSBoost','fsAD' , 'fsB', 'fsGB', 'fsLB' , 'fsRB' , 'fsRUSB')
%%

% disp('Predicting for ...  AdaBoostM1')
% Y1 = predict(AdaBoostM1,Xtest(:,fsAD));
% disp('Predicting for ...  Bag')
% Y2 = predict(Bag,Xtest(:,fsB));
disp('Predicting for ...  GentleBoost')
Y3 = predict(GentleBoost,Xtest(:,fsB));
% disp('Predicting for ...  LogitBoost')
% Y4 = predict(LogitBoost,Xtest(:,fsLB));

%%
% disp('Predicting for ...  LPBoost')
% Y5 = predict(LPBoost,Xtest(:,fsLPB));
% disp('Predicting for ...  RobustBoost')
% Y6 = predict(RobustBoost,Xtest(:,fsRB));
% disp('Predicting for ...  RUSBoost')
% Y7 = predict(RUSBoost,Xtest(:,fsRUSB));
% disp('Predicting for ...  TotalBoost')
% Y8 = predict(TotalBoost,Xtest(:,fsTB));



%% 
if 0
C_AB = confusionmat(Ytest,Y1);
C_AB = bsxfun(@rdivide,C_AB,sum(C_AB,2)) * 100;

C_B = confusionmat(Ytest,Y2);
C_B = bsxfun(@rdivide,C_B,sum(C_B,2)) * 100;

C_GB = confusionmat(Ytest,Y3);
C_GB = bsxfun(@rdivide,C_GB,sum(C_GB,2)) * 100;

C_LB = confusionmat(Ytest,Y4);
C_LB = bsxfun(@rdivide,C_LB,sum(C_LB,2)) * 100;

% C_LPB = confusionmat(Ytest,Y5);
% C_LPB = bsxfun(@rdivide,C_LPB,sum(C_LPB,2)) * 100;

C_RB = confusionmat(Ytest,Y6);
C_RB = bsxfun(@rdivide,C_RB,sum(C_RB,2)) * 100;

C_RUSB = confusionmat(Ytest,Y7);
C_RUSB = bsxfun(@rdivide,C_RUSB,sum(C_RUSB,2)) * 100;

% C_TB = confusionmat(Ytest,Y8);
% C_TB = bsxfun(@rdivide,C_TB,sum(C_TB,2)) * 100;

Cmat = [C_AB C_B C_GB C_LB  C_RB C_RUSB ];
labels = {'AdaBoost'; 'Bag' ; 'GentleBoost' ; 'LogitBoost' ; ...
     'RobustBoost' ; 'RUSBoost'};

comparisonPlot( Cmat, labels )
print(gcf,'-depsc','-r300','-painters',[sourcefile...
    'cb24ni/5th_project/figures/Ensemble_trees_Comparison_top5features.eps'])
end

%%
plotconf(Ytest, Y3,{'E','S-B'}, 'Bag - 5 features')
% print(gcf, '-depsc', '-r300','-painters', [sourcefile...
%      'cb24ni/5th_project/figures/Conf_Mat_BagOptimized_12features.eps']);

if 0
plotconf(Ytest, Y1,{'E','S-B'}, 'AdaBoost')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_AdaBoost_top5.eps']);
figure
plotconf(Ytest, Y2,{'E','S-B'}, 'Bag')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_Bag_top5.eps']);
figure
plotconf(Ytest, Y3,{'E','S-B'}, 'GentleBoost')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_GentleBoost_top5.eps']);

figure
plotconf(Ytest, Y4,{'E','S-B'}, 'LogitBoost')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_LogitBoost_top5.eps']);


% figure
% plotconf(Ytest, Y5,{'E','S-B'}, 'LPBoost')
% print(gcf, '-depsc', '-r300','-painters', [sourcefile...
%     'cb24ni/5th_project/figures/Conf_Mat_LPBoost_top5.eps']);

figure
plotconf(Ytest, Y6,{'E','S-B'}, 'RobustBoost')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_RobustBoost_top5.eps']);

figure
plotconf(Ytest, Y7,{'E','S-B'}, 'RUSBoost')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
    'cb24ni/5th_project/figures/Conf_Mat_RUSBoost_top5.eps']);
% 
% figure
% plotconf(Ytest, Y8,{'E','S-B'}, 'TotalBoost')
% print(gcf, '-depsc', '-r300','-painters', [sourcefile...
%     'cb24ni/5th_project/figures/Conf_Mat_TotalBoost_top5.eps']);
save('MODELS_ENSEMBLE_TREES_top5.mat','AdaBoostM1','Bag','GentleBoost',...
    'GentleBoost','RobustBoost','RUSBoost','fsAD' , 'fsB', 'fsGB', 'fsLB' , 'fsRB' , 'fsRUSB')
end