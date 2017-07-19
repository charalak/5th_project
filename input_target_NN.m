%  function tab = collect_data(it)
clearvars
it =299;
% Collect data
%--------------------------------------------------------------------------
%% set path
if strcmp(computer, 'MACI64') 
    machine = '/Users/charalak/Bifrost/';
else
    machine = '/mn/stornext/u3/charalak/Bifrost_cvs/';
end

source_file = [machine 'cb24ni/cb24ni_source/'];
lcc_file = [machine 'cb24ni/RUNS/fiji4d/'];
%% load data

% qj = fitsread([source_file 'qj_cb24ni_' num2str(it,'%04.0f') '.fits']);
% qv = fitsread([source_file 'qv_cb24ni_' num2str(it,'%04.0f') '.fits']);
    % tg = fitsread([source_file 'tg_cb24ni' num2str(it,'%04.0f') '.fits']);
    % p  = fitsread([source_file 'pressure_cb24ni_' num2str(it,'%04.0f') '.fits']);  
    % p=p*10; % convertion cgs [dyn/cm2/g]
    % nel = fitsread([source_file 'nel_cb24ni' num2str(it,'%04.0f') '.fits']);

    % make a list of interested fits files
    list_quant = dir(fullfile(machine,'cb24ni/cb24ni_source/','*0299.fits'));



    % 
     z = fitsread([source_file 'z_cb24ni.fits']);
     z = z(20:350);
     zz(1,1,:)=z;
     z=repmat(zz,768,768,1);
     z = reshape(z,[],1);
     clearvars zz
     L = fitsread([lcc_file 'lcc_' num2str(it,'%04.0f')  '_fiji_3Donly.fits']);
     L = reshape(L,[],1); 
     L = L>0;
