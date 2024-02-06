function Callback_pushbutton_CTDataPanel_SelectCTDataSet(src, evnt)

gFig = ancestor(src, 'Figure');
gData = guidata(gFig);

%% CT dir
td = tempdir;
fd_info = fullfile(td, 'DLAS');
ffn_info = fullfile(fd_info, 'dirInfo.mat');
if ~exist(fd_info, 'dir')
    mkdir(fd_info);
    [CTPath] = uigetdir();
    save(ffn_info, 'CTPath');
else
    if exist(ffn_info, 'file')
        load(ffn_info);
        [CTPath] = uigetdir(fileparts(CTPath));
    else
        [CTPath] = uigetdir();
        save(ffn_info, 'CTPath');
    end
end

[RefPath, vol_name]=fileparts(CTPath);
[DataPath, ~]=fileparts(RefPath);
matPath = fullfile(DataPath, 'mat');
if ~exist(matPath, 'dir')
    mkdir(matPath);
end

%% volume 

hWB = waitbar(0, 'Loading volume ...');

fn_mat_vol = [vol_name, '_vol.mat'];
ffn_mat_vol = fullfile(matPath, fn_mat_vol);
ffd_vol = fullfile(RefPath, vol_name);
if ~exist(ffn_mat_vol, 'file')
    % volume
    FL = dir(fullfile(ffd_vol, 'CT*'));
    nFL = length(FL);
    fnL = strings(nFL, 1);
    for n = 1:nFL
        fnL(n) = fullfile(FL(n).folder, FL(n).name);
    end
    mv = medicalVolume(fnL);
    save(ffn_mat_vol, 'mv');
    gData.mv = mv;
else
    voldata = load(ffn_mat_vol);
    gData.mv = voldata.mv;
end

%% contour data
waitbar(.5, hWB, 'Loading Plan Structrues...');

fn_mat_cont = [vol_name, '_cont.mat'];
ffn_mat_cont = fullfile(matPath, fn_mat_cont);
if ~exist(ffn_mat_cont, 'file')
    %  contour
    FL = dir(fullfile(ffd_vol, '*RT*'));
    ffn = fullfile(FL(1).folder, FL(1).name);
    info = dicominfo(ffn);
    cont = dicomContours(info);

    % match to slice zz
    zz = gData.mv.VolumeGeometry.Position(:, 3);
    nSlice = length(zz);
    nST = size(cont.ROIs, 1);

    hasST = false(nST, nSlice);
    dataST = cell(nST, nSlice);
    for n = 1:nST
        ContData = cont.ROIs.ContourData{n};
        for p = 1:length(ContData)
            z = ContData{p}(1, 3);
            idx = find(abs(z-zz)<1e-3);
            hasST(n, idx) = 1;
            dataST{n, idx} = ContData{p};
        end
    end

    save(ffn_mat_cont, 'zz', 'cont', 'hasST', 'dataST');

    Oname =  cont.ROIs.Name;
    gData.cont.O.zz = zz;
    gData.cont.O.cont = cont;
    gData.cont.O.hasST = hasST;
    gData.cont.O.dataST = dataST;
else
    contdata = load(ffn_mat_cont);
    gData.cont.O.zz = contdata.zz;
    gData.cont.O.cont = contdata.cont;
    gData.cont.O.hasST = contdata.hasST;
    gData.cont.O.dataST = contdata.dataST;
    Oname =  contdata.cont.ROIs.Name;
end


% Siemens
waitbar(.6, hWB, 'Loading Siemens Structrues...');

