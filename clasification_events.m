%% Classification of joule heating events
% In this script we use several supervised machine learning techniques to
% classify observations of features either as impulsive heating events or
% slow burning current sheets.

%% Description of data
% Data are calculate from Bifrost code and its IDL routines that extract
% specific quantities. The features selected here are somehow expected to 
% related with joule heating (magnetic reconnection) events.
%
% The goal is to assest if a pixel given the specific values of the
% features is classified either in one class. The data contains 1e5 random
% pixels (observations) or 67 features (quantities).
% 
% Attributes (features): 
% all are numeric:
% 
%    'b2'    'beta'    'bh'    'cs'    'divb'    'divu'    'ee'
%     'etahall'    'etaohm'    'j2b'    'jb'    'jdb'    'job'
%     'man'    'pressure'    'qgenrad'    'qjoule'    'qspitz'
%     'qvisc'    'r'    'tg'    'z'    'min_bbaroxyz'
%     'max_bbaroxyz'    'min_bpgradxyz'    'max_bpgradxyz'
%     'bpgrad'    'min_bpgradaxyz'    'max_bpgradaxyz'
%     'min_brotjxyz'    'max_brotjxyz'    'brotj'    'min_btlorxyz'
%     'max_btlorxyz'    'btlor'    'min_btloraxyz'
%     'max_btloraxyz'    'btlora'    'min_gradpxyz'
%     'max_gradpxyz'    'gradp'    'min_jxyz'    'max_jxyz'    'j'
%     'min_lfaxyz'    'max_lfaxyz'    'lfa'    'min_stretchxyz'
%     'max_stretchxyz'    'min_tiltxyz'    'max_tiltxyz'
%     'min_vortxyz'    'max_vortxyz'    'vort'  
    
% Predictor:
% 'L'
%
%%  Import Existing Data
%
% We import data as table
TT = load('Users/charalak/Bifrost/cb24ni/5th_project/nop1e5_rand_nof54_50_50/tablenop1e5_rand_nof54_50_50.mat');
TT=TT.TT;
names = TT.Properties.VariableNames;
[nrows, ncols] = size(table2array(TT));
%% Prepare the Data: Response and Predictors
% We can separate the data into response and predictors. This will make it
% easier to call subsequent functions which expect the data in this format.

% Response
Y = TT.L;

tabulate(Y)
% Predictor matrix
X = double(table2array(TT(:,1:end-1)));

%% Cross Validation
% Cross validation is almost an inherent part of machine learning. Cross
% validation may be used to compare the performance of different predictive
% modeling techniques. In this example, we use holdout validation. Other
% techniques including k-fold and leave-one-out cross validation are also
% available.
% 
% In this example, we partition the data into training set and test set.
% The training set will be used to calibrate/train the model parameters.
% The trained model is then used to make a prediction on the test set.
% Predicted values will be compared with actual data to compute the
% confusion matrix. Confusion matrix is one way to visualize the
% performance of a machine learning technique.

% In this example, we will hold 40% of the data, selected randomly, for
% test phase.
cv = cvpartition(height(TT),'HoldOut',0.4);

% Training set
Xtrain = X(cv.training,:);
Ytrain = Y(cv.training,:);
% Test set
Xtest = X(test(cv),:);
Ytest = Y(test(cv),:);

disp('Training Set')
tabulate(Ytrain)
disp('Test Set')
tabulate(Ytest)

%% Generalized Linear Model - Logistic Regression
% In this example, a logistic regression model is leveraged. Response may
% follow normal, binomial, Poisson, gamma, or inverse Gaussian
% distribution. 
% 
% Since the response in this data set is binary, binomial distribution is
% suitable.

% Train the classifier
glm = GeneralizedLinearModel.fit(Xtrain,double(Ytrain),'linear','Distribution','binomial','link','logit');

% Make a prediction for the test set
Y_glm = glm.predict(Xtest);
Y_glm = round(Y_glm) + 1;

% Compute the confusion matrix
C_glm = confusionmat(double(Ytest),Y_glm);
% Examine the confusion matrix for each class as a percentage of the true class
C_glm = bsxfun(@rdivide,C_glm,sum(C_glm,2)) * 100

%% Discriminant Analysis
% Discriminant analysis is a classification method. It assumes that
% different classes generate data based on different Gaussian
% distributions. Linear discriminant analysis is also known as the Fisher
% discriminant. 
% 
% Here, a quadratic discriminant classifier is used.

% Train the classifier
da = ClassificationDiscriminant.fit(Xtrain,Ytrain,'discrimType','pseudoQuadratic');

% Make a prediction for the test set
Y_da = da.predict(Xtest);