var_names = cell(numel(list_quant),1);
for i=1:numel(list_quant)
    if ((~strcmp(list_quant(i).name,'lfx_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'lfy_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'lfz_cb24ni_0299.fits')) &&...    
        (~strcmp(list_quant(i).name,'curlbx_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'curlby_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'curlbz_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'qv_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'qj_cb24ni_0299.fits')) && ...
        (~strcmp(list_quant(i).name,'ux_cb24ni_0299.fits')) && ...
        (~strcmp(list_quant(i).name,'uy_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'nel_cb24ni0299.fits')) &&...
        (~strcmp(list_quant(i).name,'rho_cb24ni_0299.fits')) &&...
        (~strcmp(list_quant(i).name,'dedt_rc0299.fits')) &&...
        (~strcmp(list_quant(i).name,'uz_cb24ni_0299.fits')))
        
        id_str = strfind(list_quant(i).name,'_');
        var_names{i,1} = list_quant(i).name(1:id_str-1);
        
    end
end
var_names = var_names(~cellfun('isempty',var_names));
nov = numel(var_names);
% extra_var_names = {'z';'L'};
% var_names = [var_names; extra_var_names];

num=1e6;
TT = zeros(num,nov);

%idx_perm_L = randperm(768*768*331,768*768*331);

idx_only_events = find(L>0);
idx_no_events = find(L==0);

rng(20)
idx_rand1 = randperm(numel(idx_only_events),round(0.5*num));
idx_rand2 = randperm(numel(idx_no_events),round(0.5*num));
idx_only_events_random = idx_only_events(idx_rand1);
idx_no_events_random = idx_no_events(idx_rand2);


% idx = [idx_only_events_random ; idx_no_events_random] ;
%idx = randperm(768*768*331,num);
idx = [1:(768*768*331)];
row_name = cell(num,1);
for i=1:num
    row_name{i,1} = num2str(idx(i));
end

tic;
parfor i=1:numel(var_names)
    input_array = fitsread([machine 'cb24ni/cb24ni_source/'...
        var_names{i,1} '_cb24ni_' num2str(it,'%04.0f') '.fits' ]);
    input_array = reshape(input_array,[],1);
    input_array =input_array(idx);
    TT(:,i) = input_array;
    
        
end
toc

TT = array2table(TT);
TT.Properties.VariableNames=var_names;
TT.Properties.RowNames=row_name;
TT.z = z(idx);



% modify fetures
TT.min_bbaroxyz = min([abs(TT.bbarox)'; abs(TT.bbaroy)'; abs(TT.bbaroz)'])';
TT.max_bbaroxyz = max([abs(TT.bbarox)'; abs(TT.bbaroy)'; abs(TT.bbaroz)'])';
TT.bbarox =[]; TT.bbaroy =[]; TT.bbaroz =[];

TT.min_bpgradxyz = min([abs(TT.bpgradx)'; abs(TT.bpgrady)'; abs(TT.bpgradz)'])';
TT.max_bpgradxyz = max([abs(TT.bpgradx)'; abs(TT.bpgrady)'; abs(TT.bpgradz)'])';
TT.bpgrad = (TT.bpgradx + TT.bpgrady + TT.bpgradz);
TT.bpgradx =[]; TT.bpgrady =[]; TT.bpgradz =[];

TT.min_bpgradaxyz = min([abs(TT.bpgradax)'; abs(TT.bpgraday)'; abs(TT.bpgradaz)'])';
TT.max_bpgradaxyz = max([abs(TT.bpgradax)'; abs(TT.bpgraday)'; abs(TT.bpgradaz)'])';
TT.bpgrad = sqrt(TT.bpgradax.^2 + TT.bpgraday.^2 + TT.bpgradaz.^2);
TT.bpgradax =[]; TT.bpgraday =[]; TT.bpgradaz =[];

TT.min_brotjxyz = min([abs(TT.brotjx)'; abs(TT.brotjy)'; abs(TT.brotjz)'])';
TT.max_brotjxyz = max([abs(TT.brotjx)'; abs(TT.brotjy)'; abs(TT.brotjz)'])';
TT.brotj = sqrt(TT.brotjx.^2 + TT.brotjy.^2 + TT.brotjz.^2);
TT.brotjx =[]; TT.brotjy =[]; TT.brotjz =[];

TT.min_btlorxyz = min([abs(TT.btlorx)'; abs(TT.btlory)'; abs(TT.btlorz)'])';
TT.max_btlorxyz = max([abs(TT.btlorx)'; abs(TT.btlory)'; abs(TT.btlorz)'])';
TT.btlor = sqrt(TT.btlorx.^2 + TT.btlory.^2 + TT.btlorz.^2);
TT.btlorx =[]; TT.btlory =[]; TT.btlorz =[];

TT.min_btloraxyz = min([abs(TT.btlorax)'; abs(TT.btloray)'; abs(TT.btloraz)'])';
TT.max_btloraxyz = max([abs(TT.btlorax)'; abs(TT.btloray)'; abs(TT.btloraz)'])';
TT.btlora = sqrt(TT.btlorax.^2 + TT.btloray.^2 + TT.btloraz.^2);
TT.btlorax =[]; TT.btloray =[]; TT.btloraz =[];

TT.min_gradpxyz = min([abs(TT.gradpx)'; abs(TT.gradpy)'; abs(TT.gradpz)'])';
TT.max_gradpxyz = max([abs(TT.gradpx)'; abs(TT.gradpy)'; abs(TT.gradpz)'])';
TT.gradp = (TT.gradpx + TT.gradpy + TT.gradpz);
TT.gradpx =[]; TT.gradpy =[]; TT.gradpz =[];

TT.min_jxyz = min([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
TT.max_jxyz = max([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
TT.j = sqrt(TT.jx.^2 + TT.jy.^2 + TT.jz.^2);
TT.jx =[]; TT.jy =[]; TT.jz =[];

TT.min_lfaxyz = min([abs(TT.lfax)'; abs(TT.lfay)'; abs(TT.lfaz)'])';
TT.max_lfaxyz = max([abs(TT.lfax)'; abs(TT.lfay)'; abs(TT.lfaz)'])';
TT.lfa = sqrt(TT.lfax.^2 + TT.lfay.^2 + TT.lfaz.^2);
TT.lfax =[]; TT.lfay =[]; TT.lfaz =[];

TT.min_stretchxyz = min([abs(TT.stretchx)'; abs(TT.stretchy)'; abs(TT.stretchz)'])';
TT.max_stretchxyz = max([abs(TT.stretchx)'; abs(TT.stretchy)'; abs(TT.stretchz)'])';
TT.stretchx =[]; TT.stretchy =[]; TT.stretchz =[];

TT.min_tiltxyz = min([abs(TT.tiltx)'; abs(TT.tilty)'; abs(TT.tiltz)'])';
TT.max_tiltxyz = max([abs(TT.tiltx)'; abs(TT.tilty)'; abs(TT.tiltz)'])';
TT.tiltx =[]; TT.tilty =[]; TT.tiltz =[];

TT.min_vortxyz = min([abs(TT.vortx)'; abs(TT.vorty)'; abs(TT.vortz)'])';
TT.max_vortxyz = max([abs(TT.vortx)'; abs(TT.vorty)'; abs(TT.vortz)'])';
TT.vort = sqrt(TT.vortx.^2 + TT.vorty.^2 + TT.vortz.^2);
TT.vortx =[]; TT.vorty =[]; TT.vortz =[];

TT.L = L(idx);

% find max and min or if they can be joined for :
% bbarox bbaroy bbaroz
% bpgradax y z
% bpgradx y z  <<
% brotx y z   <<
% btlorax y z 
% btlorx y z <
% curlbx y z
% gradpx y z
% jx jy jz
% lfax y z
% lfx y z
% stretchx y z
% tiltx y z
% vortx y z

% minmax
% 'bbarox_cb24ni_0299.fits' 'bbaroy_cb24ni_0299.fits' 'bbaroz_cb24ni_0299.fits'

% reshape from 3D array to 1D array
% num=1e6;   % <<<<
% qj =reshape(qj,[],1); 
% qv =reshape(qv,[],1); 
% tg =reshape(tg,[],1); 
% p =reshape(p,[],1);    
% nel =reshape(nel,[],1); 
% L =reshape(L,[],1); L = L>0;  
% z =reshape(z,[],1); 
% choose pixels because the total number is too large
    % choose the first 'num' pixels 
% qj=qj(1:num); qv = qv(1:num); tg=tg(1:num); p = p(1:num);
% nel = nel(1:num);  L=L(1:num); z = z(1:num);

    % choose 'num' random pixels
% idx = randi(numel(L),1,num);
%  qj=qj(idx); qv = qv(idx); tg=tg(idx); p = p(idx);
%  nel = nel(idx);  L=L(idx); z = z(idx);


% input2 = [qj'; qv'; tg'; p'; nel'; z'];
% L2 = zeros(2,num);
% L2(1,:) = L>0;
% L2(2,:) = L==0;
filename = 'nop1e6_rand_nof54_all';
save([machine 'cb24ni/5th_project/' filename '/table' filename '.mat'],'TT')
% save('/Users/charalak/Bifrost/cb24ni/5th_project/nop_1e6_rand/target_nn1e6_rand.mat','L2')


%  clearvars qj qv tg p nel  z






 
