function updateContour(gData, idx)

% O
hasST = gData.cont.O.hasST;
dataST = gData.cont.O.dataST;
tableST = gData.Panel.STTable.hTable.Data;
cont = gData.cont.O.cont;

iSlice = round(gData.Panel.Slider.hSlider.Value);

set(gData.View.hC.O, 'XData', [], 'YData', []);    
set(gData.View.hC.O1, 'XData', [], 'YData', []);    
set(gData.View.hC.O2, 'XData', [], 'YData', []);    
if hasST(idx, iSlice)
    C = dataST{idx, iSlice};
    set(gData.View.hC.O, 'XData', C(:, 1), 'YData', C(:, 2), 'Color', cont.ROIs.Color{idx}/255);    
    set(gData.View.hC.O1, 'XData', C(1, 1), 'YData', C(1, 2));    
    set(gData.View.hC.O2, 'XData', C(end, 1), 'YData', C(end, 2));    
end

% SM
hasST_SM = gData.cont.SM.hasST_SM;
dataST_SM = gData.cont.SM.dataST_SM;
set(gData.View.hC.SM, 'XData', [], 'YData', []);    
set(gData.View.hC.SM1, 'XData', [], 'YData', []);    
set(gData.View.hC.SM2, 'XData', [], 'YData', []);    
if hasST_SM(idx, iSlice)
    C = dataST_SM{idx, iSlice};
    set(gData.View.hC.SM, 'XData', C(:, 1), 'YData', C(:, 2));    
    set(gData.View.hC.SM1, 'XData', C(1, 1), 'YData', C(1, 2));    
    set(gData.View.hC.SM2, 'XData', C(end, 1), 'YData', C(end, 2));    
end

% RS
hasST_RS = gData.cont.RS.hasST_RS;
dataST_RS = gData.cont.RS.dataST_RS;
set(gData.View.hC.RS, 'XData', [], 'YData', []);    
set(gData.View.hC.RS1, 'XData', [], 'YData', []);    
set(gData.View.hC.RS2, 'XData', [], 'YData', []);    
if hasST_RS(idx, iSlice)
    C = dataST_RS{idx, iSlice};
    set(gData.View.hC.RS, 'XData', C(:, 1), 'YData', C(:, 2));    
    set(gData.View.hC.RS1, 'XData', C(1, 1), 'YData', C(1, 2));    
    set(gData.View.hC.RS2, 'XData', C(end, 1), 'YData', C(end, 2));    
end

% OS mask
ffd = gData.cont.OS.ffd;
OST = gData.cont.OS.OST;
T = gData.Panel.STTable.hTable.Data;

junk = OST.Plan;
junk2 = OST.Oncosoft;
for n = 1:length(junk)
    bb{n} = junk{n}(2:end-1);
    bb2{n} = junk2{n}(2:end-1);
end
a = T.Structure{idx};
idx_ = find(strcmp(bb, a));

FL = dir(fullfile(ffd, ['*', bb2{idx_}, '*']));
ffn = fullfile(ffd, FL(1).name);
mv = niftiread(ffn);
msk = mv(:,:,iSlice);

if any(msk(:))
    set(gData.View.hC.OS.mask, 'AlphaData', single(msk')/10); 
    
    % OS contour
    B = bwboundaries(msk');
    [xx, yy] = intrinsicToWorld(gData.Panel.View.RA, B{1}(:, 2), B{1}(:, 1));
    set(gData.View.hC.OS.Line, 'XData', xx, 'YData', yy);    
    set(gData.View.hC.OS.Line1, 'XData', xx(1), 'YData', yy(1));    
    set(gData.View.hC.OS.Line2, 'XData', xx(end), 'YData', yy(end));    
end




% data_main = guidata(hFig_main);
% CT = data_main.CT;
% hPlotObj = data_main.hPlotObj;
% selected = data_main.selected;
% SS = data_main.SS;
% 
% SS_SagCor = [];
% if data_main.flag.SS_SagCorLoaded
%     SS_SagCor = data_main.SS_SagCor;
% end
% 
% switch panelTag
%     case '1'
%         [cont] = fun_getContour(selected.idxSS, SS.structures, SS.sNames, CT.zz);
%         contData = cont.data;
% 
%         if iSlice <= cont.ind(1) && iSlice >= cont.ind(end)
%             xx = [];
%             yy = [];
%             for iS = 1:length(contData{iSlice})
%                 points = contData{iSlice}(iS).points;
%                 x = points(:,1);
%                 y = points(:,2);
% 
%                 xx = [xx;x]; 
%                 yy = [yy;y];
%             end
%             set(hPlotObj.SS.z, 'xdata', xx, 'ydata', yy, 'color', SS.contourColor{selected.idxSS}/255);    
% %             set(hText.Struct, 'String', SS.sNames{selected.idxSS}, 'ForegroundColor', SS.contourColor{selected.idxSS}/255,  'visible', 'on')
%         else
%             set(hPlotObj.SS.z, 'xdata', (nan), 'ydata', (nan));    
% %             set(hText.Struct, 'visible', 'off')
%         end
% 
%     case '2'  % x cut
%         if ~isempty(SS_SagCor)
%             if isempty(SS_SagCor(selected.idxSS).sag(iSlice).pt)
%                 set(hPlotObj.SS.x, 'xdata', [], 'ydata', []);    
%             else
%                 ptmm = [];
%                 for iB = 1:length(SS_SagCor(selected.idxSS).sag(iSlice).pt)
%                     pt = SS_SagCor(selected.idxSS).sag(iSlice).pt{iB};
%                     ptmm = [ptmm;pt];
%                 end
%                 set(hPlotObj.SS.x, 'xdata', ptmm(:,2), 'ydata', ptmm(:,1), 'color', SS.contourColor{selected.idxSS}/255);
%             end
%         end
% 
%     case '3' % y cut
%         if ~isempty(SS_SagCor)
%             if isempty(SS_SagCor(selected.idxSS).cor(iSlice).pt)
%                 set(hPlotObj.SS.y, 'xdata', [], 'ydata', []);    
%             else
%                 ptmm = [];
%                 for iB = 1:length(SS_SagCor(selected.idxSS).cor(iSlice).pt)
%                     pt = SS_SagCor(selected.idxSS).cor(iSlice).pt{iB};
%                     ptmm = [ptmm;pt];
%                 end
%                 set(hPlotObj.SS.y, 'xdata', ptmm(:,2), 'ydata', ptmm(:,1), 'color', SS.contourColor{selected.idxSS}/255);
%             end
%         end
% end