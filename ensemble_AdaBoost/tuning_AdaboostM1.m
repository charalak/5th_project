%% Create Predictive Ensemble Using CV
% While searching for an optimal complexity level, tune the learning rate to
% minimize the number of learning cycles

% To search for the optimal tree-complexity level:
% 
% 1 - Cross-validate a set of ensembles. Exponentially increase the tree-complexity 
% level for subsequent ensembles from decision stump (one split) to at most
% n - 1 splits. n is the sample size. Also, vary the learning rate for each
% ensemble between 0.1 to 1.

% 2 - Estimate the cross-validated misclassification rate of each ensemble.

% 3 - For tree-complexity level  $j$,  $j=1...J$, compare the cumulative, 
% cross-validated misclassification rate of the ensembles by plotting them
% against number of learning cycles. Plot separate curves for each learning 
% rate on the same figure.

% 4 - Choose the curve that achieves the minimal misclassification rate, and note
% the corresponding learning cycle and learning rate.

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
fs = [17, 44, 43, 10,9,19, 42] ; % importance estimates AdaBoostM1, prunOn, SurrogateOn 
% Responses and features
 Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));
clearvars TT

rng(1);
irandom = randperm(1e6,50000);
method = 'AdaBoostM1';
prunkey = 'On';
surrogatekey = 'On';
cvkey = 'On';

%% Deep and stump ensemble trees for reference

% rng(1); % For reproducibility
% MdlDeep = fitctree(Xtest,Ytest,'CrossVal','on','MergeLeaves','off',...
%     'MinParentSize',1);
% MdlStump = fitctree(Xtest,Ytest,'MaxNumSplits',1,'CrossVal','on');


% %%
% n = size(Xtest,1);
% m = floor(log(n - 1)/log(3));
% learnRate = [0.1 0.25 0.5 1];
% numLR = numel(learnRate);
% maxNumSplits = 3.^(0:m);
% numMNS = numel(maxNumSplits);
% numTrees = 150;
% Mdl = cell(numMNS,numLR);

%%
% t = templateTree('Surrogate',surrogatekey,'Prune',prunkey, ...
%     'MaxNumSplits',mnspl);
% Mdl = fitcensemble(Xtest(irandom,:),Ytest(irandom),'Method',method,...
%     'CrossVal',cvkey ,...
%     'NumLearningCycles',500,'Learners',t);

%% Hyperaprameter optimization

t = templateTree('Surrogate',surrogatekey,'Prune',prunkey);
% variabledesc = hyperparameters('fitcensemble',Xtest,Ytest,t);
% variabledesc(1,1).Range{1} = '';
% variabledesc(1,1).Range{2} = '';
% variabledesc(1,1).Range{3} = '';
% variabledesc(1,1).Range{5} = '';
Mdl = fitcensemble(Xtest(irandom,fs),Ytest(irandom),'Method',method,...
    'NumLearningCycles',469,'LearnRate',0.11648,...
    'Learners',t,'OptimizeHyperparameters',...
    {'MaxNumSplits','MinLeafSize'},...
    'HyperparameterOptimizationOptions',struct('Optimizer','bayesopt',...
    'AcquisitionFunctionName', 'expected-improvement-plus',...
    'Verbose',1));



print('-f2', '-depsc', '-r300','-painters', 'AdaBoost_opt_MNS_MLS.eps');
