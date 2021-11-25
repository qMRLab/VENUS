%% Sample code to correct B1+ inhomogeneity in MTsat maps 

% This script is to analyze MTw images obtained at different B1 pulse
% amplitudes applied for the MT saturation pulses. 

% currently set up to be run section by section so that you can view the
% results/ check data quality/ troubleshoot. To run faster, comment out lines used to
% display the images.

% code that can be used to load/export MRI data is here: https://github.com/ulrikls/niak
% image view code is a modified version of https://www.mathworks.com/matlabcentral/fileexchange/47463-imshow3dfull

%% Load the associated matlab files
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

%% Set up directories

sessions = {'rth750retest'};

tic;
for ii=1:1
cursid = ['sub-invivo_ses-' sessions{ii}];
bidsFolder = '/Users/agah/Desktop/KuzuData/PHD_DATA/ds-venus';
pth1 = [bidsFolder filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep ];
% Aligned 
pth2 = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep ];
mtwn = [pth2 cursid '_acq-MTon_MTS_aligned.nii.gz'];
pdwn = [pth2 cursid '_acq-MToff_MTS_aligned.nii.gz'];
t1wn = [pth1 cursid '_flip-02_mt-off_MTS.nii.gz'];
b1map = [bidsFolder filesep 'derivatives/qMRLab/sub-invivo/' 'ses-' sessions{ii} filesep 'fmap' filesep cursid '_desc-resampledfiltered_TB1map.nii.gz'];


% Output figures
OutputDirectory = [bidsFolder filesep 'out'];

% load in the fit results from simSeq_M0b_R1obs.m
% makes sure to find the file names/locations where you made the values. 
fitvalsDir = '/Users/agah/Desktop/KuzuData/PHD_DATA/ds-venus/'; %-> USER DEFINED
fitValues = load(strcat(fitvalsDir,'fitvalues_single.mat')); % -> USER DEFINED
fitValues = fitValues.fitValues; % may or maynot need this line depending on how it saves

%% image names
 

%load the images your favourite way

hfa = double(load_nii_data(t1wn));
lfa = double(load_nii_data(pdwn));
mtw = double(load_nii_data(mtwn));
%[~, lfa] = niak_read_vol(strcat(DATADIR,seg_fn{2}));
%[~, mtw] = niak_read_vol(strcat(DATADIR,seg_fn{3}));

% can check to see if it loaded properly, don't worry about orientation
%figure; imshow3Dfull(lfa, [200 600],jet)

%% Load B1 map and set up b1 matrices

% B1 nominal and measured -> USER DEFINED
b1_rms = [3.64];  % value in microTesla. Nominal value for the MTsat pulses 

% load B1 map -> USER DEFINED
b1 = double(load_nii_data(b1map));

b1 = b1./100;
% filter the b1 map if you wish. %
%b1 = imgaussfilt3(b1,1);

% check the quality of the map, and make sure it is oriented the same as
% your other images (and same matrix size. if not you may need to pad the
% image). 
%figure; imshow3Dfull(b1, [0.7 1.2],jet)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% include any preprocessing steps here such as MP-PCA denoising, and
% unringing of GRE images. Not needed for this analysis. Each of the below
% functions can be optimized for your dataset. 
%% denoise (code here https://github.com/sunenj/MP-PCA-Denoising) -> USER DEFINED OPTION
%img_dn = cat(4,hfa, lfa, mtw);
%all_PCAcorr = MPdenoising( img_dn );

%% unring the images ( code here https://github.com/josephdviviano/unring) -> USER DEFINED OPTION
%hfa = unring3D(all_PCAcorr(:,:,:,1), 3);
%lfa = unring3D(all_PCAcorr(:,:,:,2), 3);
%mtw = unring3D(all_PCAcorr(:,:,:,3), 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Generate a brain mask to remove background
mask = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'T1_biascorr_brain_mask_' sessions{ii} '.nii.gz']));
%threshold = 175; % -> USER DEFINED
%mask (lfa >threshold) = 1;  % check your threshold here, data dependent. You could also load a mask made externally instead. 

% check it 
%figure; imshow3Dfullseg(lfa, [150 600], mask)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin MTsat calculation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate A0 and R1
low_flip_angle = 6;    % flip angle in degrees -> USER DEFINED
high_flip_angle = 20;  % flip angle in degrees -> USER DEFINED
TR1 = 28;               % low flip angle repetition time of the GRE kernel in milliseconds -> USER DEFINED
TR2 = 18;               % high flip angle repetition time of the GRE kernel in milliseconds -> USER DEFINED

a1 = low_flip_angle*pi/180 .* b1; % note the inclusion of b1 here.
a2 = high_flip_angle*pi/180 .* b1; 

% New code Aug 4, 2021 CR for two TR's
R1 = 0.5 .* (hfa.*a2./ TR2 - lfa.*a1./TR1) ./ (lfa./(a1) - hfa./(a2));
App = lfa .* hfa .* (TR1 .* a2./a1 - TR2.* a1./a2) ./ (hfa.* TR1 .*a2 - lfa.* TR2 .*a1);

% Old code for single TR only
%R1 = 0.5 .* (hfa.*a2./ TR - lfa.*a1./TR) ./ (lfa./(a1) - hfa./(a2));
% App = lfa .* hfa .* (TR .* a2./a1 - TR.* a1./a2) ./ (hfa.* TR .*a2 - lfa.* TR .*a1);

