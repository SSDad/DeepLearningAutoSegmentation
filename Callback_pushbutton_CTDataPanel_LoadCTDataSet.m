function Callback_pushbutton_CTDataPanel_LoadCTDataSet(src, evnt)

gFig = ancestor(src, 'Figure');
gData = guidata(gFig);

pum = gData.Panel.CTDataSet.Comp.popupmenu.SelectCTDataSet;
fd_vol_name = pum.String{pum.Value};

fd1 = gData.File.CTFolderList(1).folder;
ffd_vol = fullfile(fd1, fd_vol_name);

mat_fd = fullfile(fileparts(fd1), 'mat');
if ~exist(mat_fd, 'dir')
    mkdir(mat_fd);
end

fn_mat_vol = [fd_vol_name, '_vol.mat'];
ffn_mat_vol = fullfile(mat_fd, fn_mat_vol);
fn_mat_cont = [fd_vol_name, '_cont.mat'];
ffn_mat_cont = fullfile(mat_fd, fn_mat_cont);

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

    %  contour
    FL = dir(fullfile(ffd_vol, '*RT*'));
    ffn = fullfile(FL(1).folder, FL(1).name);
    info = dicominfo(ffn);
    cont = dicomContours(info);
    save(ffn_mat_cont, 'cont');

else
    voldata = load(ffn_mat_vol);
    contdata = load(ffn_mat_cont);
end

gData.mv = voldata.mv;
gData.cont.O = contdata.cont;
guidata(gFig, gData);

% view
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

% dy = RA.PixelExtentInWorldX;
% dy = RA.PixelExtentInWorldY;
RAGrid.xx = RA.XWorldLimits(1)+dx/2:dx:RA.XWorldLimits(2)-dx/2;
RAGrid.yy = RA.YWorldLimits(1)+dy/2:dy:RA.YWorldLimits(2)-dy/2;
% gData.Panel.View.RAGrid = RAGrid;

iSlice = 1;
% axis and image
I = mv.Voxels(:, :, iSlice);
I = I';
hA = gData.Panel.View.Axial.hAxis;
hI = imshow(I, RA, [], 'Parent', hA);    

gData.hI = hI;


% slider
hSS =  gData.Panel.Slider.Comp.hSlider;
hSS.Min = 1;
hSS.Max = nSlice;
hSS.Value = iSlice;

gData.Panel.Slider.Comp.hText.String = [num2str(iSlice), '/', num2str(nSlice)];

gData.Panel.Slider.hPanel.Visible = 'on';

% contour O
cont = gData.cont.O;
T = cont.ROIs;
nR = size(T, 1);
SN = T.Name;
SL = cell(nR, 1);
for n=1:nR
    SL{n} = false;
end

OT = gData.Panel.STSelection.hTable.O;
OT.Data = [SN, SL];

gData.OT = OT;

guidata(gFig, gData);


% % Body Boundary
%     gData.Panel.View.hBB(iA) = line(hA(iA), 'XData', [], 'YData', [], 'Color', 'b');
%     gData.Panel.View.hBB(iA).Visible = 'off';
