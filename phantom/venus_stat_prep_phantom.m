function venus_stat_prep_phantom(bidsFolder)
% Crawls through derivatives to parse a 
% summary stat csv along with vectorized mat files to 
% export them elsewhere for interactive analysis.

    % Create a stat folder under derivatives/qMRLab
    statDir = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-phantom' filesep 'stat'];
    if ~exist(statDir) == 7 
        mkdir(statDir)
    end

    sessions = {'rth750retest','rth750test','rthPRIretest','rthPRItest','rthSKYretest','rthSKYtest',...
    'vendor750retest','vendor750test','vendorPRIretest','vendorPRItest','vendorSKYretest','vendorSKYtest'};

    csvData = {};
    refMean = {'1.989','1.454','0.9841','0.706','0.4967','0.3515','0.24713','0.1753','0.1259','0.089'};
    refStd = {'1','2.5','0.33','1.5','0.41','0.91','0.086','0.11','0.33','0.17'};
    refNiCl2 = {'0.299','0.623','1.072','1.720','2.617','3.912','5.731','8.297','11.936','17.070'};
    cHeader = {'Session','RefT1 (mean)','T1 (mean)','T1 (std)','T1cor (mean)','T1cor (std)','MTsat (mean)','MTsat (std)','B1 (mean)','B1 (std)','NiCl2 conc','RefT1 (std)','NumSamples'}; 

    it = 1;
    % Get masked values 
    for ii = 1:length(sessions)
        
        curStatDir = [statDir filesep 'ses-' sessions{ii}];
        mkdir(curStatDir);

        curLabel = double(load_nii_data([bidsFolder filesep 'derivatives' filesep '3DSlicer' filesep 'sub-phantom' filesep 'anat' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_labels.nii.gz']));
        curT1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-phantom' filesep 'anat' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_T1map.nii.gz']));
        
        if exist([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-phantom' filesep 'anat' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_desc-b1corrected_T1map.nii.gz']) == 2 
            curT1cor = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-phantom' filesep 'anat' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_desc-b1corrected_T1map.nii.gz']));
        else
            curT1cor = [];
        end

        if exist([bidsFolder filesep 'derivatives' filesep 'ANTs' filesep 'sub-phantom' filesep 'fmap' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_desc-resampled_TB1map.nii.gz'])==2
            curB1 = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'ANTs' filesep 'sub-phantom' filesep 'fmap' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_desc-resampled_TB1map.nii.gz']));
        else
            curB1 = [];
        end


        curMTS = double(load_nii_data([bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-phantom' filesep 'anat' filesep 'ses-' sessions{ii} filesep 'sub-phantom_ses-' sessions{ii} '_MTsat.nii.gz']));
        
        for jj =1:10
        csvData(it,1) = sessions(ii);
        csvData(it,2) = refMean(jj);
        T1 = curT1(curLabel == jj);
        csvData(it,3) = num2cell(nanmean(T1));
        csvData(it,4) = num2cell(nanstd(T1));

        if ~isempty(curT1cor)
            T1cor = curT1cor(curLabel == jj);    
            csvData(it,5) = num2cell(nanmean(T1cor));
            csvData(it,6) = num2cell(nanstd(T1cor));
        else
            T1cor = [];
            csvData(it,5) = {'N/A'};
            csvData(it,6) = {'N/A'};
        end

        MTsat = curMTS(curLabel == jj);
        csvData(it,7) = num2cell(nanmean(MTsat));
        csvData(it,8) = num2cell(nanstd(MTsat));

        if ~isempty(curB1)
            B1 = curB1(curLabel == jj);
            csvData(it,9) = num2cell(nanmean(B1));
            csvData(it,10) = num2cell(nanstd(B1));
        else
            B1 = [];
            csvData(it,9) = {'N/A'};
            csvData(it,10) = {'N/A'};
        end

        csvData(it,11) = refStd(jj);
        csvData(it,12) = refNiCl2(jj);

        csvData(it,13) = num2cell(length(curT1(curLabel == jj)));

        svName = [curStatDir filesep 'sub-phantom_ses-' sessions{ii} '_desc-sphere' num2str(jj) '_metrics.mat'];
        save(svName,'T1', 'T1cor', 'B1', 'MTsat');

        it = it +1; 
        end
        
    end

    csvData = [cHeader;csvData];
    cell2csv([statDir 'venus_phantom_stat_summary.csv'],csvData,',');

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