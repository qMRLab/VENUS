function venus_filterb1_invivo(bidsFolder)
% This is using filter_map module mostly to take 
% advantage of I/O and provenance. 
% Otherwise just a division of fmap.

    sessions = {'vendorPRIretest','vendorPRItest','vendorSKYretest','vendorSKYtest',...
        'rth750retest','rth750test','rthPRIretest','rthPRItest','rthSKYretest','rthSKYtest'};

    setenv('ISBIDS','1');
    setenv('ISNEXTFLOW','0');

    for ii = 1:length(sessions)
        
        cursid = ['sub-invivo_ses-' sessions{ii}];
        
        pth = [bidsFolder filesep 'derivatives' filesep 'qMRLab' filesep 'sub-invivo' filesep 'ses-' sessions{ii} filesep 'fmap' filesep ];
        FMAP = [pth cursid '_desc-resampled_TB1map'];
        
        Model = filter_map;
        data = struct();
        
        % These maps contain a transformation, so first we need 
        % to reslice.
        %reslice_nii([FMAP '.nii'],[FMAP '_resliced.nii']);
        
        data.Raw = double(load_nii_data([FMAP '.nii.gz']));
        
        % ==== Fit Data ====
        
        FitResults = FitData(data,Model,0);
        

        addDescription = struct();
        addDescription.BasedOn = [{FMAP '.nii(.gz)'}];
        p.Results.description = [];
        if isempty(p.Results.description)
            addDescription.GeneratedBy.Description = 'qMRLab venus local';
        else
            addDescription.GeneratedBy.Description = p.Results.description;
        end
        
        FitResultsSave_BIDS(FitResults,[FMAP '.nii.gz'],'invivo','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription,'desc','resampledfiltered');
    end

end