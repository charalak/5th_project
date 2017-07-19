%% k-medoids Clustering
% !!! UPDATE: NOT CONCLUSIVE WHAT I AM TRYING TO FIND !!!

% k-medoids clustering is a partitioning method commonly used in domains that
% require robustness to outlier data, arbitrary distance metrics, or ones for
% which the mean or median does not have a clear definition.
% 
% It is similar to k-means, and the goal of both methods is to divide a set 
% of measurements or observations into k subsets or clusters so that the 
% subsets minimize the sum of distances between a measurement and a center of
% the measurement's cluster. In the k-means algorithm, the center of the 
% subset is the mean of measurements in the subset, often called a centroid.
% In the k-medoids algorithm, the center of the subset is a member of the
% subset, called a medoid.
% 
% The k-medoids algorithm returns medoids which are the actual data points in
% the data set. This allows you to use the algorithm in situations where the 
% mean of the data does not exist within the data set. This is the main
% difference between k-medoids and k-means where the centroids returned by 
% k-means may not be within the data set. Hence k-medoids is useful for 
% clustering categorical data where a mean is impossible to define or 
% interpret.
% 
% The function kmedoids provides several iterative algorithms that minimize
% the sum of distances from each object to its cluster medoid, over all 
% clusters. One of the algorithms is called partitioning around medoids 
% (PAM) [1] which proceeds in two steps.
% 
% Build-step: Each of k clusters is associated with a potential medoid.
% This assignment is performed using a technique specified by the 'Start'
% name-value pair argument. 
% Swap-step: Within each cluster, each point is tested as a potential medoid
% by checking if the sum of within-cluster distances gets smaller using that 
% point as the medoid. If so, the point is defined as a new medoid. Every
% point is then assigned to the cluster with the closest medoid.
% The algorithm iterates the build- and swap-steps until the medoids do not
% change, or other termination criteria are met.
% 
% You can control the details of the minimization using several optional
% input parameters to kmedoids, including ones for the initial values of the
% cluster medoids, and for the maximum number of iterations. By default,
% kmedoids uses the k-means++ algorithm for cluster medoid initialization 
% and the squared Euclidean metric to determine distances.

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
% fs = [1:54];
% fs = [17 10 22 9 4 1 19 3 11 14 18 15 5 6 41 12 44]; % qjoule j2b z etaohm (cs=4)
% fs = [17 43 44 13 9 10 22 19 42 12]; % top 10 bag ensemble
fs = 1:10;
filename = 'nop1e6_BagEnsemble_top10_multi_class';
TT = load([sourcefile 'cb24ni/5th_project/' filename '/table' filename '.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;
% Responses and features
Xtest = double(table2array(TT(:,1:end-1)));
Ytest = TT.L;
rng(1);
% idx1 = find((Ytest>=1)& (Ytest<=255));
idx1 = find(Ytest>=1);

idx2 = find(Ytest==0);

% idx = find(Ytest==0);
% idx = randperm(numel(idx),150);
% Xtest = Xtest(idx,fs);
Xtest = Xtest(idx,:);
% Ytest = Ytest(idx);
% Xtest = zscore(Xtest,0,1);
% clearvars TT



%% K-medoids
if 0
options = statset('UseParallel',1,'MaxIter',500);
x=[]; sil = [];
for i=24
    range('default');
dist = 'mahalanobis';
[idx2,C,sumd,D] = kmedoids(Xtest,i,'Algorithm', 'clara',...
    'Options',options,'Distance',dist,...
    'Replicates',i+1);
[silh2,h] = silhouette([],idx2,pdist(Xtest,dist));
cluster2 = mean(silh2);
% eva = evalclusters(Xtest,i,'silhouette','Klist',[1:6])
 disp(['num of clusters =  ' num2str(i) '   silhuent eval = ' num2str(cluster2)])
%  tabulate(idx2);
x = [x i];
sil = [sil cluster2];

 end

plot(x,sil,'o')
[~,imax] = max(sil);
x(imax)
end