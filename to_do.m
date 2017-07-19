
%% Compare accuracies of two classification models by repeated cross validation

% Method: 1 -- testckfold
% testckfold statistically assesses the accuracies of two classification 
% models by repeatedly cross validating the two models, determining the
% differences in the classification loss, and then formulating the test
% statistic by combining the classification loss differences. This type of 
% test is particularly appropriate when sample size is limited.

% 10 x 10 t-tests
[h, p, e1, e2] = testckfold(C1,C2,X1,X2,Y , 'Alternative', 'higher', 'Test', '10x10t',  'Options', statsset('UseParallel',true)); 
% h = test decision
%  p-value for the hypothesis test (p) and the respective classification 
% losses for each cross-validation run and fold (e1 and e2).

% C1 is at most as accurate as C2

% Method: 2 -- testcholdout

%  returns the test decision, by conducting the mid-p-value McNemar test,
%  from testing the null hypothesis.
% More details about this test: https://se.mathworks.com/help/stats/testcholdout.html#bup0p8g-1
rng(1);                             % For reproducibility
CVP = cvpartition(Y,'holdout',0.5);
idxTrain = training(CVP);           % Training-set indices
idxTest = test(CVP); 

MdlSVM = fitcsvm(X(idxTrain,:),Y(idxTrain));
MdlBag = fitensemble(X(idxTrain,:),Y(idxTrain));
YhatSVM = predict(MdlSVM,X(idxTest,:));
YhatBag = predict(MdlBag,X(idxTest,:));
[h, p, e1 , e2] = testcholdout(YHat1,YHat2,Y(idxTest));
% testcholdout statistically assesses the accuracies of two classification
% models. The function first compares their predicted labels against the true
% labels, and then it detects whether the difference between the 
% misclassification rates is statistically significant.

%% Feature Selection

% Method 1:  PCA for feature selection

% Method 2: rendom trees :
% Train an ensemble of 100 boosted classification trees using AdaBoostM1 
% and the entire set of predictors. Inspect the importance measure for each predictor.

% -------------------------------------------------------------------------
% C = fitcensemble(X,Y,'AdaBoostM1',nTrees,'Tree');
% 'AdaBoostM1'	Adaptive boosting	Binary only
% 'Bag'	Bootstrap aggregating (e.g., random forest)	Binary and multiclass

% predImp = predictorImportance(C);
% 
% figure;
% bar(predImp);
% h = gca;
% h.XTick = 1:2:h.XLim(2);
% title('Predictor Importances');
% xlabel('Predictor');
% ylabel('Importance measure');

% Identify the top five predictors in terms of their importance.

% [~,idxSort] = sort(predImp,'descend');
% idx5 = idxSort(1:5);

% Test whether the two models have equal predictive accuracies. 
% Specify the reduced data set and then the full predictor data. 
% Use parallel computing to speed up computations.

% Options = statset('UseParallel',true);
% [h,p,e1,e2] = testckfold(C,C,X(:,idx5),X,Y,'Options',Options)
addpath('~/Documents/MATLAB/')
opt = statset('pca'); opt.MaxIter = 4000; opt.TolFun=1e-10; opt.Display='on';
[wcoeff,score,latent,tsquared,explained] = pca(Xtest(1:10000,:),...
    'VariableWeights','variance','Options',opt);
coefforth = inv(diag(std(Xtest(1:10000,:))))*wcoeff;

% [h,ptx,pty, coefs] = biplot_kanellas(coefforth(:,1:2),'scores',score(:,1:2));
% ptx = ptx(1,:); ptx = ptx'; pty = pty(1,:); pty = pty';