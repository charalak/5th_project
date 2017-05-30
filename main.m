% This project tries to built a model using ML for joule heating
% classification. 
% SUPERVISED MODEL
% Train data on clustered joule heating events
%-------------------------------------------------------
% Improve Neural Network Generalization and Avoid Overfitting
% http://se.mathworks.com/help/nnet/ug/improve-neural-network-generalization-and-avoid-overfitting.html#bss4gz0-32

%-------------------------------------------------------
clear all;
%% load input and target data
input = load('/Users/charalak/Bifrost/cb24ni/5th_project/nop_1e5_rand/input_nn1e5_rand.mat','input2');
input = input.input2; input = input';
target = load('/Users/charalak/Bifrost/cb24ni/5th_project/nop_1e5_rand/target_nn1e5_rand.mat','L2');
target = target.L2; 
% target = target(1,:);
target = target';


Xtrain = input(1:70000,:);
YTrain = target(1:70000,:);
xtest = input(70001:end,:);
ytest = target(70001:end,:);

misclass = NN_misclass(Xtrain,YTrain,xtest,ytest)
%% Multiple Neural Networks
    % to improve generalization, train multiple neural networks and average
    % their outputs.
    
%% Early Stopping


%% Random Data Division (dividerand)
% You can divide the input data randomly so that 60% of the samples are 
% assigned to the training set, 20% to the validation set, and 20% to the 
% test set, as follows:

% [trainP,valP,testP,trainInd,valInd,testInd] = dividerand(p);
% This function not only divides the input data, but also returns indices 
% so that you can divide the target data accordingly using divideind:

% [trainT,valT,testT] = divideind(t,trainInd,valInd,testInd);

%% sequential feature selection to fit the model
opts = statset('display','iter');
% trainbr
% c = cvpartition(target,'k',10);  % create 10-fold cross validation
[in,history] = sequentialfs(@NN_misclass,input,target,'cv',10,'options',opts)