% Compute the confusion matrix
C_da = confusionmat(Ytest,Y_da);
% Examine the confusion matrix for each class as a percentage of the true class
C_da = bsxfun(@rdivide,C_da,sum(C_da,2)) * 100

%% Classification Using Nearest Neighbors
% Categorizing query points based on their distance to points in a training
% dataset can be a simple yet effective way of classifying new points.
% Various distance metrics such as euclidean, correlation, hamming,
% mahalonobis or your own distance metric may be used.

% Train the classifier
knn = ClassificationKNN.fit(Xtrain,Ytrain,'Distance','seuclidean');

% Make a prediction for the test set
Y_knn = knn.predict(Xtest);

% Compute the confusion matrix
C_knn = confusionmat(Ytest,Y_knn);
% Examine the confusion matrix for each class as a percentage of the true class
C_knn = bsxfun(@rdivide,C_knn,sum(C_knn,2)) * 100

%% Naive Bayes Classification
% Naive Bayes classification is based on estimating P(X|Y), the probability
% or probability density of features X given class Y. The Naive Bayes
% classification object provides support for normal (Gaussian), kernel,
% multinomial, and multivariate multinomial distributions

% The multivariate multinomial distribution (_mvmn_) is appropriate for
% categorical features
dist = repmat({'normal'},1,ncols-1);
% dist(catPred) = {'mvmn'};

% Train the classifier
% Nb = fitcnb(Xtrain,Ytrain,'Distribution','normal',...
%     'OptimizeHyperparameters','auto',...
%     'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
%     'expected-improvement-plus'),'CrossVal','on');
Nb = fitcnb(Xtrain,Ytrain,'Distribution','normal');

% Nb = NaiveBayes.fit(Xtrain,Ytrain,'Distribution',dist);

% Make a prediction for the test set
Y_Nb = Nb.predict(Xtest);

% Compute the confusion matrix
C_nb = confusionmat(Ytest,Y_Nb);
% Examine the confusion matrix for each class as a percentage of the true class
C_nb = bsxfun(@rdivide,C_nb,sum(C_nb,2)) * 100

%% Support Vector Machines
% Support vector machine (SVM) is supported for binary response variables.
% An SVM classifies data by finding the best hyperplane that separates all
% data points of one class from those of the other class.

opts = statset('MaxIter',30000);
% Train the classifier
svmStruct = svmtrain(Xtrain,Ytrain,'kernel_function','rbf','kktviolationlevel',0.1,'options',opts);

% Make a prediction for the test set
Y_svm = svmclassify(svmStruct,Xtest);
C_svm = confusionmat(Ytest,Y_svm);
% Examine the confusion matrix for each class as a percentage of the true class
C_svm = bsxfun(@rdivide,C_svm,sum(C_svm,2)) * 100

%% Decision Trees
% Classification trees and regression trees are two kinds of decision
% trees. A decision tree is a flow-chart like structure in which internal
% node represents test on an attribute, each branch represents outcome of
% test and each leaf node represents a response (decision taken after
% computing all attributes). Classification trees give responses that are
% nominal, such as 'true' or 'false'. Regression trees give numeric
% responses.

% Train the classifier
t = ClassificationTree.fit(Xtrain,Ytrain);

% Make a prediction for the test set
Y_t = t.predict(Xtest);

% Compute the confusion matrix
C_t = confusionmat(Ytest,Y_t);
% Examine the confusion matrix for each class as a percentage of the true class
C_t = bsxfun(@rdivide,C_t,sum(C_t,2)) * 100


%% Ensemble Learning: TreeBagger
% Bagging stands for bootstrap aggregation. Every tree in the ensemble is
% grown on an independently drawn sample of input data. To compute
% prediction for the ensemble of trees, TreeBagger takes an average of
% predictions from individual trees (for regression) or takes votes from
% individual trees (for classification). Ensemble techniques such as
% bagging combine many weak learners to produce a strong learner.
% 
% From a marketing perspective, as we are creating this predictive model,
% it may be more important for us to classify *_yes_* correctly than a
% *_no_*. If that is the case, we can include our opinion using the _cost_
% matrix. Here, _cost_ matrix specifies that it is 5 times more costly to
% classify a *_yes_* as a *_no_*.

% Cost of misclassification
cost = [0 1
        1 0];
opts = statset('UseParallel',true);
% Train the classifier
tb = TreeBagger(150,Xtrain,Ytrain,'method','classification','Options',opts,'OOBVarImp','on','cost',cost);

% Make a prediction for the test set
[Y_tb, classifScore] = tb.predict(Xtest);
Y_tb = nominal(Y_tb);

