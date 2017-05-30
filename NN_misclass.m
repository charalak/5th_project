function [misclass, ypred]= NN_misclass(XTrain,YTrain,xtest,ytest)
% check size
[Nr,Nc] = size(XTrain);
if Nr>Nc
    XTrain = XTrain'; 
end
[Nr,Nc] = size(YTrain);
if Nr>Nc
    YTrain = YTrain'; 
end
[Nr,Nc] = size(xtest);
if Nr>Nc
    xtest = xtest'; 
end
[Nr,Nc] = size(ytest);
if Nr>Nc
    ytest = ytest'; 
end


% Feedforward neural network
% net = feedforwardnet(10);
% Pattern recognition network
train_func = 'trainscg';
train_func = 'trainlm'; % <<
% trainbr
net = feedforwardnet(70,'trainbr');

%-------------------
%   Modified Performance Function
% net.divideFcn = '';
% net.trainParam.epochs = 1000;
% net.trainParam.goal = 1e-9;
% net.performParam.regularization = 0.5;
%-------------------

% Configure network inputs and outputs to best match input and target data
% net = configure(net,XTrain,YTrain);
% Train neural network
[net,~] = train(net,XTrain,YTrain,'useParallel','yes','showResources','yes');   
ypred = net(xtest);    %prediction

% https://se.mathworks.com/matlabcentral/answers/127061-low-performance-of-neural-network-using-logsig-for-output-layer
% default output transfer functions are tansig for patternnet and purelin
% for feedforwardnet and fitnet
% Therefore, changing the output function of feedforwardnet from purelin 
% to logsig will not yield the correct results because the range of logsig 
% is not {-1,1}.
% If you want to use logsig, normalized targets must be in {0,1}; 
% The best way to do this is just to use mapminmax BEFORE train to convert 
% targets to { 0,1 }. Then disable mapminmax during training.
% This may also be a way of using softmax.


ypred = ypred>=0.5;
ytest2 = ytest(1,:);
ypred2 = ypred(1,:);
% perf = perform(net,ytest2,ypred2)
%calculate missclassification rate
misclass = sum(ytest2 ~= ypred2);
end