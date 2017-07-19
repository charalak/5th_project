function criterion = featureImp(Xtrain,Ytrain,Xtest,Ytest,modeltype)
%featureImp This function computes the misclassification rate for a given
%modeltype.
%   SEQUENTIALFS expects one to compute the criterion which the method
%   seeks to minimize over all feasible feature subsets. In this particular
%   case, we are computing the misclassification rate. This function
%   incorporates the flexibility for one to try different models, as
%   specified by the modeltype argument.

% Copyright 2013 The MathWorks, Inc.

switch modeltype
    case 'LinearModel'
        lm = fitlm(Xtrain,double(Ytrain));
        
        Y_lm = lm.predict(Xtest);
        Y_lm = round(Y_lm);
        Y_lm(Y_lm < 1) = 1;
        Y_lm(Y_lm > 2) = 2;
        Cmat = confusionmat(double(Ytest),Y_lm);
    case 'GeneralizedLinearModel'
        glm = fitglm(Xtrain,double(Ytrain),'quadratic','Distribution','normal','link','identity');
        Y_glm = glm.predict(Xtest);
        Y_glm = round(Y_glm);% + 1;
        Cmat = confusionmat(logical(Ytest),logical(Y_glm));
    case 'ClassificationDiscriminant'
        da = fitcdiscr(Xtrain, Ytrain, 'DiscrimType', 'Quadratic');
        Y_da = da.predict(Xtest);
        Cmat = confusionmat(Ytest,Y_da);
    case 'ClassificationKNN'
        knn = fitcknn(Xtrain,Ytrain,'Distance','seuclidean');
        Y_knn = knn.predict(Xtest);
        Cmat = confusionmat(Ytest,Y_knn);
    case 'NaiveBayes'
        Nb = fitcnb(Xtrain,Ytrain);
        Y_Nb = Nb.predict(Xtest);
        Cmat = confusionmat(Ytest,Y_Nb);
    case 'svm'
        svmStruct = fitcsvm(Xtrain,Ytrain,'method','LS','kernel_function','rbf');
        Y_svm = ClassificationSVM(svmStruct,Xtest);
        Cmat = confusionmat(Ytest,Y_svm);
    case 'ClassificationTree'
%         t = ClassificationTree.fit(Xtrain,Ytrain);
      t =  fitctree(Xtrain,Ytrain, 'MinLeafSize',1,...
    'MaxNumSplits', 807,...
    'SplitCriterion', 'gdi',...
    'NumVariablesToSample', 54);
        Y_t = t.predict(Xtest);
        Cmat = confusionmat(Ytest,Y_t);
    case 'TreeBagger'
        cost = [0 1
                1 0];
        tb = TreeBagger(25,Xtrain,Ytrain,'method','classification','cost',cost);
        Y_tb = tb.predict(Xtest);
        Y_tb = nominal(Y_tb);
        %Cmat = confusionmat(nominal(Ytest),Y_tb);
        Cmat =confusionmat(categorical(Ytest,[0 1]),categorical(Y_tb));
    case 'NN'
        [~, net] = NNfun(Xtrain,Ytrain);
        Y_nn = net(Xtest');
        Y_nn = round(Y_nn');
        Cmat = confusionmat(Ytest,Y_nn);
    otherwise
        error('Modeltype should be one of the following: LinearModel, GeneralizedLinearModel, ClassificationDiscriminant, ClassificationKNN, NaiveBayes, svm, ClassificationTree, TreeBagger or NN')
end

% Confusion matrix in percentage/100
Cmat = bsxfun(@rdivide,Cmat,sum(Cmat,2));

% Misclassification rate for each class
misclassification = 1 - diag(Cmat);

criterion = sum(misclassification);