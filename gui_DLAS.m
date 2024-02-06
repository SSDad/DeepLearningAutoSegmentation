%%%%%%%%%%%%%%%%%%%%%%%%%
% Auto contour comparison
% Zhen Ji
% Janurary 2024 
%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = gui_DLAS(varargin)

gFig = uifigure('Name',                'DLAS', ...
                    'Units',                 'normalized',...
                    'Position',             [0.1 0.1 0.8 0.8]);

junk = get(0, 'ScreenSize');
ScreenW = junk(3);
ScreenH = junk(4);
nR = 4; nC = 3;
RowHightRatio = zeros(nR, 1);
ColumnWidthRatio = zeros(1, nC);

RowHightRatio(1) = 1/8;
RowHightRatio(2) = 1/8;
RowHightRatio(3) = 1/2 - RowHightRatio(1) - RowHightRatio(2);
RowHightRatio(4) = 1-sum(RowHightRatio(1:nR-1));
RowHight = ScreenH*RowHightRatio;

ColumnWidthRatio(1) = 1/8;
ColumnWidthRatio(3) = 1/32;
ColumnWidthRatio(2) = 1-ColumnWidthRatio(1)-ColumnWidthRatio(3);
ColumnWidth = ScreenW*ColumnWidthRatio;

g = uigridlayout(gFig);
g.RowHeight = {RowHight(1), RowHight(2), RowHight(3), '1x'};
g.ColumnWidth = {ColumnWidth(1), '1x', ColumnWidth(3)};

Panel.CTDataSet.hPanel = uipanel(g);
Panel.CTDataSet.hPanel.Layout.Row = 1;
Panel.CTDataSet.hPanel.Layout.Column = 1;
Panel.CTDataSet.hPanel.BackgroundColor = 'k';

Panel.STDataSet.hPanel = uipanel(g);
Panel.STDataSet.hPanel.Layout.Row = 2;
Panel.STDataSet.hPanel.Layout.Column = 1;
Panel.STDataSet.hPanel.BackgroundColor = 'k';

Panel.STTable.hPanel = uipanel(g);
Panel.STTable.hPanel.Layout.Row = [3 4];
Panel.STTable.hPanel.Layout.Column = 1;
Panel.STTable.hPanel.BackgroundColor = 'k';

Panel.View.hPanel = uipanel(g);
Panel.View.hPanel.Layout.Row = [1 4];
Panel.View.hPanel.Layout.Column = 2;
Panel.View.hPanel.BackgroundColor = 'k';

% Contrast
Panel.Contrast.hPanel = uipanel(g);
Panel.Contrast.hPanel.Layout.Row = [1 2];
Panel.Contrast.hPanel.Layout.Column = 3;
Panel.Contrast.hPanel.BackgroundColor = 'k';

% Slider
Panel.Slider.hPanel = uipanel(g);
Panel.Slider.hPanel.Layout.Row = [3 4];
Panel.Slider.hPanel.Layout.Column = 3;
% Panel.Slider.hPanel.BackgroundColor = 'k';

[gData.Panel] = addComp2Panel(Panel);

[gData.Toolbar] = addToolbar(gFig);

gData.cont.SM.CC = 'cyan';
gData.cont.RS.CC = 'm';
gData.cont.OS.CC = 'y';

% [hMenu, hMenuItem] = addManu(hFig_main);
% data_main.hMenu = hMenu;
% data_main.hMenuItem = hMenuItem;
% gData.Panel = addPanel(gFig);

% guiData.hPanel = hPanel;
% guiData.hTable = hTable;
% guiData.hPushbutton = hPushbutton;
% guiData.hAxis = hAxis;
% guiData.hPlotObj = hPlotObj;
% guiData.hText = hText;
% guiData.Param = Param;
% guiData.hStatTab_zTime = hStatTab_zTime;
% guiData.hFig_main = guiFig;
% guiData.editBoxText_pt = [];
% 
% guiData.nib_jh = 50;
% 

guidata(gFig, gData);