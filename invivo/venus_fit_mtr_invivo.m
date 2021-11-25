function venus_fit_mtr_invivo(bidsFolder)

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
        % Aligned 
        pth2 = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'anat' filesep ];
        mtw = [pth2 cursid '_acq-MTon_MTS_aligned'];
        pdw = [pth2 cursid '_acq-MToff_MTS_aligned'];

        
        
        Model = mt_ratio;
        data = struct();
        
        try
            data.MTon=double(load_nii_data([mtw '.nii.gz']));
        catch
            data.MTon=double(load_nii_data([mtw '.nii']));
        end
        try
            data.MToff=double(load_nii_data([pdw '.nii.gz']));
        catch
            data.MToff=double(load_nii_data([pdw '.nii']));
        end

                
        FitResults = FitData(data,Model,0);

        addDescription = struct();
        addDescription.Options = Model.options;
        addDescription.BasedOn = [{[mtw '.nii(.gz)']},{[pdw '.nii(.gz)']}];
        p.Results.description = [];
        if isempty(p.Results.description)
            addDescription.GeneratedBy.Description = 'qMRLab venus local';
        else
            addDescription.GeneratedBy.Description = p.Results.description;
        end
        
        try
            FitResultsSave_BIDS(FitResults,[mtw '.nii.gz'],'invivo','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription);
        catch
            FitResultsSave_BIDS(FitResults,[mtw '.nii'],'invivo','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription); 
        end
        
    end
end    