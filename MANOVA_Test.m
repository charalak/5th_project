%% Multivariate Analysis of Variance (MANOVA)
% This script takes the 54 features of 1e6 observations grouped as heating
% events (Ytest==1), and slow-burning heating (Ytest==0)

% Input = Xtest : m x n matrix : m observations x n features
%         Ytest : m x 1 array  : 0 slow burning, 1 impulsive event

%% Introduction
% http://userwww.sfsu.edu/efc/classes/biol710/manova/manovanewest.htm

% Multivariate analysis of variance (MANOVA) is simply an ANOVA with 
% several dependent variables.  That is to say, ANOVA tests for the 
% difference in means between two or more groups, while MANOVA tests for 
% the difference in two or more vectors of means.
% 
% For example, we may conduct a study where we try two different textbooks,
% and we are interested in the students' improvements in math and physics. 
% In that case, improvements in math and physics are the two dependent
% variables, and our hypothesis is that both together are affected by the
% difference in textbooks.  

% A multivariate analysis of variance (MANOVA) 
% could be used to test this hypothesis. Instead of a univariate F value,
% we would obtain a multivariate F value (Wilks' ?) based on a comparison of
% the error variance/covariance matrix and the effect variance/covariance
% matrix.  Although we only mention Wilks' ? here, there are other statistics
% that may be used, including Hotelling's trace and Pillai's criterion.  
% The "covariance" here is included because the two measures are probably 
% correlated and we must take this correlation into account when performing 
% the significance test.

% Assumptions
% The MANOVA test makes the following assumptions about the data in X:
% The populations for each group are normally distributed.
% The variance-covariance matrix is the same for each population.
% All observations are mutually independent.
clear
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

%% Responses and features
Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));
%% One-way multivariate analysis of variance

%https://se.mathworks.com/help/stats/manova1.html
% performs a one-way Multivariate Analysis of Variance (MANOVA) for
% comparing the multivariate means of the columns of X, grouped by group.

% The function returns d, an estimate of the dimension of the space 
% containing the group means. manova1 tests the null hypothesis that the
% means of each group are the same n-dimensional multivariate vector, and 
% that any difference observed in the sample X is due to random chance.
% If d = 0, there is no evidence to reject that hypothesis. If d = 1, then 
% you can reject the null hypothesis at the 5% level, but you cannot reject 
% the hypothesis that the multivariate means lie on the same line.

[d,p,stats] = manova1(Xtest,Ytest)

if d==1 
    disp(['Dimension d is :  ' num2str(d)])
    disp('NULL HYPOTHESIS IS --- REJECTED ---')
elseif d==0
    disp('NULL HYPOTHESIS IN --- NOT REJECTED ---')
else 
    disp(['Dimension d is :  ' num2str(d)])
end


%% Mihalanobis distance betwwen each pair of group means

% The Mahalanobis distance is a measure of the distance between
% a point P and a distribution D, introduced by P. C. Mahalanobis in 1936.[1]
% It is a multi-dimensional generalization of the idea of measuring how many
% standard deviations away P is from the mean of D. This distance is zero 
% if P is at the mean of D, and grows as P moves away from the mean: along
% each principal component axis, it measures the number of standard
% deviations from P to the mean of D. If each of these axes is rescaled
% to have unit variance, then Mahalanobis distance corresponds to
% standard Euclidean distance in the transformed space. Mahalanobis 
% distance is thus unitless and scale-invariant, and takes into account
% the correlations of the data set.
% https://en.wikipedia.org/wiki/Mahalanobis_distance
% [1]  Mahalanobis, Prasanta Chandra (1936). "On the generalised distance 
% in statistics" (PDF). Proceedings of the National Institute of Sciences 
% of India. 2 (1): 49?55. Retrieved 2016-09-27.    

disp(['Mihalanobis distance betwwen each pair of group means =  '...
    num2str(max(max(stats.gmdist)))])

% Mahalanobis distances from each point to the mean of its group

% [~, isort_mdist] = sort(stats.mdist,'descend');

%% Histograms of distances from group means
fig = figure('position',[1 1 1000 700])  ;
subaxis(1,1,1,'SpacingVert',0.0,'ML',0.08,'MB',0.1,'MR',0.02,'MT',0.01)
[N1, edges1] = histcounts(log10(stats.mdist(Ytest==1)));
centers1 = 0.5*(10.^edges1(2:end)+10.^edges1(1:end-1));

loglog(centers1,N1,'LineWidth',1.5,'Color',[ 0    0.4470    0.7410]);
hold on;

[N0, edges0] = histcounts(log10(stats.mdist(Ytest==0)));
centers0 = 0.5*(10.^edges0(2:end)+10.^edges0(1:end-1));

loglog(zeros(1,2)+mean(stats.mdist(Ytest==1)),[1 max(N0)],'--','Color',...
    [ 0    0.4470    0.7410],'LineWidth',1.5)
loglog(centers0,N0,'LineWidth',1.5,'Color',[0.9290 0.6940 0.1250])
loglog(zeros(1,2)+mean(stats.mdist(Ytest==0)),[1 max(N0)],'--','Color',...
    [0.9290 0.6940 0.1250],'LineWidth',1.5)

axis tight;
set(gca,'XTick',[1e1 1e2 1e3 1e4 1e5],'FontSize',16)
xlabel('Mihalanobis Distance')
ylabel('Counts')
legend('Event',['\mu = ' num2str(round(mean(stats.mdist(Ytest==1))))],...
    'S-B',['\mu = ' num2str(round(mean(stats.mdist(Ytest==0))))])
text(0.7,0.4, ['P_E ( Dist. > \mu ) = '...
    num2str(sum(stats.mdist(Ytest==1)>mean(stats.mdist(Ytest==1)))/numel(Ytest),'%.2f')], ...
    'Units', 'normalized','Color', [ 0    0.4470    0.7410], 'FontSize',16)
text(0.7,0.3, ['P_{S-B} ( Dist. > \mu ) = '...
    num2str(sum(stats.mdist(Ytest==0)>mean(stats.mdist(Ytest==0)))/numel(Ytest),'%.2f')], ...
    'Units', 'normalized','Color', [0.9290 0.6940 0.1250], 'FontSize',16)
hold off;

% print(gcf, '-depsc', '-r300','-painters', [sourcefile...
%     'cb24ni/5th_project/figures/Hist_Groups_Mihalanobis_dist.eps'] );

%% Canonical variables
% The canonical variables C are linear combinations of the original
% variables, chosen to maximize the separation between groups. 
% Specifically, C(:,1) is the linear combination of the X columns that has
% the maximum separation between groups. This means that among all possible
% linear combinations, it is the one with the most significant F statistic
% in a one-way analysis of variance. C(:,2) has the maximum separation 
% subject to it being orthogonal to C(:,1), and so on.

%% Wilks' lambda
% Wilks' lambda is a direct measure of the proportion of variance in
% the combination of dependent variables (features) that is unaccounted for by the
% independent variable (the grouping variable or factor).

% If lambda is small  then it suggests that there is an effect from the 
% grouping variable and that the groups have different mean values.

% In other words, the closer to zero the statistic is, the more the variable 
% in question contributes to the model. 

% You would reject the null hypothesis when Wilk?s lambda is close to zero, 
% although this should be done in combination with a small p-value.
Wilks_Lamnda = stats.lambda