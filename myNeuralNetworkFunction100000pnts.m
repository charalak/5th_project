function [y1] = myNeuralNetworkFunction100000pnts(x1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 26-May-2017 15:31:11.
%
% [y1] = myNeuralNetworkFunction(x1) takes these arguments:
%   x = 6xQ matrix, input #1
% and returns:
%   y = 2xQ matrix, output #1
% where Q is the number of samples.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.keep = [1 2 3 4 5];
x1_step2.xoffset = [0;-0.000347609631717205;2348992.75;1.0682138055563;1394600106.87996];
x1_step2.gain = [473.65433953941;1131.17631143378;1.78132459296733e-05;9.82356355763647;7.04659860346455e-09];
x1_step2.ymin = -1;

% Layer 1
b1 = [2.4380366540290778765;-2.4294297048049302568;-2.4165703228141048875;1.6355988390886699868;1.4929985733570276807;-1.085975049801382486;0.95385348197537711545;0.419245550329538752;-0.65708247296906319157;0.26810395945546161567;-1.207002513811271216;-2.1326898189979921483;-4.896804040511380407;2.7693240467452557851;1.3659038596079611239;-1.8439686890890354398;-2.2751871786684372267;9.2375505284855261579;-2.3806239205212924581;2.9293121859017841047];
IW1_1 = [-0.61367292313232613132 0.31019645270986551111 1.4689052158583979502 1.3375043479432349169 2.777968583565007421;0.57163975374642761462 1.4062603580559560612 -1.595789667203293849 -1.1561170009158379113 0.26462521997858001743;0.55660460555855839626 -1.6106832959433468044 -0.10642468517373254722 1.0615914908439969544 -1.0560059933598811011;-1.6303038042222339765 -0.48503683908238010014 -1.5033189446222259278 -1.22528156191476989 0.078519848851236487275;-1.2723271200409393966 -1.5019635124116117453 -0.87605154705701338003 0.58591518233475881061 -1.2567508950464061357;0.18368426029911918973 1.4750638120070087567 -1.7433432094322680594 0.44455568495450648037 -1.0649204000115113367;-0.1916194072149522698 3.1200067848637886847 -0.06800541692376757541 -0.39017983248400878171 -0.58162569034126854195;-1.8158758089237649891 -0.84636911902957800979 0.5334453389546065516 1.5091050815938158447 2.0928737026574690816;1.3481037810492537687 1.608473236060620648 0.63459110214758285284 1.4473153716016053938 -0.54143076099011211433;-0.35998076453489680215 0.90440311618400337501 -2.3701763089613483437 -1.4546867371166012362 -1.2422592030166426103;-1.5968810994280770998 -0.31312891282721022623 -2.2439634847599503331 2.4826093270438218674 2.3420331464107850827;-2.0237574094921351175 -1.465294438172989766 -1.5502662064365886341 -1.1586434610257534406 0.90019379358980455841;-5.9344272094622576574 3.0500107849649076286 0.18968189863354120717 1.1731555840726581863 -1.0572301397063383899;1.665659372956165285 -0.23672087468390673459 -2.7383300895124556007 1.196219334875421314 0.26087943749597503063;0.34387283673728424871 -2.0007603077961815252 1.0101142420288955481 -0.9110293776951624567 0.15267233130005791741;-2.5581077601419766054 -2.1391073453203888199 -0.21340661679549516316 -0.87891265909892546393 -0.93314854552071280214;-0.1369261864352179503 1.6674023077165653905 -0.47801627176846706035 1.1164662218019740791 0.88811284415873648079;6.8108367113700643003 3.5380830341325935073 -0.060065027443017782183 1.2298918647871979193 -1.5627046309092609278;-0.37139072287004343265 1.5002474431970405089 -0.044773036593067201683 1.8087353970854076479 -0.81523933508305346241;0.22494288305998008659 -1.5985581633299685844 0.32885395333571221244 1.6866273039364099162 0.36834537013966389685];

% Layer 2
b2 = [-0.84463014708342742942;0.93401687202996142023];
LW2_1 = [1.2782481344377889521 0.58752900191737900126 0.079492890184141476451 -0.35374330554871502574 -0.65982814238586495748 0.35952605852834329525 -0.68613521538017119283 0.47456920349970072026 0.76054797602136425816 0.090852778444017928683 1.8770476591416787038 1.7368991984934500916 -4.1187357903345009902 -2.2940598434771137804 -0.77134920820974850475 -1.3731089816198269737 0.79435180361948709571 5.2345378146393093388 0.82669059339309725054 -1.7614632777965046895;-0.43415635572068300707 -1.1062900529241985748 -0.91988197586229136782 0.37463273337280689201 1.246057876626966765 0.097270732486355288016 0.54111293010160688155 -1.3427119725328928723 -0.95591768843156488256 0.99691084237012383973 -0.91995331666188284725 -1.8803566584404487472 3.9659291053020333528 2.1714104030978886861 -0.37397400196492763813 2.3951617436413235041 -0.085283840958557288747 -6.0507689016415566741 -0.061009687582331259548 1.3871515043959330438];

% ===== SIMULATION ========

% Dimensions
Q = size(x1,2); % samples

% Input 1
xp1 = removeconstantrows_apply(x1,x1_step1);
xp1 = mapminmax_apply(xp1,x1_step2);

% Layer 1
a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*xp1);

% Layer 2
a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);

% Output 1
y1 = a2;
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Remove Constants Input Processing Function
function y = removeconstantrows_apply(x,settings)
y = x(settings.keep,:);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n,~)
if isa(n,'gpuArray')
    a = iSoftmaxApplyGPU(n);
else
    a = iSoftmaxApplyCPU(n);
end
end
function a = iSoftmaxApplyCPU(n)
nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);
numerator = exp(n);
denominator = sum(numerator,1);
denominator(denominator == 0) = 1;
a = bsxfun(@rdivide,numerator,denominator);
end
function a = iSoftmaxApplyGPU(n)
nmax = max(n,[],1);
numerator = arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
denominator = sum(numerator,1);
a = arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
end
function numerator = iSoftmaxApplyGPUHelper1(n,nmax)
numerator = exp(n - nmax);
end
function a = iSoftmaxApplyGPUHelper2(numerator,denominator)
if (denominator == 0)
    a = numerator;
else
    a = numerator ./ denominator;
end
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end
