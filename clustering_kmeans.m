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
%%

options = statset('UseParallel',1);

for i=15
    
[idx2,C,sumd,D] = kmeans(Xtest,i,'Options',options,'Distance','cos',...
    'Replicates',16);
[silh2,h] = silhouette(Xtest,idx2,'cos');
cluster2 = mean(silh2);
 disp(['num of clusters =  ' num2str(i) '   silhuent eval = ' num2str(cluster2)])
%  tabulate(idx2);
 end


%% Evaluate clustering solutions
% rng('default');  % For reproducibility
% eva = evalclusters(Xtest,'kmeans','silhouette','KList',[1:17])
