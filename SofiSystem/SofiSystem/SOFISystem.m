function varargout = SOFISystem(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SOFISystem_OpeningFcn, ...
                   'gui_OutputFcn',  @SOFISystem_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SOFISystem is made visible.
function SOFISystem_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for SOFISystem
handles.output = hObject;
handles.vRecursiveSearch = 0;
handles.vUseFolders = 0;
handles.vUseFiles = 0;
handles.vUseMDataFiles = 0;
handles.vSaveImages = 1;
handles.vSaveMDataFiles = 1;
set(handles.cbSaveImages,'Value',1.0);
set(handles.cbSaveMDATA,'Value',1.0);
handles.vBaseFolder = '.';

handles.vCalcSOFIX = 1;
handles.vCalcSOFIX_Fourier = 0;
handles.vCalcSOFIX_Fourier_Mod = 0;
handles.vReadyForTest = 0;
handles.vRunning = 0;

handles.vHPCSelection = 0;
% Variables for SOFI
handles.vSofiOrder = 2;
handles.vSofiWin = 1e2;
handles.vUseSplit = 0;
handles.vUse2Channels = 0;
handles.vActualChannel = 1;
% Variables of Microscopie
% NA = 1.4; % numerical aperture
% n1 = 1.334; % ref. index of sample
% n = n1; 
% n2 = n1;
% d1 = [];
% d = 0;
% d2 = [];
% lambda = 0.625; % emission wavelength in micron
% mag = 160; % magnification
% pix = mag*0.100/4; % virtual pixel size in micron
handles.vMicNA = 1.4; % numerical aperture
handles.vMicN1  = 1.334; % ref. index of sample
handles.vMicLambda = 0.625; % emission wavelength in micron
handles.vMicLambda2 = 0.625; % emission wavelength in micron.. for 2nd channel
handles.vMicMagnification = 160; % magnification
handles.vMicFocPos = 0.0;
handles.vMicZPos = 0.0;
handles.vMicZStep = 0.0;

% Variables for load FIles... dummy fill of initial values
MAXNUM_IMAGES_IN_A_FOLDER = 30; % increase if you have more files in a folder
INITIALGROUP = 1;
handles.numFolders = 1;
handles.vCellFolder(1,INITIALGROUP) =  {'dummy'};
handles.vCellOutFolder(1,INITIALGROUP) = {'dummy'};
handles.numImages(INITIALGROUP) = 1;
handles.vDataImagesInFolder(1,1:MAXNUM_IMAGES_IN_A_FOLDER) = {'dummy'}; % only for set max dimensions of DATA structure

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SOFISystem wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = SOFISystem_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTIONS OF GENERIC SELECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % --- Executes on button press in pbSelectFolder.
    function pbSelectFolder_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vUseFolders = 1;
        handles.vUseFiles = 0;
        dummy = uigetdir(handles.vBaseFolder);
        if(dummy ~= 0)
            handles.vBaseFolder = dummy;
            clear dummy;
            handles.vBaseFolder = strcat(handles.vBaseFolder,'\');
            if(handles.vRecursiveSearch == 0)
                handles.numFolders = 1;
                set(handles.lbDirectorios,'String',cellstr(handles.vBaseFolder));
                handles.vCellFolder(1,1) =  {handles.vBaseFolder};
                handles.vCellOutFolder(1,1) = {handles.vBaseFolder};
                if(handles.vUseMDataFiles == 0)
                    tempFiles = dir(fullfile(handles.vBaseFolder,'*.tif*'));
                    dimTF = size(tempFiles);
                    handles.numImages(1) = 0;
                    for i=1: dimTF(1)
                        if(~tempFiles(i).isdir)
                            handles.vDataImagesInFolder(1,i) = {tempFiles(i).name};
                            handles.numImages(1) = handles.numImages(1) + 1;
                        end
                    end
                else % Use mat Data files saved before
                    tempFiles = dir(fullfile(handles.vBaseFolder,'*OriginalData.mat*'));
                    dimTF = size(tempFiles);
                    handles.numImages(1) = 0;
                    for i=1: dimTF(1)
                        if(~tempFiles(i).isdir)
                            handles.vDataImagesInFolder(1,i) = {tempFiles(i).name};
                            handles.numImages(1) = handles.numImages(1) + 1;
                        end
                    end
                end
                if(handles.numImages(1) ~= 0)
                    handles.vReadyForTest = 1;
                    set(handles.lbArchivos,'String',cellstr(handles.vDataImagesInFolder(1,1:handles.numImages(1))));
                else
                    set(handles.lbArchivos,'String',cellstr('No data available in the current folder'));
                end
            else % Folder contain a group of folders with Data
                tempDirs = dir(handles.vBaseFolder);
                numObjs = size(tempDirs);
                handles.numFolders = 0;
                for actualObject = 1 :numObjs(1)
                    if(~strcmp(tempDirs(actualObject).name,'.') && ~strcmp(tempDirs(actualObject).name,'..') && tempDirs(actualObject).isdir)
                        actualDir = tempDirs(actualObject).name;

                        handles.vCellFolder(1,actualObject) =  {actualDir};
                        handles.vCellOutFolder(1,actualObject) = {actualDir};
                        handles.numFolders = handles.numFolders + 1;
                        handles.numImages(actualObject) = 0;
                        if(handles.vUseMDataFiles == 0)
                            tempFiles = dir(fullfile(actualDir,'*.tif*'));
                            dimTF = size(tempFiles);
                            for i=1: dimTF(1)
                                if(~tempFiles(i).isdir)
                                    handles.vDataImagesInFolder(actualObject,i) = {tempFiles(i).name};
                                    handles.numImages(actualObject) = handles.numImages(actualObject) + 1;
                                    handles.vReadyForTest = 1;
                                end
                            end
                        else % Use mat Data files saved before
                            tempFiles = dir(fullfile(actualDir,'*OriginalData.mat*'));
                            dimTF = size(tempFiles);
                            for i=1: dimTF(1)
                                if(~tempFiles(i).isdir)
                                    handles.vDataImagesInFolder(actualObject,i) = {tempFiles(i).name};
                                    handles.numImages(actualObject) = handles.numImages(actualObject) + 1;
                                    handles.vReadyForTest = 1;
                                end
                            end
                        end
                    end
                end
                % validation... need be "1" in order to calc data.. someone
                % data need be useful
                handles.vReadyForTest = handles.vReadyForTest | 0;
                if(handles.numFolders == 0)
                    set(handles.lbDirectorios,'String',cellstr('Please... Select a Directory with Valid SubDir OR Unselect #Search In SubFolders#'));
                    set(handles.lbArchivos,'String',cellstr('No data available in the current folder'));
                    handles.vReadyForTest = 0;
                else
                    set(handles.lbDirectorios,'String',cellstr(handles.vCellFolder(1,1)));
                    if(handles.numImages(1) ~= 0)
                        set(handles.lbArchivos,'String',cellstr(handles.vDataImagesInFolder(1,1:handles.numImages(1))));
                    else
                        set(handles.lbArchivos,'String',cellstr('No data available in the current folder'));
                    end
                end
            end
        else
            set(handles.lbDirectorios,'String',cellstr('Please... Select a valid Directory'));
            set(handles.lbArchivos,'String',cellstr('No data available in the current folder'));
            handles.vReadyForTest = 0;
            handles.vBaseFolder = '.\';
        end
    end
    guidata(hObject, handles);
    
    % --- Executes on button press in pbSelectFiles.
    function pbSelectFiles_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vUseFolders = 0;
        handles.vUseFiles = 1;
 
        handles.numFolders = 1;
        dummy = handles.vBaseFolder;
        if(handles.vUseMDataFiles)
            [handles.vFiles, handles.vBaseFolder, filterindex] = uigetfile( ...
                                               {'*OriginalData.mat*','Saved MAT-files (*OriginalData.mat)'}, ...
                                                'Select Files to Process', ...
                                                handles.vBaseFolder, ...
                                                'MultiSelect', 'on');
        else
            [handles.vFiles, handles.vBaseFolder, filterindex] = uigetfile( ...
                                               {'*.tif*','Original Images (*.tif)'}, ...
                                                'Select Files to Process', ...
                                                handles.vBaseFolder, ...
                                                'MultiSelect', 'on');
        end
        
        if(ischar(handles.vBaseFolder))
            handles.vCellFolder(1,1) =  {handles.vBaseFolder};
            handles.vCellOutFolder(1,1) = {handles.vBaseFolder};
            set(handles.lbDirectorios,'String',cellstr(handles.vCellFolder(1,1)));
        else
            handles.vBaseFolder = dummy;
        end
        
        if(iscell(handles.vFiles))
            dummy = size(handles.vFiles);
            handles.numImages(1) = dummy(2);
            for actualFile= 1: dummy(2)
                handles.vDataImagesInFolder(1,actualFile) = {char(handles.vFiles(1,actualFile))};
                handles.vReadyForTest = 1;
            end
        elseif(ischar(handles.vFiles))
            handles.numImages(1) = 1;
            handles.vDataImagesInFolder(1,1) = {handles.vFiles};
            handles.vReadyForTest = 1;
        end
        set(handles.lbArchivos,'String',cellstr(handles.vDataImagesInFolder(1,1:handles.numImages(1))));
    end
    guidata(hObject, handles);

    % --- Executes on button press in cbRecursiveSearching.
    function cbRecursiveSearching_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vRecursiveSearch = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vRecursiveSearch)
    end
    guidata(hObject, handles);
    
    % --- Executes on button press in cbSaveImages.
    function cbSaveImages_Callback(hObject, eventdata, handles)
    % hObject    handle to cbSaveImages (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of cbSaveImages
    if(handles.vRunning == 0)
        handles.vSaveImages = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vSaveImages)
    end
    guidata(hObject, handles);
    
    % --- Executes on button press in cbSaveMDATA.
    function cbSaveMDATA_Callback(hObject, eventdata, handles)
    % hObject    handle to cbSaveMDATA (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of cbSaveMDATA
    if(handles.vRunning == 0)
        handles.vSaveMDataFiles = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vSaveMDataFiles)
    end
    guidata(hObject, handles);

    % --- Executes on button press in cbUseMDATA.
    function cbUseMDATA_Callback(hObject, eventdata, handles)
    % hObject    handle to cbUseMDATA (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of cbUseMDATA
    if(handles.vRunning == 0)
        handles.vUseMDataFiles = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vUseMDataFiles)
    end
    guidata(hObject, handles);

    % --- Executes on button press in pbRUN.
    function pbRUN_Callback(hObject, eventdata, handles)
    % hObject    handle to pbRUN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if(handles.vRunning == 0)
        handles.vRunning = 1;
        guidata(hObject, handles);
        % Disable actions...
        set(handles.pbSelectFolder,'Enable','off');
        set(handles.pbSelectFiles,'Enable','off');
        set(handles.pbRUN,'Enable','off');
        set(handles.cbUseMDATA,'Enable','off');
        set(handles.cbSaveImages,'Enable','off');
        set(handles.cbSaveMDATA,'Enable','off');
        set(handles.cbRecursiveSearching,'Enable','off');
        
        
        set(handles.lbArchivos,'Enable','off');
        set(handles.lbDirectorios,'Enable','off');
        
        set(handles.rbHPC_OFF,'Enable','off');
        set(handles.rbHPC_PCTCPU,'Enable','off');
        set(handles.rbHPC_PCT_GPU,'Enable','off');
        set(handles.rbHPC_Cluster,'Enable','off');
        
        set(handles.cbSOFIX,'Enable','off');
        set(handles.cbSOFIX_Fourier,'Enable','off');
        set(handles.cbSOFIX_Fourier_Mod,'Enable','off');
       
        %process
        disp('Init Process:');
        SOFICalls;
        %end Process
        
        handles.vRunning = 0;
        % Disable actions...
        set(handles.pbSelectFolder,'Enable','on');
        set(handles.pbSelectFiles,'Enable','on');
        set(handles.pbRUN,'Enable','on');
        set(handles.cbUseMDATA,'Enable','on');
        set(handles.cbSaveImages,'Enable','on');
        set(handles.cbSaveMDATA,'Enable','on');
        set(handles.cbRecursiveSearching,'Enable','on');
        
        set(handles.lbArchivos,'Enable','on');
        set(handles.lbDirectorios,'Enable','on');
        
        set(handles.rbHPC_OFF,'Enable','on');
        set(handles.rbHPC_PCTCPU,'Enable','on');
        set(handles.rbHPC_PCT_GPU,'Enable','on');
        set(handles.rbHPC_Cluster,'Enable','on');
        
        set(handles.cbSOFIX,'Enable','on');
        set(handles.cbSOFIX_Fourier,'Enable','on');
        set(handles.cbSOFIX_Fourier_Mod,'Enable','on');
        disp('End Process');
    end
    guidata(hObject, handles);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTIONS OF SHOW DATA LISTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % --- Executes on selection change in lbArchivos.
    function lbArchivos_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns lbArchivos contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from lbArchivos
    guidata(hObject, handles);

    % --- Executes during object creation, after setting all properties.
    function lbArchivos_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lbArchivos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);

    % --- Executes on selection change in lbDirectorios.
    function lbDirectorios_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
    end
    guidata(hObject, handles);

    % --- Executes during object creation, after setting all properties.
    function lbDirectorios_CreateFcn(hObject, eventdata, handles)
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTIONS OF HPC SELECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % --- Executes when selected object is changed in pHPC.
    function pHPC_SelectionChangeFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in pHPC 
    % eventdata  structure with the following fields (see UIBUTTONGROUP)
    %	EventName: string 'SelectionChanged' (read only)
    %	OldValue: handle of the previously selected object or empty if none was selected
    %	NewValue: handle of the currently selected object
    % handles    structure with handles and user data (see GUIDATA)
    if(hObject == handles.rbHPC_OFF)
        handles.vHPCSelection = 0;
    elseif(hObject == handles.rbHPC_PCTCPU)
        handles.vHPCSelection = 1;
    elseif(hObject == handles.rbHPC_PCT_GPU)
        handles.vHPCSelection = 2;
    elseif(hObject == handles.rbHPC_Cluster)
        handles.vHPCSelection = 3;
    end
    guidata(hObject, handles);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTIONS OF SOFI SELECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cbSPLIT_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vUseSplit = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vUseSplit)
    end
    guidata(hObject, handles);

    function cb2Channels_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vUse2Channels = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vUse2Channels)
    end
    guidata(hObject, handles);

    % --- Executes on button press in cbSOFIX_Fourier_Mod.
    function cbSOFIX_Fourier_Mod_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vCalcSOFIX = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vCalcSOFIX)
    end
    guidata(hObject, handles);

    % --- Executes on button press in cbSOFIX_Fourier.
    function cbSOFIX_Fourier_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vCalcSOFIX_Fourier = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vCalcSOFIX_Fourier)
    end
    guidata(hObject, handles);

    % --- Executes on button press in cbSOFIX.
    function cbSOFIX_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of cbSOFIX
    if(handles.vRunning == 0)
        handles.vCalcSOFIX_Fourier_Mod = get(hObject,'Value');
    else
        set(hObject,'Value',handles.vCalcSOFIX_Fourier_Mod);
    end
    guidata(hObject, handles);

    function editSofiOrder_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of editSofiOrder as text
    %        str2double(get(hObject,'String'))- returns contents of editSofiOrder as a double
    if(handles.vRunning == 0)
        handles.vSofiOrder = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vSofiOrder);
    end
    guidata(hObject, handles);
    
    function editSofiWin_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vSofiWin = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vSofiWin);
    end
    guidata(hObject, handles);


    function editMicNA_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicNA = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicNA);
    end
    guidata(hObject, handles);

    function editMicLambda_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicLambda = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicLambda);
    end
    guidata(hObject, handles);

    function editMicLambda2_Callback(hObject, eventdata, handles)    
    if(handles.vRunning == 0)
        handles.vMicLambda2 = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicLambda2);
    end
    guidata(hObject, handles);
    
    function editMicN1_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicN1 = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicN1);
    end
    guidata(hObject, handles);

    function editMicMagnification_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicMagnification = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicMagnification);
    end
    guidata(hObject, handles);

    function editMicZPos_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicZPos = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicZPos);
    end
    guidata(hObject, handles);

    function editMicFocPos_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicFocPos = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicFocPos);
    end
    guidata(hObject, handles);

    function editMicZStep_Callback(hObject, eventdata, handles)
    if(handles.vRunning == 0)
        handles.vMicZStep = str2double(get(hObject,'String'));
    else
        set(hObject,'String',handles.vMicZStep);
    end
    guidata(hObject, handles);
    
    % --- Executes during object creation, after setting all properties.
    function editMicMagnification_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicMagnification (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    % --- Executes during object creation, after setting all properties.
    function editMicNA_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicNA (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
    function editMicLambda_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicLambda (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
    function editMicN1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicN1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    % --- Executes during object creation, after setting all properties.
    function editSofiOrder_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editSofiOrder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
    function editSofiWin_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editSofiWin (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes during object creation, after setting all properties.
    function editMicZPos_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicZPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
    function editMicFocPos_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicFocPos (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes during object creation, after setting all properties.
    function editMicZStep_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicZStep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
    function editMicLambda2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to editMicLambda2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
