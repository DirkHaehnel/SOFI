
% Variables ....
% handles.vRecursiveSearch;
% handles.vUseFolders;
% handles.vUseFiles;
% handles.vUseMDataFiles;
% handles.vSaveImages;
% handles.vSaveMDataFiles;
% handles.vBaseFolder;
% 
% handles.vCalcSOFIX;
% handles.vCalcSOFIX_Fourier;
% handles.vCalcSOFIX_Fourier_Mod;
% handles.vReadyForTest;
% handles.vRunning;
% 
% handles.numFolders;
% handles.vCellFolder(1,XXXFOLDEINDEX);
% handles.vCellOutFolder(1,XXXFOLDEINDEX);
% handles.numImages(XXXFOLDEINDEX);
% handles.vDataImagesInFolder(XXXFOLDEINDEX,1:handles.numImages(XXXFOLDEINDEX));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INIT PROCESS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate Parallel conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vUsingCPU = 1;
vUsingGPU = 0;
vUsingLocalWorkers = 0;
vUsingClusterWorkers = 0;

secondSelection = 0;

% handles.vHPCSelection == 0 (Use CPU); % handles.vParMeth == 1 (Use Local Workers); % handles.vParMeth == 2 (Use GPU);% handles.vParMeth == 3 (Use Cluster Workers);
if((handles.vHPCSelection == 3) || (secondSelection == 1))
    %Cluster Workers => use ditribuited workers
    vUsingClusterWorkers = 1;
    vUsingCPU = 0;
    
    %secondSelection = 0;
    secondSelection = 1; %%% Need configure ... please wait...
end
if((handles.vHPCSelection == 2)  || (secondSelection == 1))
    if(gpuDeviceCount >= 1)
        %GPU => use gpu structures
        vUsingGPU = 1;
        vUsingCPU = 0;

        secondSelection = 0;
    end
end
if((handles.vHPCSelection == 1)  || (secondSelection == 1))
    %Local Workers => use workers of PC (4 or 8)
    matlabpool;
    vMatlabPoolSize = matlabpool('size');
    if(vMatlabPoolSize > 0)
        vUsingLocalWorkers = 1;
        vUsingCPU = 0;

        secondSelection = 0;
    end
end
if((handles.vHPCSelection == 0)  || (secondSelection == 1))
    %Only CPU => To do serial processing
    vUsingCPU = 1;

    vUsingGPU = 0;
    vUsingLocalWorkers = 0;
    vUsingClusterWorkers = 0;
end

