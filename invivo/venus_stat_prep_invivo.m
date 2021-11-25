function venus_stat_prep_invivo(bidsFolder)
% Crawls through derivatives to parse a 
% summary stat csv along with vectorized mat files to 
% export them elsewhere for interactive analysis.

% nextflow run venus-process-invivo_new.nf --bids /Users/agah/Desktop/KuzuData/PHD_DATA/ds-temp -with-report report.html

    % Create a stat folder under derivatives/qMRLab
    derivativeDir = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo'];
    if ~exist(derivativeDir) == 7 
        mkdir(derivativeDir)
    end

    sessions = {'rth750retest','rth750test','rthPRIretest','rthPRItest','rthSKYretest','rthSKYtest',...
    'vendor750retest','vendor750test','vendorPRIretest','vendorPRItest','vendorSKYretest','vendorSKYtest'};

    csvData = {};
    cHeader = {'Session','Region','T1 (mean)','T1 (std)','T1cor (mean)','T1cor (std)','MTsat (mean)','MTsat (std)','MTsatcor (mean)','MTsatcor (std)','MTsatCFcor (mean)','MTsatCFcor (std)','B1 (mean)','B1 (std)','MTR (mean)','MTR (std)','NumSamples'}; 
    
    it = 1;
    
    % Central stack (slices from 5-14) is selected. 
    
    % Get masked values 
    for ii = 1:length(sessions)
        
        curStatDir = [derivativeDir filesep 'ses-' sessions{ii} filesep 'stat'];
        mkdir(curStatDir);
        
        if strcmp(sessions{ii}(end-5:end),'retest')
          % Always use masks from test retest images will be aligned.
          lblDir = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii}(1:end-6) 'test' filesep 'anat'];
        else
          lblDir = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat'];
        end
        
        labels = struct();
        labels(1).region = 'CSF';
        labels(1).label = double(load_nii_data([lblDir filesep 'T1_fast_pve_0.nii.gz']));
        labels(1).label = labels(1).label(:,:,5:14);
        labels(2).region = 'GM';
        labels(2).label = double(load_nii_data([lblDir filesep 'T1_fast_pve_1.nii.gz']));
        labels(2).label = labels(2).label(:,:,5:14);
        labels(3).region = 'WM';
        labels(3).label = double(load_nii_data([lblDir filesep 'T1_fast_pve_2.nii.gz']));
        labels(3).label = labels(3).label(:,:,5:14);
      
        if strcmp(sessions{ii}(end-5:end),'retest')
            curT1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_space-test_T1map.nii.gz']));
        else
            curT1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_T1map.nii.gz']));
        end
        curT1 = curT1(:,:,5:14);
        
        if strcmp(sessions{ii}(end-5:end),'retest')
            curMTS = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_space-test_MTsat.nii.gz']));
        else
            curMTS = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_MTsat.nii.gz']));        
        end
        curMTS  = curMTS(:,:,5:14);
        
        if strcmp(sessions{ii}(end-5:end),'retest')
            curMTR = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_space-test_MTRmap.nii.gz']));
        else
            curMTR = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_MTRmap.nii.gz']));
        end
        curMTR  = curMTR(:,:,5:14);

        if exist([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo'  filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_MTsat.nii.gz']) == 2 
            if strcmp(sessions{ii}(end-5:end),'retest')
                curMTScor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_space-test_MTsat.nii.gz']));
            else
                curMTScor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_MTsat.nii.gz']));
            end
            curMTScor = curMTScor(:,:,5:14);
        else
            curMTScor = [];
        end

        if exist([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo'  filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-cfb1corrected_MTsat.nii.gz']) == 2 
            if strcmp(sessions{ii}(end-5:end),'retest')
                curMTSCFcor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-cfb1corrected_space-test_MTsat.nii.gz']));
            else
                curMTSCFcor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-cfb1corrected_MTsat.nii.gz']));            
            end
            curMTSCFcor = curMTSCFcor(:,:,5:14);
        else
            curMTSCFcor = [];
        end
        
        if exist([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo'  filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_T1map.nii.gz']) == 2 
            if strcmp(sessions{ii}(end-5:end),'retest')
                curT1cor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_space-test_T1map.nii.gz']));
            else
                curT1cor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep 'sub-invivo_ses-' sessions{ii} '_desc-b1corrected_T1map.nii.gz']));           
            end
                curT1cor = curT1cor(:,:,5:14);
        else
            curT1cor = [];
        end

        if exist([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'fmap' filesep 'sub-invivo_ses-' sessions{ii} '_desc-resampledfiltered_TB1map.nii.gz'])==2
            if strcmp(sessions{ii}(end-5:end),'retest')
                curB1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'fmap' filesep 'sub-invivo_ses-' sessions{ii} '_desc-resampledfiltered_space-test_TB1map.nii.gz']));
            else
                curB1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'fmap' filesep 'sub-invivo_ses-' sessions{ii} '_desc-resampledfiltered_TB1map.nii.gz']));
            end
            curB1 = curB1(:,:,5:14);
        else
            curB1 = [];
        end


        
        for jj =1:3
        csvData(it,1) = sessions(ii);
        csvData(it,2) = {labels(jj).region};
        T1 = curT1(labels(jj).label == 1);
        csvData(it,3) = num2cell(nanmean(T1));
        csvData(it,4) = num2cell(nanstd(T1));

        if ~isempty(curT1cor)
            T1cor = curT1cor(labels(jj).label == 1);    
            csvData(it,5) = num2cell(nanmean(T1cor));
            csvData(it,6) = num2cell(nanstd(T1cor));
        else
            T1cor = [];
            csvData(it,5) = {'N/A'};
            csvData(it,6) = {'N/A'};
        end

        MTsat = curMTS(labels(jj).label == 1);
        csvData(it,7) = num2cell(nanmean(MTsat));
        csvData(it,8) = num2cell(nanstd(MTsat));

        if ~isempty(curMTScor)
            MTsatcor = curMTScor(labels(jj).label == 1);
            csvData(it,9) = num2cell(nanmean(MTsatcor));
            csvData(it,10) = num2cell(nanstd(MTsatcor));
        else
            MTsatcor = [];
            csvData(it,9) = {'N/A'};
            csvData(it,10) = {'N/A'};
        end

        if ~isempty(curMTSCFcor)
            MTsatCFcor = curMTSCFcor(labels(jj).label == 1);
            csvData(it,11) = num2cell(nanmean(MTsatCFcor));
            csvData(it,12) = num2cell(nanstd(MTsatCFcor));
        else
            MTsatCFcor = [];
            csvData(it,11) = {'N/A'};
            csvData(it,12) = {'N/A'};
        end
        
        if ~isempty(curB1)
            B1 = curB1(labels(jj).label == 1);
            csvData(it,13) = num2cell(nanmean(B1));
            csvData(it,14) = num2cell(nanstd(B1));
        else
            B1 = [];
            csvData(it,13) = {'N/A'};
            csvData(it,14) = {'N/A'};
        end
        
        MTR = curMTR(labels(jj).label == 1);
        csvData(it,15) = num2cell(nanmean(MTR));
        csvData(it,16) = num2cell(nanstd(MTR));

        csvData(it,17) = num2cell(length(curT1(labels(jj).label == 1)));

        svName = [curStatDir filesep 'sub-invivo_ses-' sessions{ii} '_desc-' labels(jj).region '_metrics.mat'];
        save(svName,'T1', 'T1cor', 'B1', 'MTsat','MTsatcor','MTR','MTsatCFcor');

        it = it +1; 
        end
        
    end

    csvData = [cHeader;csvData];
    cell2csv([derivativeDir filesep 'venus_invivo_stat_summary.csv'],csvData,',');

end


function cell2csv(filename,cellArray,delimiter)
    % Writes cell array content into a *.csv file.
    % 
    % CELL2CSV(filename,cellArray,delimiter)
    %
    % filename      = Name of the file to save. [ i.e. 'text.csv' ]
    % cellarray    = Name of the Cell Array where the data is in
    % delimiter = seperating sign, normally:',' (default)
    %
    % by Sylvain Fiedler, KA, 2004
    % modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
    if nargin<3
        delimiter = ',';
    end
    
    datei = fopen(filename,'w');
    for z=1:size(cellArray,1)
        for s=1:size(cellArray,2)
    
            var = eval(['cellArray{z,s}']);
    
            if size(var,1) == 0
                var = '';
            end
    
            if isnumeric(var) == 1
                var = num2str(var);
            end
    
            fprintf(datei,var);
    
            if s ~= size(cellArray,2)
                fprintf(datei,[delimiter]);
            end
        end
        fprintf(datei,'\n');
    end
    fclose(datei);
    end