%% Feautre Study: Events & Slow-burning

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
qv = TT.qvisc;
qv(qv<=0) = NaN;
TT.qvisc = qv;
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
% Xtest = Xtest(idx,:);
% Ytest = Ytest(idx);
% Xtest = zscore(Xtest,0,1);
% clearvars TT


%% plot events vs s-b in 3d: etaohm, j, qjoule
% scatter3(log10(Xtest(idx2,1)),log10(Xtest(idx2,4)),(Xtest(idx2,7)))
% hold on
% scatter3(log10(Xtest(idx1,1)),log10(Xtest(idx1,4)),(Xtest(idx1,7)))
% hold off

%% plot events in 3d: etaohm, j, qjoule
% figure, 
% scatter3(log10(Xtest(idx2,3)),log10(Xtest(idx2,10)),log10(Xtest(idx2,1)),'.')
% hold on
% scatter3(log10(Xtest(idx1,3)),log10(Xtest(idx1,10)),log10(Xtest(idx1,1)))
% hold off
% xlabel('etaohm');ylabel('j');zlabel('qj');


%% loop to plot all top 10 features agains each other
close all
idx_classes = ismember(Ytest,[1 50 100 200 300 500 600 800 850]);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [1 2 3 4 5  8 9 10]
        if (j>i)
        
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = gscatter(log10(Xtest(idx_classes,iqx)),log10(Xtest(idx_classes,iqy)),...
                Ytest(idx_classes));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            for ii=1:numel(unique(Ytest(idx_classes)))
                gs(ii).MarkerSize=10;
            end
            leg = legend;
            title(leg,'Event Nr.')
            legend boxon
            axis tight
            set(gca,'FontSize',18)
            print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end

%% plot loop: all vs one SPECIAL feature 
close all
idx_classes = ismember(Ytest,[1 50 100 200 300 500 600 800 850]);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [6 7]
        if 1
        
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = gscatter(log10(Xtest(idx_classes,iqx)),(Xtest(idx_classes,iqy)),...
                Ytest(idx_classes));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            for ii=1:numel(unique(Ytest(idx_classes)))
                gs(ii).MarkerSize=10;
            end
            leg = legend;
            title(leg,'Event Nr.')
            legend boxon
            axis tight
            set(gca,'FontSize',18)
            print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end

%% SLOW-BURNING: loop to plot all top 10 features agains each other
close all
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [1 2 3 4 5  8 9 10]
        if (j>i)
        
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),log10(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/slow_burning/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end



%% SLOW-BURNING: loop to plot all top 10 features agains each other
close all
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [1 2 3 4 5  8 9 10]
        if (j>i)
        
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),log10(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/slow_burning/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end

%% SLOW-BURNING: plot loop: all vs one SPECIAL feature
close all
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [6 7]
        if 1
        
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
%             leg = legend;
%             title(leg,'Event Nr.')
%             legend boxon
            axis tight
            set(gca,'FontSize',18)
            print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/slow_burning/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end

%% Events vs. S-B


close all
idx_classes2 = ismember(Ytest,[1 50 100 200 300 500 600 800 850]);
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [1 2 3 4 5  8 9 10]
% for i = [1  3]
%     for j =  [1  3]
        if (j>i)
            % SLOW-BURNING: loop to plot all top 10 features agains each other
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),log10(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            
            % --------------
           hold on
            gs = gscatter(log10(Xtest(idx_classes2,iqx)),log10(Xtest(idx_classes2,iqy)),...
                Ytest(idx_classes2));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            for ii=1:numel(unique(Ytest(idx_classes2)))
                gs(ii).MarkerSize=10;
            end
            leg = legend;
            title(leg,'Event Nr.')
            legend boxon
            axis tight
            set(gca,'FontSize',18)
           hold off
           print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/e_vs_sb/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end


%% Events vs. S-B : special features


close all
idx_classes2 = ismember(Ytest,[1 50 100 200 300 500 600 800 850]);
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [6 7]
% for i = [1  3]
%     for j =  [1  3]
        if (j>i)
            % SLOW-BURNING: loop to plot all top 10 features agains each other
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            
            % --------------
           hold on
            gs = gscatter(log10(Xtest(idx_classes2,iqx)),(Xtest(idx_classes2,iqy)),...
                Ytest(idx_classes2));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            for ii=1:numel(unique(Ytest(idx_classes2)))
                gs(ii).MarkerSize=10;
            end
            leg = legend;
            title(leg,'Event Nr.')
            legend boxon
            axis tight
            set(gca,'FontSize',18)
           hold off
           print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/e_vs_sb/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end


%% Events vs. S-B: ALL events


close all
idx_classes2 = Ytest>0;
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [1 2 3 4 5  8 9 10]
% for i = [1  3]
%     for j =  [1  3]
        if (j>i)
            % SLOW-BURNING: loop to plot all top 10 features agains each other
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),log10(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            
            % --------------
           hold on
            gs = scatter(log10(Xtest(idx_classes2,iqx)),log10(Xtest(idx_classes2,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel(['log_{10} (' names{iqy} ')'],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'r';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
           hold off
           print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/e_vs_sb/AllEvents_vs_sb/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end


%% Events vs. S-B : special features - ALL events


close all
idx_classes2 = Ytest>0;
idx_classes = ismember(Ytest,0);
fig = figure;
for i = [1 2 3 4 5  8 9 10]
    for j =  [6 7]
% for i = [1  3]
%     for j =  [1  3]
        if (j>i)
            % SLOW-BURNING: loop to plot all top 10 features agains each other
            iqx = i; iqy = j; % index quantity x and y respectively
            
            gs = scatter(log10(Xtest(idx_classes,iqx)),(Xtest(idx_classes,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'b';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
            
            % --------------
           hold on
            gs = scatter(log10(Xtest(idx_classes2,iqx)),(Xtest(idx_classes2,iqy)));
            xlabel(['log_{10} (' names{iqx} ')'],'Interpreter','none');
            ylabel([names{iqy}],'Interpreter','none');
            fig.Units= 'Normalized';
            fig.Position =[0.7 0.7 0.3 0.3];
            gs.LineWidth = 0.1;
            gs.MarkerEdgeColor = 'r';
            gs.MarkerFaceColor = [0 0.5 0.5];
            axis tight
            set(gca,'FontSize',18)
           hold off
           print(gcf, '-depsc', '-r300','-painters', [sourcefile...
                'cb24ni/5th_project/figures/multi_class/e_vs_sb/AllEvents_vs_sb/' ...
                names{iqx} '_VS_' names{iqy}  '.eps']);
        end
    end
end


countLevels = @(x)numel(categories(categorical(x)));
numLevels = varfun(countLevels,TT(:,1:end-1),'OutputFormat','uniform');