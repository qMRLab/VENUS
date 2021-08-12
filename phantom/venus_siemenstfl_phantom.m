function venus_siemenstfl_phantom(bidsFolder)
% This is using filter_map module mostly to take 
% advantage of I/O and provenance. 
% Otherwise just a division of fmap.

    sessions = {'vendorPRIretest','vendorPRItest','vendorSKYretest','vendorSKYtest'};

    setenv('ISBIDS','1');
    setenv('ISNEXTFLOW','0');

    for ii = 1:length(sessions)
        
        cursid = ['sub-phantom_ses-' sessions{ii}];
        
        pth = [bidsFolder filesep 'sub-phantom' filesep 'ses-' sessions{ii} filesep 'fmap' filesep ];
        FMAP = [pth cursid '_acq-fmap_TB1TFL'];
        
        Model = filter_map;
        data = struct();
        
        % These maps contain a transformation, so first we need 
        % to reslice.
        reslice_nii([FMAP '.nii'],[FMAP '_resliced.nii']);
        
        data.Raw = double(load_nii_data([FMAP '_resliced.nii']));
        
        % Siemens scaling
        data.Raw = data.Raw./800;

        % Multiply by 100 so that it is BIDS 
        data.Raw = data.Raw.*100;
        
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
        
        % ========================= !!!!!!!!!!!!!!!!!!!!!!!!=================
        FitResults.Filtered = data.Raw;
        FitResultsSave_BIDS(FitResults,[FMAP '_resliced.nii'],'phantom','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription);
    end

end