fn_mat_cont_SM = [vol_name, '_cont_SM.mat'];
ffn_mat_cont_SM = fullfile(matPath, fn_mat_cont_SM);
if ~exist(ffn_mat_cont_SM, 'file')
    fd = dir(fullfile(DataPath, 'Siemens', ['*', vol_name(end)]));
    ffd = fullfile(fd.folder, fd(1).name);
    fn = dir(fullfile(ffd, ['*RT*.dcm']));
    ffn = fullfile(ffd, fn(1).name);
    info = dicominfo(ffn);
    cont_SM = dicomContours(info);
    
    SMname = cont_SM.ROIs.Name;
    
    SMT = readtable('STTable.xlsx', 'sheet', 'SM');
    ind = cellfun(@isempty, SMT.Plan);
    SMT = SMT(~ind, :);

    hasST_SM = false(size(gData.cont.O.hasST));
    dataST_SM = cell(size(gData.cont.O.dataST));

    for m = 1:size(SMT,1 )
        Onm = SMT.Plan{m}(2:end-1);
        idxO = find(strcmp(Onm, Oname));
        if ~isempty(idxO)
            SMnm = SMT.Siemens{m}(2:end-1);
            idxSM = find(strcmp(SMnm, SMname));
            SMcont = cont_SM.ROIs.ContourData{idxSM};
    
            % match zz
            zz = gData.cont.O.zz;
            nSlice = length(zz);
            for p = 1:length(SMcont)
                z = SMcont{p}(1, 3);
                idx = find(abs(z-zz)<1e-3);
                hasST_SM(idxO, idx) = 1;
                dataST_SM{idxO, idx} = SMcont{p};
            end
        end
    end

    save(ffn_mat_cont_SM, 'hasST_SM', 'dataST_SM');

    gData.cont.SM.hasST_SM = hasST_SM;
    gData.cont.SM.dataST_SM = dataST_SM;

else
    contdata_SM = load(ffn_mat_cont_SM);
    gData.cont.SM.hasST_SM = contdata_SM.hasST_SM;
    gData.cont.SM.dataST_SM = contdata_SM.dataST_SM;
end

% RayStation
waitbar(.7, hWB, 'Loading RayStation Structrues...');

fn_mat_cont_RS = [vol_name, '_cont_RS.mat'];
ffn_mat_cont_RS = fullfile(matPath, fn_mat_cont_RS);
if ~exist(ffn_mat_cont_RS, 'file')
    fd = dir(fullfile(DataPath, 'RayStation', ['*', vol_name(end)]));
    ffd = fullfile(fd.folder, fd(1).name);
    fn = dir(fullfile(ffd, ['RS*.dcm']));
    ffn = fullfile(ffd, fn(1).name);
    info = dicominfo(ffn);
    cont_RS = dicomContours(info);
    
    RSname = cont_RS.ROIs.Name;
    
    RST = readtable('STTable.xlsx', 'sheet', 'RS');
    ind = cellfun(@isempty, RST.Plan);
    RST = RST(~ind, :);

    hasST_RS = false(size(gData.cont.O.hasST));
    dataST_RS = cell(size(gData.cont.O.dataST));

    for m = 1:size(RST,1 )
        Onm = RST.Plan{m}(2:end-1);
        idxO = find(strcmp(Onm, Oname));

        if ~isempty(idxO)
            RSnm = RST.RayStation{m}(2:end-1);
            idxRS = find(strcmp(RSnm, RSname));
            RScont = cont_RS.ROIs.ContourData{idxRS};
    
            % match zz
            zz = gData.cont.O.zz;
            nSlice = length(zz);
            for p = 1:length(RScont)
                z = RScont{p}(1, 3);
                idx = find(abs(z-zz)<1e-3);
                hasST_RS(idxO, idx) = 1;
                dataST_RS{idxO, idx} = RScont{p};
            end
        end
    end

    save(ffn_mat_cont_RS, 'hasST_RS', 'dataST_RS');

    gData.cont.RS.hasST_RS = hasST_RS;
    gData.cont.RS.dataST_RS = dataST_RS;

else
    contdata_RS = load(ffn_mat_cont_RS);
    gData.cont.RS.hasST_RS = contdata_RS.hasST_RS;
    gData.cont.RS.dataST_RS = contdata_RS.dataST_RS;
end

% Oncosoft
waitbar(.8, hWB, 'Loading Oncosoft Structrues...');

fd = dir(fullfile(DataPath, 'Oncosoft', ['*', vol_name(end)]));
ffd = fullfile(fd.folder, fd(1).name);
gData.cont.OS.ffd = ffd;

OST = readtable('STTable.xlsx', 'sheet', 'OS');
ind = cellfun(@isempty, OST.Plan);
OST = OST(~ind, :);
gData.cont.OS.OST = OST;