% vMatlabPoolSize = matlabpool('size');
% if(vMatlabPoolSize && (handles.vParMeth == 1))
%     matlabpool('close');
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XXX_Evaluate Parallel conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOFI Calls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if(vUsingCPU)
    % Others options deleted for clear system for miss Anja
    tic;
    if(handles.vUseFiles) % Use only a list of files
        externDirectory = char(handles.vBaseFolder);   
        % if not mat Files available...create these first
        if(handles.vUseMDataFiles == 0)
            handles.vActualChannel = 2;
            stateActual = 0;
            skipFile  = 0;
            for actualFile=1: handles.numImages(1)
                if(skipFile == 0)
                    if(handles.vActualChannel == 1)
                        handles.vActualChannel = 2;
                    else
                        handles.vActualChannel = 1;
                    end

                    set(handles.lbArchivos,'Value',actualFile);

                    externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                    nameFile = strcat(externDirectory,externActualFile);
                    externActualFile = regexprep(externActualFile, '.tif', '');
                    externActualFileBase = externActualFile;
                    
                    SOFITask_SofiXMod_Step1_CPU;
                    
                    nameMATFile = strcat(externDirectory,'Data_',externActualFileBase,'_OriginalData','.mat');
                    nameMATFileBase = nameMATFile;


                    %Evaluate Data
                    zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                    dummy = size(zText);
                    if(dummy(1) > 0)
                        zText = regexprep(zText, 'Z_', '');
                        zText = regexprep(zText, '_', '');
                        % Need Verify theory
                        z       = str2double(zText);
                        focpos  = 0;
                    else
                        z = handles.vMicZPos + stateActual*handles.vMicZStep;
                        focpos = handles.vMicFocPos;
                        stateActual = stateActual + 1;
                    end

                    z525 = size(regexp(externActualFileBase, '525', 'match'));
                    z625 = size(regexp(externActualFileBase, '625', 'match'));
                    if(z525(1) > 0)
                        lambda = 525;
                    elseif(z625(1) > 0)
                        lambda = 625;
                    elseif(handles.vUse2Channels)
                        if(handles.vActualChannel == 1)
                            lambda = handles.vMicLambda;
                        else
                            lambda = handles.vMicLambda2;
                        end
                    else
                        lambda = handles.vMicLambda;
                    end

                    %Evaluate Xnumber Split
                    dummy = 1;
                    actualPosition = actualFile + 1;
                    while dummy
                        if(actualFile < handles.numImages(1))
                            externActualFile = char(handles.vDataImagesInFolder(1,actualPosition));
                            nameFile = strcat(externDirectory,externActualFile);
                            externActualFile = regexprep(externActualFile, '.tif', '');
                            zText = size(regexp(externActualFile, externActualFileBase, 'match'));
                            if(zText(1)>0)
                                actualPosition = actualPosition + 1;
                                skipFile = skipFile + 1;
                                
                                SOFITask_SofiXMod_Step1_CPU;
                            else
                                dummy = 0;
                            end
                        else
                            dummy = 0;
                        end
                    end
                    clear zText z525 z625

                    if(handles.vCalcSOFIX == 1)
                        SOFITask_SofiXMod_Step2_CPU;
                        if(handles.vCalcSOFIX_Fourier == 1)
                            SOFITask_SofiXFourierMod_CPU;
                        end
                    end
                else
                    skipFile = skipFile - 1;
                end
            end
        else
            handles.vActualChannel = 2;
            for actualFile=1: handles.numImages(1)
                if(handles.vActualChannel == 1)
                    handles.vActualChannel = 2;
                else
                    handles.vActualChannel = 1;
                end

                set(handles.lbArchivos,'Value',actualFile);

                externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                nameMATFile = strcat(externDirectory,externActualFile);
                externActualFile = regexprep(externActualFile, '.tif', '');
                externActualFile = regexprep(externActualFile, '.mat', '');
                externActualFile = regexprep(externActualFile, 'Data_', '');
                externActualFile = regexprep(externActualFile, '_OriginalData', '');

                load(nameMATFile);
                externActualFileBase = externActualFile;

                %Evaluate Data
                zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                dummy = size(zText);
                if(dummy(1) > 0)
                    zText = regexprep(zText, 'Z_', '');
                    zText = regexprep(zText, '_', '');
                    % Need Verify theory
                    z       = str2double(zText);
                    focpos  = 0;
                else
                    z = handles.vMicZPos + stateActual*handles.vMicZStep;
                    focpos = handles.vMicFocPos;
                    stateActual = stateActual + 1;
                end

                z525 = size(regexp(externActualFileBase, '525', 'match'));
                z625 = size(regexp(externActualFileBase, '625', 'match'));
                if(z525(1) > 0)
                    lambda = 525;
                elseif(z625(1) > 0)
                    lambda = 625;
                elseif(handles.vUse2Channels)
                    if(handles.vActualChannel == 1)
                        lambda = handles.vMicLambda;
                    else
                        lambda = handles.vMicLambda2;
                    end
                else
                    lambda = handles.vMicLambda;
                end

                clear zText z525 z625

                if(handles.vCalcSOFIX == 1)
                    SOFITask_SofiXMod_CPU;
                    if(handles.vCalcSOFIX_Fourier == 1)
                        SOFITask_SofiXFourierMod_CPU;
                    end
                end
            end
        end
    else % Use files sorted in a FOlder structure
        if(handles.vRecursiveSearch) % Only vadid for Folder use
            if(handles.vUseMDataFiles == 0)
                for actualFolder = 1 : handles.numFolders
                    set(handles.lbDirectorios,'Value',actualFolder);

                    externDirectory = char(handles.vCellFolder(1,actualFolder));
                    %handles.vCellOutFolder(1,actualFolder);

                    handles.vActualChannel = 2;
                    stateActual = 0;
                    skipFile  = 0;
                    for actualFile=1: handles.numImages(1)
                        if(skipFile == 0)
                            if(handles.vActualChannel == 1)
                                handles.vActualChannel = 2;
                            else
                                handles.vActualChannel = 1;
                            end

                            set(handles.lbArchivos,'Value',actualFile);

                            externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                            nameFile = strcat(externDirectory,externActualFile);
                            externActualFile = regexprep(externActualFile, '.tif', '');
                            externActualFileBase = externActualFile;
                            SOFITask_SofiXMod_Step1_CPU;
                            nameMATFile = strcat(externDirectory,'Data_',externActualFileBase,'_OriginalData','.mat');
                            nameMATFileBase = nameMATFile;


                            %Evaluate Data
                            zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                            dummy = size(zText);
                            if(dummy(1) > 0)
                                zText = regexprep(zText, 'Z_', '');
                                zText = regexprep(zText, '_', '');
                                % Need Verify theory
                                z       = str2double(zText);
                                focpos  = 0;
                            else
                                z = handles.vMicZPos + stateActual*handles.vMicZStep;
                                focpos = handles.vMicFocPos;
                                stateActual = stateActual + 1;
                            end

                            z525 = size(regexp(externActualFileBase, '525', 'match'));
                            z625 = size(regexp(externActualFileBase, '625', 'match'));
                            if(z525(1) > 0)
                                lambda = 525;
                            elseif(z625(1) > 0)
                                lambda = 625;
                            elseif(handles.vUse2Channels)
                                if(handles.vActualChannel == 1)
                                    lambda = handles.vMicLambda;
                                else
                                    lambda = handles.vMicLambda2;
                                end
                            else
                                lambda = handles.vMicLambda;
                            end

                            %Evaluate Xnumber Split
                            dummy = 1;
                            actualPosition = actualFile + 1;
                            while dummy
                                if(actualFile < handles.numImages(1))
                                    externActualFile = char(handles.vDataImagesInFolder(1,actualPosition));
                                    nameFile = strcat(externDirectory,externActualFile);
                                    externActualFile = regexprep(externActualFile, '.tif', '');
                                    zText = size(regexp(externActualFile, externActualFileBase, 'match'));
                                    if(zText(1)>0)
                                        actualPosition = actualPosition + 1;
                                        skipFile = skipFile + 1;

                                        SOFITask_SofiXMod_Step1_CPU;
                                    else
                                        dummy = 0;
                                    end
                                else
                                    dummy = 0;
                                end
                            end
                            clear zText z525 z625

                            if(handles.vCalcSOFIX == 1)
                                SOFITask_SofiXMod_Step2_CPU;
                                if(handles.vCalcSOFIX_Fourier == 1)
                                    SOFITask_SofiXFourierMod_CPU;
                                end
                            end
                        else
                            skipFile = skipFile - 1;
                        end
                    end
                end
            else
                handles.vActualChannel = 2;
                for actualFile=1: handles.numImages(1)
                    if(handles.vActualChannel == 1)
                        handles.vActualChannel = 2;
                    else
                        handles.vActualChannel = 1;
                    end

                    set(handles.lbArchivos,'Value',actualFile);

                    externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                    nameMATFile = strcat(externDirectory,externActualFile);
                    externActualFile = regexprep(externActualFile, '.tif', '');
                    externActualFile = regexprep(externActualFile, '.mat', '');
                    externActualFile = regexprep(externActualFile, 'Data_', '');
                    externActualFile = regexprep(externActualFile, '_OriginalData', '');

                    load(nameMATFile);
                    externActualFileBase = externActualFile;

                    %Evaluate Data
                    zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                    dummy = size(zText);
                    if(dummy(1) > 0)
                        zText = regexprep(zText, 'Z_', '');
                        zText = regexprep(zText, '_', '');
                        % Need Verify theory
                        z       = str2double(zText);
                        focpos  = 0;
                    else
                        z = handles.vMicZPos + stateActual*handles.vMicZStep;
                        focpos = handles.vMicFocPos;
                        stateActual = stateActual + 1;
                    end

                    z525 = size(regexp(externActualFileBase, '525', 'match'));
                    z625 = size(regexp(externActualFileBase, '625', 'match'));
                    if(z525(1) > 0)
                        lambda = 525;
                    elseif(z625(1) > 0)
                        lambda = 625;
                    elseif(handles.vUse2Channels)
                        if(handles.vActualChannel == 1)
                            lambda = handles.vMicLambda;
                        else
                            lambda = handles.vMicLambda2;
                        end
                    else
                        lambda = handles.vMicLambda;
                    end

                    clear zText z525 z625

                    if(handles.vCalcSOFIX == 1)
                        SOFITask_SofiXMod_CPU;
                        if(handles.vCalcSOFIX_Fourier == 1)
                            SOFITask_SofiXFourierMod_CPU;
                        end
                    end
                end

            end
        else
            externDirectory = char(handles.vCellFolder(1,1));
            %handles.vCellOutFolder(1,1);
            if(handles.vUseMDataFiles == 0)
                handles.vActualChannel = 2;
                stateActual = 0;
                skipFile  = 0;
                for actualFile=1: handles.numImages(1)
                    if(skipFile == 0)
                        if(handles.vActualChannel == 1)
                            handles.vActualChannel = 2;
                        else
                            handles.vActualChannel = 1;
                        end

                        set(handles.lbArchivos,'Value',actualFile);

                        externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                        nameFile = strcat(externDirectory,externActualFile);
                        externActualFile = regexprep(externActualFile, '.tif', '');
                        externActualFileBase = externActualFile;
                        SOFITask_SofiXMod_Step1_CPU;
                        nameMATFile = strcat(externDirectory,'Data_',externActualFileBase,'_OriginalData','.mat');
                        nameMATFileBase = nameMATFile;


                        %Evaluate Data
                        zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                        dummy = size(zText);
                        if(dummy(1) > 0)
                            zText = regexprep(zText, 'Z_', '');
                            zText = regexprep(zText, '_', '');
                            % Need Verify theory
                            z       = str2double(zText);
                            focpos  = 0;
                        else
                            z = handles.vMicZPos + stateActual*handles.vMicZStep;
                            focpos = handles.vMicFocPos;
                            stateActual = stateActual + 1;
                        end

                        z525 = size(regexp(externActualFileBase, '525', 'match'));
                        z625 = size(regexp(externActualFileBase, '625', 'match'));
                        if(z525(1) > 0)
                            lambda = 525;
                        elseif(z625(1) > 0)
                            lambda = 625;
                        elseif(handles.vUse2Channels)
                            if(handles.vActualChannel == 1)
                                lambda = handles.vMicLambda;
                            else
                                lambda = handles.vMicLambda2;
                            end
                        else
                            lambda = handles.vMicLambda;
                        end

                        %Evaluate Xnumber Split
                        dummy = 1;
                        actualPosition = actualFile + 1;
                        while dummy
                            if(actualFile < handles.numImages(1))
                                externActualFile = char(handles.vDataImagesInFolder(1,actualPosition));
                                nameFile = strcat(externDirectory,externActualFile);
                                externActualFile = regexprep(externActualFile, '.tif', '');
                                zText = size(regexp(externActualFile, externActualFileBase, 'match'));
                                if(zText(1)>0)
                                    actualPosition = actualPosition + 1;
                                    skipFile = skipFile + 1;

                                    SOFITask_SofiXMod_Step1_CPU;
                                else
                                    dummy = 0;
                                end
                            else
                                dummy = 0;
                            end
                        end
                        clear zText z525 z625

                        if(handles.vCalcSOFIX == 1)
                            SOFITask_SofiXMod_Step2_CPU;
                            if(handles.vCalcSOFIX_Fourier == 1)
                                SOFITask_SofiXFourierMod_CPU;
                            end
                        end
                    else
                        skipFile = skipFile - 1;
                    end
                end
            else
                 handles.vActualChannel = 2;
                for actualFile=1: handles.numImages(1)
                    if(handles.vActualChannel == 1)
                        handles.vActualChannel = 2;
                    else
                        handles.vActualChannel = 1;
                    end

                    set(handles.lbArchivos,'Value',actualFile);

                    externActualFile = char(handles.vDataImagesInFolder(1,actualFile));
                    nameMATFile = strcat(externDirectory,externActualFile);
                    externActualFile = regexprep(externActualFile, '.tif', '');
                    externActualFile = regexprep(externActualFile, '.mat', '');
                    externActualFile = regexprep(externActualFile, 'Data_', '');
                    externActualFile = regexprep(externActualFile, '_OriginalData', '');

                    load(nameMATFile);
                    externActualFileBase = externActualFile;

                    %Evaluate Data
                    zText = regexp(externActualFileBase, 'Z_.+_', 'match');
                    dummy = size(zText);
                    if(dummy(1) > 0)
                        zText = regexprep(zText, 'Z_', '');
                        zText = regexprep(zText, '_', '');
                        % Need Verify theory
                        z       = str2double(zText);
                        focpos  = 0;
                    else
                        z = handles.vMicZPos + stateActual*handles.vMicZStep;
                        focpos = handles.vMicFocPos;
                        stateActual = stateActual + 1;
                    end

                    z525 = size(regexp(externActualFileBase, '525', 'match'));
                    z625 = size(regexp(externActualFileBase, '625', 'match'));
                    if(z525(1) > 0)
                        lambda = 525;
                    elseif(z625(1) > 0)
                        lambda = 625;
                    elseif(handles.vUse2Channels)
                        if(handles.vActualChannel == 1)
                            lambda = handles.vMicLambda;
                        else
                            lambda = handles.vMicLambda2;
                        end
                    else
                        lambda = handles.vMicLambda;
                    end

                    clear zText z525 z625

                    if(handles.vCalcSOFIX == 1)
                        SOFITask_SofiXMod_CPU;
                        if(handles.vCalcSOFIX_Fourier == 1)
                            SOFITask_SofiXFourierMod_CPU;
                        end
                    end
                end

            end
        end
    end
    tiempoCPU = toc
elseif(vUsingGPU)
    tic
    tiempoGPU = toc
elseif(vUsingLocalWorkers)
    tic
    tiempoLocalWorkers = toc
elseif(vUsingClusterWorkers)    
    tic
    tiempoCluster = toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XXX_SOFI Calls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Disable Parallel conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if(vMatlabPoolSize)
%     matlabpool('close');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XXX_Disable Parallel conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
