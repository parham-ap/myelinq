function varargout = MyelinQ(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MYELINQ MATLAB code for MyelinQ.fig
%
%   This code implements the method proposed in the article
%   "A novel image segmentation method for the evaluation of
%   inflammation-induced cortical and hippocampal white matter injury
%   in neonates".
%   
%   For more information, visit:
%   https://github.com/parham-ap/myelin_quantification
%
%   Copyright (c) 2018, Hady Ahmady Phoulady
%	Department of Computer Science,
%	University of Southern Maine, Portland, ME.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @MyelinQ_OpeningFcn, ...
                       'gui_OutputFcn',  @MyelinQ_OutputFcn, ...
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
end

% --- Executes just before MyelinQ is made visible.
function MyelinQ_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to MyelinQ (see VARARGIN)

    % Choose default command line output for MyelinQ
    handles.output = hObject;

    handles.imageFolder = cd;
    handles.roiFolder = cd;
    handles.segmentationFolder = cd;

    handles = LoadUserSettings(handles);

    if (~exist(handles.imageFolder, 'dir'))
        handles.imageFolder = cd;
    end
    appendText(handles.txtInfo, ['Image Folder: ', handles.imageFolder]);

    if (~exist(handles.roiFolder, 'dir'))
        handles.roiFolder = cd;
    end
    if (~exist(handles.segmentationFolder, 'dir'))
        handles.segmentationFolder = cd;
    end

    if (handles.chkUseROIs.Value)
        set(handles.btnROIFolder, 'Visible', 'on');
        appendText(handles.txtInfo, ['ROIs Folder: ', handles.roiFolder]);
    else
        set(handles.btnROIFolder, 'Visible', 'off');
    end

    if (handles.chkSaveSegmentation.Value)
        set(handles.btnSegmentationFolder, 'Visible', 'on');
        appendText(handles.txtInfo, ['Segmentation Folder: ', handles.segmentationFolder]);
    else
        set(handles.btnSegmentationFolder, 'Visible', 'off');
    end

    handles = LoadImageList(handles);
    set(handles.lstImageList, 'value', []);
    UpdateAnalyzeButtonCaption(handles);
    
    handles = ResetAndPushDataSummary(handles);

    guidata(hObject, handles);

    % UIWAIT makes MyelinQ wait for user response (see UIRESUME)
    % uiwait(handles.figMain);
end

% --- Outputs from this function are returned to the command line.
function varargout = MyelinQ_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on selection change in lstImageList.
function lstImageList_Callback(hObject, eventdata, handles)
    % hObject    handle to lstImageList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    UpdateAnalyzeButtonCaption(handles);

    guidata(hObject, handles);

    % Hints: contents = cellstr(get(hObject,'String')) returns lstImageList contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from lstImageList
end

% --- Executes during object creation, after setting all properties.
function lstImageList_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lstImageList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnImgFolder.
function btnImgFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to btnImgFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    returnValue = uigetdir(handles.imageFolder, 'Select image folder');
    % returnValue will be 0 (a double) if they click cancel.
    % returnValue will be the path (a string) if they clicked OK.
    if returnValue ~= 0
        % Assign the value if they didn't click cancel.
        handles.imageFolder = returnValue;
        handles = LoadImageList(handles);
    %     set(handles.txtFolder, 'string', handles.imageFolder);
        appendText(handles.txtInfo, ['Image Folder: ', handles.imageFolder]);
        guidata(hObject, handles);
        UpdateAnalyzeButtonCaption(handles);
        % Save the image folder in our ini file.
        SaveUserSettings(handles);
    end
end

% --- Executes on button press in btnSelectAllOrNone.
function btnSelectAllOrNone_Callback(hObject, eventdata, handles)
    % hObject    handle to btnSelectAllOrNone (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if (length(handles.lstImageList.Value) < length(handles.lstImageList.String))
        set(handles.lstImageList, 'value', 1: length(handles.lstImageList.String));
    else
        set(handles.lstImageList, 'value', []);
    end

    UpdateAnalyzeButtonCaption(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in chkUseROIs.
function chkUseROIs_Callback(hObject, eventdata, handles)
    % hObject    handle to chkUseROIs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of chkUseROIs
    if (get(hObject, 'Value'))
        set(handles.btnROIFolder, 'Visible', 'on');
    else
        set(handles.btnROIFolder, 'Visible', 'off');
    end
end

% --- Executes on button press in btnROIFolder.
function btnROIFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to btnROIFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    returnValue = uigetdir(handles.roiFolder, 'Select folder');
    if returnValue ~= 0
        % Assign the value if they didn't click cancel.
        handles.roiFolder = returnValue;
        handles = LoadROIs(handles);
        appendText(handles.txtInfo, ['ROIs Folder: ', handles.roiFolder]);
        guidata(hObject, handles);
        % Save the image folder in our ini file.
        SaveUserSettings(handles);
    end
end

% --- Executes on button press in chkSaveSegmentation.
function chkSaveSegmentation_Callback(hObject, eventdata, handles)
    % hObject    handle to chkSaveSegmentation (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of chkSaveSegmentation
    if (get(hObject, 'Value'))
        set(handles.btnSegmentationFolder, 'Visible', 'on');
    else
        set(handles.btnSegmentationFolder, 'Visible', 'off');
    end
end

% --- Executes on button press in btnSegmentationFolder.
function btnSegmentationFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to btnSegmentationFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    returnValue = uigetdir(handles.segmentationFolder, 'Select folder');
    if returnValue ~= 0
        handles.segmentationFolder = returnValue;
        appendText(handles.txtInfo, ['Segmentation Folder: ', handles.segmentationFolder]);
        guidata(hObject, handles);
        SaveUserSettings(handles);
    end
end

% --- Executes on button press in chkSaveSummary.
function chkSaveSummary_Callback(hObject, eventdata, handles)
    % hObject    handle to chkSaveSummary (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of chkSaveSummary
end

% --- Executes on button press in btnExit.
function btnExit_Callback(hObject, eventdata, handles)
    % hObject    handle to btnExit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    SaveUserSettings(handles);
    close(handles.figMain);
end


function txtInfo_Callback(hObject, eventdata, handles)
    % hObject    handle to txtInfo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of txtInfo as text
    %        str2double(get(hObject,'String')) returns contents of txtInfo as a double
end

% --- Executes during object creation, after setting all properties.
function txtInfo_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to txtInfo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnAnalyze.
function btnAnalyze_Callback(hObject, eventdata, handles)
    % hObject    handle to btnAnalyze (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    Selected = get(handles.lstImageList, 'value');
    numberOfSelectedFiles = length(Selected);
    numberOfFilesAnalyzed = 0;

    ListOfImageNames = get(handles.lstImageList, 'string');

    handles = ResetAndPushDataSummary(handles);
    handles.unitTomM2 = struct('Inch', 25.4^2, 'Centimeter', 10^2, 'Meter', 1000^2, 'Millimeter', 1^2, 'Nanometer', 0.000001^2);

    for j = 1 : numberOfSelectedFiles
        imageName = strcat(cell2mat(ListOfImageNames(Selected(j))));
        imageFullFileName = fullfile(handles.imageFolder, strcat(cell2mat(ListOfImageNames(Selected(j)))));

        appendText(handles.txtInfo, sprintf('(%d/%d) Analyzing %s...', j, numberOfSelectedFiles, imageName));

        handles = AnalyzeSingleImage(handles, imageFullFileName);
        numberOfFilesAnalyzed = numberOfFilesAnalyzed + 1;
    end

    roiInd = cell(length(handles.roiSub), 1);
    for s = 1: length(roiInd)
        roiInd{s} = find(cellfun(@(c) ~isempty(strfind(c, handles.roiSub(s).name)), handles.dataSummary(:, 3)));
    end
    handles.dataSummary = handles.dataSummary(vertcat(1, vertcat(roiInd{:}), setdiff((2: size(handles.dataSummary, 1)), vertcat(roiInd{:}))'), :);

    FillUpTable(handles)

    if (handles.chkSaveSummary.Value)
        appendText(handles.txtInfo, 'Saving summary excel file...');
        xlswrite(fullfile(handles.imageFolder, 'summary.xls'), handles.dataSummary);
        ExcelAutoFitDeleteSheet(fullfile(handles.imageFolder, 'summary.xls'), 'Sheet1');
    end

    appendText(handles.txtInfo, sprintf('Done analyzing %d files.', numberOfFilesAnalyzed));

    guidata(hObject, handles);
end

function handles = AnalyzeSingleImage(handles, fullImageFileName)
    tifInfo = imfinfo(fullImageFileName);
    theImage = imread(fullImageFileName);

    IG = im2double(rgb2gray(theImage));


    thresh = multithresh(IG, 2);
    symmetryMask = IG <= thresh(1);

    minSize = round(650 * (tifInfo.XResolution * tifInfo.YResolution) / handles.unitTomM2.(tifInfo.ResolutionUnit) / 1000000);
    if (isempty(minSize))
        minSize = 489;
    end
    IM = bwareaopen(imdilate(symmetryMask, strel('disk', 5, 0)), minSize);

    IG = imfilter(IG, fspecial('gaussian', 3, 1));
    IG(~IM) = max(IG(:));
    
    neighbourhood = floor(200 * sqrt(tifInfo.XResolution * tifInfo.YResolution) / sqrt(handles.unitTomM2.(tifInfo.ResolutionUnit)) / 1000);
    neighbourhood = neighbourhood - mod(neighbourhood, 2) + 1;
    if (isempty(neighbourhood))
        neighbourhood = 173;
    end
    IB2 = ~imbinarize(IG, adaptthresh(im2double(rgb2gray(theImage)), .75, 'Statistic', 'Gaussian', 'NeighborhoodSize', neighbourhood));

    tmpData = cell(3, 1);
    [~, tmpData{1}, ext] = fileparts(fullImageFileName);
    pix = nnz(IB2);

    boundaryIB2 = PutBoundaryOnImage(theImage, IB2);
    if (handles.chkSaveSegmentation.Value)
        if (~exist(fullfile(handles.segmentationFolder, [tmpData{1}, '.png']), 'file'))
            imwrite(boundaryIB2, fullfile(handles.segmentationFolder, [tmpData{1}, '.png']))
        end
        if (~exist(fullfile(handles.segmentationFolder, [tmpData{1}, '_Mask.png']), 'file'))
            imwrite(IB2, fullfile(handles.segmentationFolder, [tmpData{1}, '_Mask.png']))
        end
    end
    tmpData{2} = num2str(pix / (tifInfo.XResolution * tifInfo.YResolution) * handles.unitTomM2.(tifInfo.ResolutionUnit));
    tmpData{3} = '-';
    appendText(handles.txtInfo, sprintf('\tMyelin area: %s', tmpData{2}));

    handles.dataSummary(handles.dataIndex, :) = tmpData;
    handles.dataIndex = handles.dataIndex + 1;

    if (handles.chkUseROIs.Value)

        for s = 1: length(handles.roiSub)
            if (exist(fullfile(handles.roiFolder, handles.roiSub(s).name, [tmpData{1}, ext]), 'file'))
                roiI = imread(fullfile(handles.roiFolder, handles.roiSub(s).name, [tmpData{1}, ext]));
                roiMask = imfill(roiI(:, :, 1) > 200 & roiI(:, :, 2) < 50 & roiI(:, :, 3) < 50, 'holes');
                if (size(theImage, 1) ~= size(roiI, 1))
                    roiMask = flip(roiMask)';
                end
                IB2tmp = IB2 & roiMask;
                pix = nnz(IB2tmp);
                boundaryIB2 = PutBoundaryOnImage(theImage, IB2tmp);
                boundaryIB2 = PutBoundaryOnImage(boundaryIB2, roiMask, [1, 0, 0], 5);
                if (handles.chkSaveSegmentation.Value)
                    if (~exist(fullfile(handles.segmentationFolder, [tmpData{1}, sprintf('_ROI_%s.png', handles.roiSub(s).name)]), 'file'))
                        imwrite(boundaryIB2, fullfile(handles.segmentationFolder, [tmpData{1}, sprintf('_ROI_%s.png', handles.roiSub(s).name)]))
                    end
                    if (~exist(fullfile(handles.segmentationFolder, [tmpData{1}, sprintf('_ROI_%s_Mask.png', handles.roiSub(s).name)]), 'file'))
                        imwrite(IB2tmp, fullfile(handles.segmentationFolder, [tmpData{1}, sprintf('_ROI_%s_Mask.png', handles.roiSub(s).name)]))
                    end
                end
                tmpData{2} = num2str(pix / (tifInfo.XResolution * tifInfo.YResolution) * handles.unitTomM2.(tifInfo.ResolutionUnit));
                tmpData{3} = handles.roiSub(s).name;
                appendText(handles.txtInfo, sprintf('\tMyelin area in %s: %s', handles.roiSub(s).name, tmpData{2}));
                handles.dataSummary(handles.dataIndex, :) = tmpData;
                handles.dataIndex = handles.dataIndex + 1;
            end
        end
    end
end

function UpdateAnalyzeButtonCaption(handles)
    Selected = get(handles.lstImageList, 'value');
    if (length(Selected) >= 1)
        handles.btnAnalyze.Enable = 'on';
        if (length(Selected) == 1)
            set(handles.btnAnalyze, 'string', sprintf('Analyze %d image...', length(Selected)));
        else
            set(handles.btnAnalyze, 'string', sprintf('Analyze %d images...', length(Selected)));
        end
    else
        set(handles.btnAnalyze, 'string', 'Analyze');
        handles.btnAnalyze.Enable = 'off';
    end
end

function SaveUserSettings(handles)
    lastUsedImageFolder = handles.imageFolder;
    lastUsedROIFolder = handles.roiFolder;
    lastUsedSegmentationFolder = handles.segmentationFolder;

    guiSettings.chkUseROIs = get(handles.chkUseROIs, 'Value');
    guiSettings.chkSaveSegmentation = get(handles.chkSaveSegmentation, 'Value');
    guiSettings.chkSaveSummary = get(handles.chkSaveSummary, 'Value');

    save([mfilename('fullpath'), '.mat'], 'lastUsedImageFolder', 'lastUsedROIFolder', 'lastUsedSegmentationFolder', 'guiSettings');
end

function handles = LoadUserSettings(handles)
    if exist([mfilename('fullpath'), '.mat'], 'file')
        initialValues = load([mfilename('fullpath'), '.mat']);
        
        handles.imageFolder = initialValues.lastUsedImageFolder;
        handles.roiFolder = initialValues.lastUsedROIFolder;
        handles.segmentationFolder = initialValues.lastUsedSegmentationFolder;

        set(handles.chkUseROIs, 'Value', initialValues.guiSettings.chkUseROIs);
        set(handles.chkSaveSegmentation, 'Value', initialValues.guiSettings.chkSaveSegmentation);
        set(handles.chkSaveSummary, 'Value', initialValues.guiSettings.chkSaveSummary);
    else
        SaveUserSettings(handles);
    end
end

function handles = LoadImageList(handles)
    imageFiles = [dir(fullfile(handles.imageFolder, '*.tif')); dir(fullfile(handles.imageFolder, '*.tiff'))];
    set(handles.lstImageList, 'string', {imageFiles.name});
    set(handles.lstImageList, 'value', []);

%     guidata(handles.lstImageList, handles);
end

function handles = LoadROIs(handles)
    handles.roiSub = dir(handles.roiFolder);
    handles.roiSub(1: 2) = [];
    handles.roiSub(~[handles.roiSub.isdir]) = [];

%     handles.roiFiles = cell(length(handles.roiSub), 1);
%     for s = 1: length(handles.roiSub)
%         handles.roiFiles{s} = dir(fullfile(handles.roiFolder, handles.roiSub(s).name, '*.tif'));
%     end
end

function imageWithBoundary = PutBoundaryOnImage(image, boundaryImageOrPoints, color, boundaryThickness)
    if (~exist('color', 'var'))
        color = [0, 1, 0];
    end
    if any(color > 1)
        if isa(image, 'uint8')
            color = color / 255;
        elseif isa(image, 'uint16')
            color = color / 65535;
        end
    end
    image = im2double(image);

    if (nargin < 4)
        boundaryThickness = 1;
    end
    if (size(boundaryImageOrPoints, 2) == 1)
        points = round(boundaryImageOrPoints);
    elseif (size(boundaryImageOrPoints, 2) == 2)
        boundaryImage = false([size(image, 1), size(image, 2)]);
        points = round(sub2ind([size(image, 1), size(image, 2)], round(boundaryImageOrPoints(:, 1)), round(boundaryImageOrPoints(:, 2))));
        boundaryImage(points) = true;
        points = find(imdilate(bwmorph(boundaryImage, 'remove'), strel('disk', boundaryThickness - 1)));
    else
        points = find(imdilate(bwmorph(boundaryImageOrPoints, 'remove'), strel('disk', boundaryThickness - 1)));
    end
    imageWithBoundary = image;
    if ((size(image, 3) > 1) || (size(color, 2) > 1))
        if (size(image, 3) == 1)
            imageWithBoundary = repmat(image, 1, 1, 3);
        end
        if (size(color, 2) == 1)
            color = repmat(color, 1, 3);
        end
        if (size(color, 1) == 1)
            imageWithBoundary(points) = color(1);
            imageWithBoundary(size(image, 1) * size(image, 2) + points) = color(2);
            imageWithBoundary(2 * size(image, 1) * size(image, 2) + points) = color(3);
        else
            [labeledImage, totalLabels] = bwlabel(boundaryImageOrPoints, 4);
            for i = 1: totalLabels
                points = find(imdilate(bwmorph(labeledImage == i, 'remove'), strel('disk', boundaryThickness - 1)));
                imageWithBoundary(points) = color(i, 1);
                imageWithBoundary(size(image, 1) * size(image, 2) + points) = color(i, 2);
                imageWithBoundary(2 * size(image, 1) * size(image, 2) + points) = color(i, 3);
            end
        end
    else
        imageWithBoundary(points) = color(1);
    end
end

function ExcelAutoFitDeleteSheet(excelFilename, sheets)
    hExcel = actxserver('Excel.Application');
    hWorkbook = hExcel.Workbooks.Open(excelFilename);
    hExcel.DisplayAlerts = false;
    if (exist('sheets', 'var'))
        if (ischar(sheets))
            sheets = {sheets};
        end
        for i = 1: length(sheets)
            try
                hExcel.ActiveWorkbook.Worksheets.get('Item', sheets{i}).Delete
            catch
            end
        end
    end

    for w = hWorkbook.Sheets.Count: -1: 1
        hWorkbook.Sheets.Item(w).Activate;
        hExcel.Cells.Select;
        hExcel.Cells.EntireColumn.AutoFit;
        hExcel.Selection.HorizontalAlignment = 3;
        hExcel.Selection.VerticalAlignment = 2;
        hExcel.Range('A1').Select;
    end

    hWorkbook.Save
    hWorkbook.Close
    hExcel.Quit
end

function handles = ResetAndPushDataSummary(handles)
    handles.dataSummary = {};
    handles.dataSummary(1, 1: 3) = {'Image Name', 'Milimeter^2', 'ROI'};
    handles.dataIndex = 2;
    FillUpTable(handles);
end

function FillUpTable(handles)
    set(handles.tblResult, 'ColumnName', handles.dataSummary(1, :));
    set(handles.tblResult, 'RowName', (1: size(handles.dataSummary, 1) - 1));
    set(handles.tblResult, 'ColumnWidth', {180, 88, 100});
    set(handles.tblResult, 'data', handles.dataSummary(2: end, :));
    pause(0.01)
end

function appendText(hObject, text)
    currentValue = cellstr(get(hObject,'String'));
    currentValue{end + 1} = text;
    set(hObject, 'String', currentValue);
    jhEdit = findjobj(hObject);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(jEdit.getDocument.getLength);
    pause(0.0001)
end
