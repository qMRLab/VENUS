function venus_fit_afi_phantom(bidsFolder)

    %% TB1AFI maps 
    
    % AFI source data is only available from qMRPullseq.
    sessions = {'rth750retest','rth750test','rthPRIretest','rthPRItest','rthSKYretest','rthSKYtest'};

    setenv('ISBIDS','1');
    setenv('ISNEXTFLOW','0');

    for ii = 1:length(sessions)
        
        cursid = ['sub-phantom_ses-' sessions{ii}];
        
        pth = [bidsFolder filesep 'sub-phantom' filesep 'ses-' sessions{ii} filesep 'fmap' filesep ];
        AFI1 = [pth cursid '_acq-tr1_TB1AFI'];
        AFI2 = [pth cursid '_acq-tr2_TB1AFI'];
        
        Model = b1_afi;
        data = struct();
        
        % Fixed for now, available in json.
        Model.Prot.Sequence.Mat = [60;25;50];
        
        data.AFIData1=double(load_nii_data([AFI1 '.nii.gz']));
        data.AFIData2=double(load_nii_data([AFI2 '.nii.gz']));
            
        % ==== Fit Data ====
        
        FitResults = FitData(data,Model,0);
        

        addDescription = struct();
        addDescription.Protocol = Model.Prot;
        addDescription.Options = Model.options;
        addDescription.BasedOn = [{[AFI1 '.nii(.gz)']},{[AFI2 '.nii(.gz)']}];
        p.Results.description = [];
        if isempty(p.Results.description)
            addDescription.GeneratedBy.Description = 'qMRLab venus local';
        else
            addDescription.GeneratedBy.Description = p.Results.description;
        end
        
        FitResultsSave_BIDS(FitResults,[AFI1 '.nii.gz'],'phantom','targetDir',[bidsFolder filesep 'derivatives'],'sesFolder',true,'ses',sessions{ii},'injectToJSON',addDescription);

    end
end
