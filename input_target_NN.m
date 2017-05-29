%  function tab = collect_data(it)
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


qj = fitsread([source_file 'qj_cb24ni_' num2str(it,'%04.0f') '.fits']);
qv = fitsread([source_file 'qv_cb24ni_' num2str(it,'%04.0f') '.fits']);
tg = fitsread([source_file 'tg_cb24ni' num2str(it,'%04.0f') '.fits']);
p  = fitsread([source_file 'pressure_cb24ni_' num2str(it,'%04.0f') '.fits']);  
p=p*10; % convertion cgs [dyn/cm2/g]
nel = fitsread([source_file 'nel_cb24ni' num2str(it,'%04.0f') '.fits']);
z = fitsread([source_file 'z_cb24ni.fits']);
z = z(20:350);
zz(1,1,:)=z;
z=repmat(zz,768,768,1);
clearvars zz
L = fitsread([lcc_file 'lcc_' num2str(it,'%04.0f')  '_fiji_3Donly.fits']);

% reshape
num=10000000;
qj =reshape(qj,[],1); qj=qj(1:num);
qv =reshape(qv,[],1); qv = qv(1:num);
tg =reshape(tg,[],1); tg=tg(1:num);
p =reshape(p,[],1);    p = p(1:num);
nel =reshape(nel,[],1); nel = nel(1:num);
L =reshape(L,[],1); L = L>0;  L=L(1:num);
z =reshape(z,[],1); z = z(1:num);

input2 = [qj'; qv'; tg'; p'; nel'; z'];
L2 = zeros(2,num);
L2(1,:) = L>0;
L2(2,:) = L==0;

save('/Users/charalak/Bifrost/cb24ni/5th_project/input_nn1e7.mat','input2')
save('/Users/charalak/Bifrost/cb24ni/5th_project/target_nn1e7.mat','L2')

%  clearvars qj qv tg p nel  z






 