%%  path
if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
end
addpath('~/Bifrost/IDL/5th_project/')
%% load data
filename = 'nop1e6_rand_nof54_50_50_rng20';
TT = load([sourcefile 'cb24ni/5th_project/' filename '/table' filename '.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;
num = height(TT);

%% Response and features
fs = [17 43 44 13 9 10 22 19 42 12];
% qjoule max_jxyz j job etaohm j2b z qvisc min_jxyz jdb

Ytest = TT.L;
tabulate(Ytest)
% Predictor matrix
Xtest = double(table2array(TT(:,fs)));

%% Build Model
disp('Building Model ....')
BagEsnsemble = fitcensemble(Xtest,Ytest,'Method','Bag',...
    'NumLearningCycles',344,'Learners','tree');

%% Predict Responses
disp('Predicting Responses ....')
filename2 = 'nop1e5_rand_nof54_50_50';
TT2 = load([sourcefile 'cb24ni/5th_project/' filename2 '/table' filename2 '.mat']);
TT2=TT2.TT;
Ytest2 = TT2.L;
% Predictor matrix
Xtest2 = double(table2array(TT2(:,fs)));
Ypredict2 = predict(BagEsnsemble,Xtest2);

%% Plot and save confusion matrix & model
plotconf(Ytest2, Ypredict2,{'E','S-B'}, 'Bag Ensemble - top 10 features')
print(gcf, '-depsc', '-r300','-painters', [sourcefile...
      'cb24ni/5th_project/figures/Conf_Mat_BagOptimized_top10features.eps']);

save([modelsfile 'ensemble_bag_top10/Mdl_ensemble_bag_top10.mat'],...
    'BagEsnsemble','fs','names','Ypredict')