% 
% FL = dir(fullfile(ffd, '*.nii'));
% 
% OSname = cell(length(FL), 1);
% for n = 1:length(FL)
%     junk = FL(n).name;
%     ind = strfind(junk, 'ST');
%     junk1 = junk(ind(1):end);
%     ind = strfind(junk1, '_');
%     idx1 = ind(2)+1;
%     ind = strfind(junk1, '.');
%     idx2 = ind(end)-1;
%     OSname{n} = junk1(idx1:idx2);
% end



% fn = dir(fullfile(ffd, ['RS*.dcm']));
% ffn = fullfile(ffd, fn(1).name);
% info = dicominfo(ffn);
% cont_RS = dicomContours(info);

%%
guidata(gFig, gData);

%% view

waitbar(.9, hWB, 'Loading Slices...');

% CT
mv = gData.mv;
[nImg, mImg, nSlice] = size(mv.Voxels);
x0 = mv.VolumeGeometry.Position(1,1);
y0 = mv.VolumeGeometry.Position(1,2);
dx = mv.VolumeGeometry.PixelSpacing(1,1);
dy = mv.VolumeGeometry.PixelSpacing(1,2);
xWL(1) = x0-dx/2;
xWL(2) = xWL(1)+dx*nImg;
yWL(1) = y0-dy/2;
yWL(2) = yWL(1)+dy*mImg;
RA = imref2d([mImg nImg], xWL, yWL);
gData.Panel.View.RA = RA;

gData.nSlice = nSlice;

% RAGrid.xx = RA.XWorldLimits(1)+dx/2:dx:RA.XWorldLimits(2)-dx/2;
% RAGrid.yy = RA.YWorldLimits(1)+dy/2:dy:RA.YWorldLimits(2)-dy/2;
% gData.Panel.View.RAGrid = RAGrid;

iSlice = 1;
% axis and image
I = mv.Voxels(:, :, iSlice);
I = I';  
I = rescale(I);
hA = gData.Panel.View.Axial.hAxis;
gData.View.hI = imshow(I, RA, [], 'Parent', hA);
hold(hA, 'on');

% slider
hSS =  gData.Panel.Slider.hSlider;
hSS.Limits = [1 nSlice];
hSS.Value = iSlice;

% contour O
cont = gData.cont.O.cont;
T = cont.ROIs;
nR = size(T, 1);
Structure = T.Name;
O = cell(nR, 1);
for n=1:nR
    O{n} = false;
end

% Siemens, RayStation, Oncosoft
waitbar(.8, hWB, 'Initializing Table...');

SM = cell(nR, 1);
RS = SM;
OS = SM;

T = table(Structure, O, SM, RS, OS);
gData.Panel.STTable.hTable.Data = T;
gData.Panel.STTable.hTable.ColumnEditable= [false true true true true];

% slice 1
hasST = gData.cont.O.hasST;
uit = gData.Panel.STTable.hTable;
s1 = uistyle('BackgroundColor', 'w', 'FontWeight', 'bold');
addStyle(uit, s1, 'column', 1)

% plan ST
ind = find(hasST(:, iSlice));
for n = 1:length(ind)
    s = uistyle('BackgroundColor', gData.cont.O.cont.ROIs.Color{ind(n)}/255);
    addStyle(uit, s, 'cell', [ind(n), 1])
    addStyle(uit, s, 'cell', [ind(n), 2])
end

% Siemens ST
hasST_SM =  gData.cont.SM.hasST_SM;
dataST_SM = gData.cont.SM.dataST_SM;
ind_SM = find(hasST_SM(:, iSlice));
s = uistyle('BackgroundColor', gData.cont.SM.CC);
for n = 1:length(ind_SM) 
    addStyle(uit, s, 'cell', [ind_SM(n), 3])
end

% RayStation ST
hasST_RS =  gData.cont.RS.hasST_RS;
dataST_RS = gData.cont.RS.dataST_RS;
ind_RS = find(hasST_RS(:, iSlice));
s = uistyle('BackgroundColor', gData.cont.RS.CC);
for n = 1:length(ind_RS) 
    addStyle(uit, s, 'cell', [ind_RS(n), 4])
end

% initialize contour
MS = 12;
MS1 = 12;
MS2 = 24;

