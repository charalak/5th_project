clear;
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
% MODELS_REDUCED_on_DT = load([modelsfile 'MODELS_REDUCED_on_DT.mat']);
% fs = MODELS_REDUCED_on_DT.fs;
fs = [1:54];
fs = [17 10 22 9 4 1 19 3 11 14 18 15 5 6 41 12 44]; % qjoule j2b z etaohm (cs=4)
% fs = [17];
TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;
% Responses and features
Xtest = double(table2array(TT(:,1:end-1)));
Ytest = TT.L;
rng(1);
irandom = randperm(1e6,10000);

Xtest = Xtest(irandom,fs);

Ytest = Ytest(irandom);
% Xtest = Xtest(Ytest==1,:);
% Xtest = zscore(Xtest,0,1);
%% Choose parameter specification 

options = statset('UseParallel',1,'MaxIter',10000);
k = 36:41;
nK = numel(k);
Sigma = {'diagonal','full'};
nSigma = numel(Sigma);
SharedCovariance = {true,false};
SCtext = {'true','false'};
nSC = numel(SharedCovariance);
RegularizationValue = 0.01;
% options = statset('MaxIter',10000);

%% Fit the GMMs using all parameter combination.
% Compute the AIC and BIC for each fit. Track the terminal convergence status of each fit.

% Preallocation
gm = cell(nK,nSigma,nSC);
aic = zeros(nK,nSigma,nSC);
bic = zeros(nK,nSigma,nSC);
converged = false(nK,nSigma,nSC);

% Fit all models
for m = 1:nSC;
    for j = 1:nSigma;
        for i = 1:nK;
            gm{i,j,m} = fitgmdist(Xtest,k(i),...
                'CovarianceType',Sigma{j},...
                'SharedCovariance',SharedCovariance{m},...
                'RegularizationValue',RegularizationValue,...
                'Options',options);
            aic(i,j,m) = gm{i,j,m}.AIC;
            bic(i,j,m) = gm{i,j,m}.BIC;
            converged(i,j,m) = gm{i,j,m}.Converged;
        end
    end
end

allConverge = (sum(converged(:)) == nK*nSigma*nSC)

%% Plot separate bar charts to compare the AIC and BIC 
% gm is a cell array containing all of the fitted gmdistribution model objects.
% All of the fitting instances converged.
% Plot separate bar charts to compare the AIC and BIC among all fits. Group the bars by k.

figure;
bar(reshape(aic,nK,nSigma*nSC));
title('AIC For Various $k$ and $\Sigma$ Choices','Interpreter','latex');
xlabel('$k$','Interpreter','Latex');
ylabel('AIC');
legend({'Diagonal-shared','Full-shared','Diagonal-unshared',...
    'Full-unshared'});

figure;
bar(reshape(bic,nK,nSigma*nSC));
title('BIC For Various $k$ and $\Sigma$ Choices','Interpreter','latex');
xlabel('$c$','Interpreter','Latex');
ylabel('BIC');
legend({'Diagonal-shared','Full-shared','Diagonal-unshared',...
    'Full-unshared'});

%%
[min_aic, imin_aic] = min(aic(:));
[min_bic, imin_bic] = min(bic(:));

if min_aic <= min_bic
    disp('AIC')
    imin = imin_aic;
else
    disp('BIC')
    imin = imin_aic;
end

[qq,ww,zz]=ind2sub(size(aic),imin);


gmBest = gm{qq,ww,zz};
clusterX = cluster(gmBest,Xtest);
kGMM = gmBest.NumComponents;


figure;
gscatter(log10(Xtest(:,1)),log10(Xtest(:,2)),clusterX);