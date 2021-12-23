nextflow.enable.dsl=2

process prepStat {
    tag { sid }

    input:
        tuple val(sid), file(mtsat), file(t1), file(mtr),\
        file(mask_gm), file(mask_wm)

    output:
        tuple val(sid), \
        path("${sid}_desc-gm_metrics.mat"), \
        path("${sid}_desc-wm_metrics.mat"), \
        path("${sid}_stat_summary.csv"), \
        emit: publish_stat

    //  There are 20 slices; however, few slices from top and bottom are not suitable for comparison.
    //  Therefore, the analysis is performed on 10 central slices (5:14) by default. (Applies to 16/18 of acquisitions).
    //  Volume prescription was performed by aligning the center of stack with that of CC.
    //  In one particular acquisition, the center was prescribed lower, as a result CC remained more 
    //  superior to the image stack (compared to remaining data). Therefore, for that acqusition 
    //  10:16 range is selected.
    //  Similarly for vendor750rev of sub-1. ROI is shifted up by 2 slices. 
    //  For | T1 0-3 (s) | MTR 35-70% | MTsat 1-8 a.u. | range, a second mean is reported in the csv.
    script: 
        """
        $params.runcmd " 
        labels = struct();
        interval = 5:14; 
        if strcmp('${sid}','sub-invivo1_ses-rthPRIrev')
            interval = 10:16;
        end
        if strcmp('${sid}','sub-invivo1_ses-vendor750rev')
            interval = 8:17;
        end
        labels(1).region = 'gm';
        labels(1).label = double(load_nii_data('$mask_gm'));
        labels(1).label = labels(1).label(:,:,interval);
        labels(2).region = 'wm';
        labels(2).label = double(load_nii_data('$mask_wm'));
        labels(2).label = labels(2).label(:,:,interval);
        curT1 = double(load_nii_data('$t1'));
        curT1 = curT1(:,:,interval);
        curMTS = double(load_nii_data('$mtsat'));
        curMTS = curMTS(:,:,interval);
        curMTR = double(load_nii_data('$mtr'));
        curMTR = curMTR(:,:,interval);
        csvData = {};
        cHeader = {'Session','Region','T1 (avg-all)','T1 (avg0-3)','T1 (std)','MTsat (avg)','MTsat (avg1-8)','MTsat (std)','MTR (avg)','MTR (avg35-70)','MTR (std)'};
        for ii=1:2

            csvData(ii,1) = '${sid}';
            csvData(ii,2) = {labels(ii).region};
            T1 = curT1(labels(ii).label == 1);
            csvData(ii,3) = num2cell(nanmean(T1));
            csvData(ii,5) = num2cell(nanstd(T1));
            T1(T1<0) =[]; T1(T1>3) =[];
            csvData(ii,4) = num2cell(nanmean(T1));

            MTsat = curMTS(labels(ii).label == 1);
            csvData(ii,6) = num2cell(nanmean(MTsat));
            csvData(ii,8) = num2cell(nanstd(MTsat));
            MTsat(MTsat<1) =[]; MTsat(MTsat>8) =[];
            csvData(ii,7) = num2cell(nanmean(MTsat));

            MTR = curMTR(labels(ii).label == 1);
            csvData(ii,9) = num2cell(nanmean(MTR));
            csvData(ii,11) = num2cell(nanstd(MTR));
            MTR(MTR<35) =[]; MTR(MTR>70) =[];
            csvData(ii,10) = num2cell(nanmean(MTR));

            svName = ['${sid}' '_desc-' labels(ii).region '_metrics.mat'];
            save('-mat7-binary',svName,'T1', 'MTsat','MTR');
        end  
        csvData = [cHeader;csvData];
        filename = ['${sid}' '_stat_summary.csv'];
        delimiter = ',';
        datei = fopen(filename,'w');
        for z=1:size(csvData,1)
            for s=1:size(csvData,2)
        
                var = eval(['csvData{z,s}']);
        
                if size(var,1) == 0
                    var = '';
                end
        
                if isnumeric(var) == 1
                    var = num2str(var);
                end
        
                fprintf(datei,var);
        
                if s ~= size(csvData,2)
                    fprintf(datei,[delimiter]);
                end
            end
            fprintf(datei,'\\n');
        end
        fclose(datei);
        exit();"
        """
}

process prepStatPhantom {
    tag { sid }

    input:
        tuple val(sid), file(t1map), file(mask)

    output:
        tuple val(sid), \
        path("${sid}_desc-sphere*_metrics.mat"), \
        path("${sid}_stat_summary.csv"), \
        emit: publish_stat_phantom

    script: 
        """
        $params.runcmd " 
        curLabel = double(load_nii_data('$mask'));
        curT1 = double(load_nii_data('$t1map'));
        csvData = {};
        refMean = {'1.989','1.454','0.9841','0.706','0.4967','0.3515','0.24713','0.1753','0.1259','0.089'};
        cHeader = {'Session','RefT1 (mean)','T1 (mean)','T1 (median)','T1 (std)','NumSamples'};

        for ii =1:10
            csvData(ii,1) = '${sid}';
            csvData(ii,2) = refMean(ii);
            T1 = curT1(curLabel == ii);
            csvData(ii,3) = num2cell(nanmean(T1));
            csvData(ii,4) = num2cell(nanmedian(T1));
            csvData(ii,5) = num2cell(nanstd(T1));
            csvData(ii,6) = length(T1);
            svName = ['${sid}' '_desc-sphere' num2str(ii) '_metrics.mat'];
            save('-mat7-binary',svName,'T1');
        end
        csvData = [cHeader;csvData];
        filename = ['${sid}' '_stat_summary.csv'];
        delimiter = ',';
        datei = fopen(filename,'w');
        for z=1:size(csvData,1)
            for s=1:size(csvData,2)
        
                var = eval(['csvData{z,s}']);
        
                if size(var,1) == 0
                    var = '';
                end
        
                if isnumeric(var) == 1
                    var = num2str(var);
                end
        
                fprintf(datei,var);
        
                if s ~= size(csvData,2)
                    fprintf(datei,[delimiter]);
                end
            end
            fprintf(datei,'\\n');
        end
        fclose(datei);
        exit();"
        """
}