gData.View.hC.O = line(hA, 'XData', [], 'YData', [], 'Color', 'k', 'Marker', '.', 'MarkerSize', MS);    
gData.View.hC.O1 = line(hA, 'XData', [], 'YData', [], 'Color', 'g', 'Marker', 'o', 'MarkerSize', MS1, 'LineWidth', 2);    
gData.View.hC.O2 = line(hA, 'XData', [], 'YData', [], 'Color', 'r', 'Marker', '.', 'MarkerSize', MS2);    

gData.View.hC.SM = line(hA, 'XData', [], 'YData', [], 'Color', gData.cont.SM.CC, 'Marker', '.', 'MarkerSize', MS);    
gData.View.hC.SM1 = line(hA, 'XData', [], 'YData', [], 'Color', 'g', 'Marker', 'o', 'MarkerSize', MS1, 'LineWidth', 2);    
gData.View.hC.SM2 = line(hA, 'XData', [], 'YData', [], 'Color', 'r', 'Marker', '.', 'MarkerSize', MS2);    

gData.View.hC.RS = line(hA, 'XData', [], 'YData', [], 'Color', gData.cont.RS.CC, 'Marker', '.', 'MarkerSize', MS);    
gData.View.hC.RS1 = line(hA, 'XData', [], 'YData', [], 'Color', 'g', 'Marker', 'o', 'MarkerSize', MS1, 'LineWidth', 2);    
gData.View.hC.RS2 = line(hA, 'XData', [], 'YData', [], 'Color', 'r', 'Marker', '.', 'MarkerSize', MS2);    

green = cat(3, ones(size(I)), ones(size(I)), zeros(size(I)));
J = false(size(I));
gData.View.hC.OS.mask = imshow(green, RA, 'parent', hA);
set(gData.View.hC.OS.mask, 'AlphaData', J); 
gData.View.hC.OS.Line = line(hA, 'XData', [], 'YData', [], 'Color', gData.cont.OS.CC, 'Marker', '.', 'MarkerSize', MS);    
gData.View.hC.OS.Line1 = line(hA, 'XData', [], 'YData', [], 'Color', 'g', 'Marker', 'o', 'MarkerSize', MS1, 'LineWidth', 2);    
gData.View.hC.OS.Line2 = line(hA, 'XData', [], 'YData', [], 'Color', 'r', 'Marker', '.', 'MarkerSize', MS2);    

waitbar(1, hWB, 'Bingo!');
pause(1);
close(hWB);
guidata(gFig, gData);

% gData.Panel.CTDataSet.Comp.popupmenu.SelectCTDataSet.String = {FL.name};
% gData.Panel.CTDataSet.Comp.popupmenu.SelectCTDataSet.Enable = 'on';
% 
% gData.File.CTFolderList = FL;
% guidata(gFig, gData);
% 
% 
% pum = gData.Panel.CTDataSet.Comp.popupmenu.SelectCTDataSet;
% fd_vol_name = pum.String{pum.Value};
% 
% fd1 = gData.File.CTFolderList(1).folder;
% ffd_vol = fullfile(fd1, fd_vol_name);
% 
% mat_fd = fullfile(fileparts(fd1), 'mat');
% if ~exist(mat_fd, 'dir')
%     mkdir(mat_fd);
% end
% 
% 

% 

% 
% 
% % slider
% hSS =  gData.Panel.Slider.Comp.hSlider;
% hSS.Min = 1;
% hSS.Max = nSlice;
% hSS.Value = iSlice;
% 
% gData.Panel.Slider.Comp.hText.String = [num2str(iSlice), '/', num2str(nSlice)];
% 
% gData.Panel.Slider.hPanel.Visible = 'on';
% 
% % contour O
% cont = gData.cont.O;
% T = cont.ROIs;
% nR = size(T, 1);
% SN = T.Name;
% SL = cell(nR, 1);
% for n=1:nR
%     SL{n} = false;
% end
% 
% OT = gData.Panel.STSelection.hTable.O;
% OT.Data = [SN, SL];
% 
% gData.OT = OT;
% 
% 
% 
% % % Body Boundary
% %     gData.Panel.View.hBB(iA) = line(hA(iA), 'XData', [], 'YData', [], 'Color', 'b');
% %     gData.Panel.View.hBB(iA).Visible = 'off';
