function venus_fit_mtsat_invivo(bidsFolder)

    % MTSAT original 
    
    sessions = {'rth750retest','rth750test','rthPRIretest','rthPRItest','rthSKYretest','rthSKYtest',...
        'vendor750retest','vendor750test','vendorPRIretest','vendorPRItest','vendorSKYretest','vendorSKYtest'};
    
    % Enforce BIDS units when saving. 
    setenv('ISBIDS','1');
    % For now just prototyping, to be nextflowed later.
    setenv('ISNEXTFLOW','0');
    
    for ii = 1:length(sessions)
        
        cursid = ['sub-invivo_ses-' sessions{ii}];
        
        % Fixed image (T1) from which masks are generated
        pth1 = [bidsFolder filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep ];
        % Aligned 
        pth2 = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep ];
        mtw = [pth2 cursid '_acq-MTon_MTS_aligned'];
        pdw = [pth2 cursid '_acq-MToff_MTS_aligned'];
        t1w = [pth1 cursid '_flip-02_mt-off_MTS'];

        
        b1map = [bidsFolder filesep 'derivatives/qMRLab/sub-invivo/' 'ses-' sessions{ii} filesep 'fmap' filesep cursid '_desc-resampledfiltered_TB1map'];
        
        Model = mt_sat;
        data = struct();
        
        try
            data.MTw=double(load_nii_data([mtw '.nii.gz']));
        catch
            data.MTw=double(load_nii_data([mtw '.nii']));
        end
        try
            data.PDw=double(load_nii_data([pdw '.nii.gz']));
        catch
            data.PDw=double(load_nii_data([pdw '.nii']));
        end
        try
            data.T1w=double(load_nii_data([t1w '.nii.gz']));
        catch
            data.T1w=double(load_nii_data([t1w '.nii']));
        end
        
        if exist([b1map '.nii.gz']) == 2
            data.B1map = load_nii_data([b1map '.nii.gz']);
            data.B1map = data.B1map./100; %BIDS to qMRLab these will be autom
        end
        
        % normally managed by nextflow, a bit tricky here.
        mtwj = [pth1 cursid '_flip-01_mt-on_MTS'];
        pdwj = [pth1 cursid '_flip-01_mt-off_MTS'];
        
        Model.Prot.MTw.Mat =[getfield(json2struct([mtwj '.json']),'FlipAngle') getfield(json2struct([mtwj '.json']),'RepetitionTime')];
        Model.Prot.PDw.Mat =[getfield(json2struct([pdwj '.json']),'FlipAngle') getfield(json2struct([pdwj '.json']),'RepetitionTime')];
        Model.Prot.T1w.Mat =[getfield(json2struct([t1w '.json']),'FlipAngle') getfield(json2struct([t1w '.json']),'RepetitionTime')];
                
        FitResults = FitData(data,Model,0);

        addDescription = struct();
        addDescription.Protocol = Model.Prot;
        addDescription.Options = Model.options;
        if exist([b1map '.nii.gz']) == 2
            addDescription.BasedOn = [{[mtw '.nii(.gz)']},{[pdw '.nii(.gz)']},{[t1w '.nii(.gz)']},{[b1map '.nii(.gz)']}];
        else
            addDescription.BasedOn = [{[mtw '.nii(.gz)']},{[pdw '.nii(.gz)']},{[t1w '.nii(.gz)']}];
        end
        p.Results.description = [];
        if isempty(p.Results.description)
            addDescription.GeneratedBy.Description = 'qMRLab venus local';
        else
            addDescription.GeneratedBy.Description = p.Results.description;
        end
        
        try
            FitResultsSave_BIDS(FitResults,[t1w '.nii.gz'],'invivo','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription);
        catch
            FitResultsSave_BIDS(FitResults,[t1w '.nii'],'invivo','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription); 
        end
        
    end
end    