% Compute the confusion matrix
C_tb = confusionmat(nominal(Ytest),Y_tb);
% Examine the confusion matrix for each class as a percentage of the true class
C_tb = bsxfun(@rdivide,C_tb,sum(C_tb,2)) * 100

%% Compare Results
% This visualization function is making use of a couple files downloaded
% from <http://www.mathworks.com/matlabcentral/ MATLAB Central>, the user
% community website. We are leveraging social computing along the way to
% help us in our effort.

Cmat = [C_glm(1:2,2:3) C_da C_knn C_nb C_svm C_t C_tb(1:2,3:4)];
labels = { 'Logistic Regression ', 'Discriminant Analysis ',...
    'k-nearest Neighbors ', 'Naive Bayes ', 'Support VM ', 'Decision Trees ', 'TreeBagger '};

comparisonPlot( Cmat, labels )


%% ROC Curve for Classification by TreeBagger
% Another way of exploring the performance of a classification ensemble is
% to plot its Receiver Operating Characteristic (ROC) curve.

[xx,yy,~,auc] = perfcurve(Ytest, classifScore(:,2),1);
figure;
plot(xx,yy,'LineWidth',2)
% xlim([0 0.02])
set(gca,'FontSize',18)
xlabel('False positive rate');
ylabel('True positive rate')
tl = title('ROC curve for ''event'', predicted vs. actual (Test Set)');
set(tl, 'FontSize',16)
text(0.4,0.25,{'TreeBagger with full feature set',...
    strcat('Area Under Curve = ',num2str(auc))},'EdgeColor','k','FontSize',18);

%% Estimating a Good Ensemble Size of Trees
% Examining the out-of-bag error may give an insight into determining a
% good ensemble size. 

figure;
plot(oobError(tb),'LineWidth',2);
xlabel('Number of Grown Trees');
ylabel('OOB Classfic. Error/Misclassif. Prob.');
set(gca,'FontSize',18)

%% Estimating Feature Importance
% Feature importance measures the increase in prediction error if the
% values of that variable are permuted across the out-of-bag observations.
% This measure is computed for every tree, then averaged over the entire
% ensemble and divided by the standard deviation over the entire ensemble.

figure;
bar(tb.OOBPermutedVarDeltaError);
ylabel('Out-Of-Bag Feature Importance');
xlabel('# Feature')
axis tight;
set(gca,'XTick',1:3:numel(names)-1,'FontSize',18)
[~,idxvarimp] = sort(tb.OOBPermutedVarDeltaError, 'descend');

%% Sequential Feature Selection
% Feature selection reduces the dimensionality of data by selecting only a
% subset of measured features (predictor variables) to create a model.
% Selection criteria involves the minimization of a specific measure of
% predictive error for models fit to different subsets.
% 
% Sequential feature selection can be computationally intensive. It can
% benefit significantly from parallel computing.

opts = statset('UseParallel',true);
critfun = @(Xtr,Ytr,Xte,Yte)featureImp(Xtr,Ytr,Xte,Yte,'TreeBagger');
% The top 5 features determined in the previous step have been included,
% to reduce the number of combinations to be tried by sequentialfs
[fs,history] = sequentialfs(critfun,Xtrain,Ytrain,'options',opts,'keepin',idxvarimp(1:5));
disp('Included features:');
disp(names(fs)');

%% TreeBagger with Reduced Feature Set

opts = statset('UseParallel',true);
tb_r = TreeBagger(120, Xtrain(:,fs),Ytrain,'method','Options',opts,'cost',cost);
[Y_tb_r, classifScore] = tb_r.predict(Xtest(:,fs));
Y_tb_r = nominal(Y_tb_r);
C_tb_r = confusionmat(nominal(Ytest),Y_tb_r);
C_tb_r = bsxfun(@rdivide,C_tb_r,sum(C_tb_r,2)) * 100

%% Compare Results
Cmat = [C_glm(1:2,2:3) C_da C_knn C_nb C_svm C_t C_tb(1:2,3:4) C_tb_r(1:2,3:4)];
labels = { 'Logistic Regression ', 'Discriminant Analysis ',...
    'k-nearest Neighbors ', 'Naive Bayes ', 'Support VM ', 'Decision Trees ', 'TreeBagger ' , 'Reduced TB '};

comparisonPlot( Cmat, labels )

%% ROC Curve for Classification by Reduced TreeBagger

[xx,yy,~,auc] = perfcurve(Ytest, classifScore(:,2),1);
figure;
plot(xx,yy)
xlabel('False positive rate'); 
ylabel('True positive rate')
title('ROC curve for ''yes'', predicted vs. actual response (Test Set)')
text(0.5,0.25,{'TreeBagger with reduced feature set',strcat('Area Under Curve = ',num2str(auc))},'EdgeColor','k');