R1 = R1.*mask;
T1 = 1/R1  .* mask;
App = App .* mask;

%check them
%figure; imshow3Dfull(T1, [0 3500],jet)
%figure; imshow3Dfull(App , [2500 6000])

% can export your T1 or R1 map here if you wish
% note these results are in milliseconds (T1) or 1/ms (for R1)
%hdr.file_name = strcat(DATADIR,'calc_sat_maps/R1.mnc'); niak_write_vol(hdr,R1);
%hdr.file_name = strcat(DATADIR,'calc_sat_maps/App.mnc'); niak_write_vol(hdr,App);

%% Generate MTsat maps for the MTw images. 
% Inital Parameters
readout_flip = 6; % flip angle used in the MTw image, in degrees -> USER DEFINED
TR = 28; % -> USER DEFINED
a_MTw_r = readout_flip /180 *pi;

% calculate maps as per Helms et al 2008. Note: b1 is included here for flip angle
MTsat = (App.* (a_MTw_r*b1)./ mtw - 1) .* (R1) .* TR - ((a_MTw_r*b1).^2)/2;

% check them, did it work?
%figure; imshow3Dfull(MTsat, [0 0.03],jet)

%fix limits - helps with background noise
MTsat(MTsat<0) = 0;


%% Start with M0B,app fitting  MTsat values 

R1_s = R1*1000; % need to convert to 1/s from 1/ms

% initialize matrices
M0b_app = zeros(size(lfa));
fit_qual = zeros(size(lfa));
comb_res = zeros(size(lfa));


%New code added thanks to Ian Tagge to speed up with the parallel toolbox.
% % accelerate!!!
disp('starting fitting via parfor')

% find indices of valid voxels
q = find( (mask(:)>0));

% make input arrays (length(q),1) from 3D volumes
b1_ = b1(q);
r1s = R1_s(q);
mtsat = MTsat(q);

% allocate output arrays
mob = q.*0; fitq = mob; comb = mob;


parfor qi = 1:length(q)
    try
         [mob(qi), fitq(qi), comb(qi)] = CR_fit_M0b_v1( b1_rms*b1_(qi), R1_s(qi), mtsat(qi),fitValues);
    catch ME
        disp(['qi:' num2str(qi) '; q: ' num2str(q(qi))])
        disp(ME.message)
    end
end



% return output arrays back into 3D volumes
M0b_app(q) = mob;
fit_qual(q) = fitq;
comb_res(q) = comb;

% view results
%figure; imshow3Dfull(M0b_app, [0 0.15],jet)

% Save results incase you need to go back, since they take a while to generate!
%hdr.file_name = strcat(DATADIR,'calc_sat_maps/M0b.mnc'); niak_write_vol(hdr,M0b_app);
%hdr.file_name = strcat(DATADIR,'calc_sat_maps/fit_qual_mask.mnc'); niak_write_vol(hdr,fit_qual);
%hdr.file_name = strcat(DATADIR,'calc_sat_maps/comb_residuals.mnc'); niak_write_vol(hdr,comb_res);

save_nii_v2(M0b_app,[OutputDirectory filesep 'M0b_app_' sessions{ii} '.nii.gz'],mtwn,64);
save_nii_v2(fit_qual,[OutputDirectory filesep 'fit_qual_' sessions{ii} '.nii.gz'],mtwn,64);
save_nii_v2(comb_res,[OutputDirectory filesep 'comb_res_' sessions{ii} '.nii.gz'],mtwn,64);
    
%% Now add these regression equations to the fitValues structure and save. 
R1_p = R1(mask>0);
M0b_p = M0b_app(mask>0);

plot_con = cat(2, R1_p,M0b_p); 
contrast_fit = zeros(1,2);
ft = fittype('poly1');

tmp = plot_con(:,2);
tmp_r1 = plot_con(:,1)*1000; % convert from ms to sec
tmp_r1(tmp==0) = []; % to clean up the plots
tmp(tmp==0) = [];
M0b_d_fit = fit(tmp_r1,tmp,ft);
[R,P]= corrcoef([tmp, tmp_r1],'Alpha',0.05,'Rows','complete') ;
contrast_fit(1,1) = R(2,1);
contrast_fit(1,2) = P(2,1);
fitvals_Msat = coeffvalues(M0b_d_fit);


fitValues.Est_M0b_from_R1 = strcat( num2str(fitvals_Msat(1)),' *Raobs + ',num2str(fitvals_Msat(2)));
save(strcat([OutputDirectory filesep],['fitValues_' sessions{ii} '.mat']),'fitValues')

CF_MTsat = MTsat_B1corr_factor_map(b1, R1_s, b1_rms,fitValues);
MTsat_b1corr  = MTsat  .* (1+ CF_MTsat)  .* mask;

MTsat_b1corr = MTsat_b1corr.*100; % Convention
save_nii_v2(MTsat_b1corr,[OutputDirectory filesep 'sub-invivo_ses-' sessions{ii} '_desc-cfb1corrected_MTsat.nii.gz'],mtwn,64);
save_nii_v2(MTsat.*100,[OutputDirectory filesep 'sub-invivo_ses-' sessions{ii} '_desc-notcorrected_MTsat.nii.gz'],mtwn,64);

end
toc;
