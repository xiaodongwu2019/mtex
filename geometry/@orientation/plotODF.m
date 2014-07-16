function plotODF(o,varargin)
% Plot EBSD data at ODF sections
%
% Input
%  ebsd - @EBSD
%
% Options
%  SECTIONS   - number of plots
%  points     - number of orientations to be plotted
%  all        - plot all orientations
%  phase      - phase to be plotted
%
% Flags
%  SIGMA (default) -
%  OMEGA - sections along crystal directions @Miller
%  ALPHA -
%  GAMMA -
%  PHI1 -
%  PHI2 -
%  AXISANGLE -
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo


mtexFig = mtexFigure('ensureTag','odf','ensureAppdata',...
  {{'sections',[]},{'CS',o.CS},{'SS',o.SS}});

% for a new plot 
if isempty(mtexFig.children)
  
  % determine section type
  sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','omega','axisangle'},'phi2');
  
  if any(strcmpi(sectype,{'sigma','omega','axisangle'}))
    varargin = [{'innerPlotSpacing',10},varargin];
  else
    varargin = [{'projection','plain',...
      'xAxisDirection','east','zAxisDirection','intoPlane',...
      'innerPlotSpacing',35,'outerPlotSpacing',35},varargin];
  end

  % get fundamental plotting region
  [max_rho,max_theta,max_sec] = getFundamentalRegion(o.CS,o.SS,varargin{:});

  if any(strcmp(sectype,{'alpha','phi1'}))
    dummy = max_sec; max_sec = max_rho; max_rho = dummy;
  elseif strcmpi(sectype,'omega')
    max_sec = 2*pi;
  end

  nsec = get_option(varargin,'SECTIONS',round(max_sec/degree/5));
  sec = linspace(0,max_sec,nsec+1); sec(end) = [];
  sec = get_option(varargin,sectype,sec,'double');
    
  varargin = [varargin,'maxrho',max_rho,'maxtheta',max_theta];  
  
else
  sectype = getappdata(gcf,'SectionType');
  sec = getappdata(gcf,'sections');
      
  if strcmpi(sectype,'omega')
    varargin = set_default_option(varargin,{getappdata(gcf,'h')});
  end
end
[symbol,labelx,labely] = sectionLabels(sectype);

% colorcoding
data = get_option(varargin,'property',[]);

% subsample to reduce size
if ~check_option(varargin,'all') && length(o) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', ...
    int2str(length(o)),' given orientations']);

  samples = discretesample(ones(1,length(o)),points);
  o= o.subSet(samples);
  if ~isempty(data)
    data = data(samples); end
end

% project orientations to ODF sections
[S2G, data]= project2ODFsection(o,sectype,sec,'data',data,varargin{:});

% predefines axes?
paxes = get_option(varargin,'parent',mtexFig.children);

% generate plots
for i = 1:length(sec)

  if isempty(paxes), ax = mtexFig.nextAxis; else ax = paxes(i); end
  S2G{i}.resolution = S2G{1}.resolution;

  % plot
  S2G{i}.plot(data{i},'parent',ax,'TR',[int2str(sec(i)*180/pi),'^\circ'],...
    'xlabel',labelx,'ylabel',labely,'dynamicMarkerSize',varargin{:});
    
end

if isempty(ax)
  setappdata(gcf,'sections',sec);
  setappdata(gcf,'SectionType',sectype);
  setappdata(gcf,'CS',o.CS);
  setappdata(gcf,'SS',o.SS);
  set(gcf,'Name',[sectype ' sections of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'tag','odf')

  if strcmpi(sectype,'omega') && ~isempty(find_type(varargin,'Miller'))
    h = varargin{find_type(varargin,'Miller')};
    setappdata(gcf,'h',h);
  end
end
