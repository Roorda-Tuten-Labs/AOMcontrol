function [varargout] = netcomm(actionStr,varargin)
%
% netcomm.m--Uses Matlab's Java interface to handle Transmission Control
% Protocol (TCP) communications with another application, either on the
% same computer or a remote one. 
%
%Sends and receives messages of type 'int8' only.
%
% NETCOMMOBJ = NETCOMM('REQUEST',HOST,PORT) range- 1025->65535
%
% NETCOMM('WRITE',NETCOMMOBJ,MSSG) 
%
% NETCOMMOBJ = NETCOMM('CLOSE',NETCOMMOBJ) closes the TCP/IP connection. This should
% be done on both client and server.
%
% netcomm.m's normal algorithm is highly inefficient for transferring large
% amounts of data because it uses a separate function call for each byte it
% reads. Efficiency can be improved greatly by downloading and compiling
% Rodney Thomson's DataReader java class and setting netcomm.m's
% doUseHelperClass variable to "true" (see code, below). 
%
% Inspired by (and heavily uses concepts from) Rodney Thomson's example code on
% the MathWorks' File Exchange.
%
% e.g., Send/receive characters:
%    server: netCommObj = netcomm('accept',21566,'timeout',2000);
%    client: netCommObj = netcomm('request','192.0.34.166',21566,'timeout',10000);
%    client: netcomm('write',netCommObj,int8('Hello server'));
%    server: mssg = netcomm('read',netCommObj); char(mssg)
%    server: netcomm('write',netCommObj,int8('Hello client'));
%    client: mssg = netcomm('read',netCommObj); char(mssg)
%    server: netcomm('close',netCommObj);
%    client: netcomm('close',netCommObj);
%
% e.g., Send/receive numerical values:
%    client: netcomm('write',netCommObj,typecast([1 2 333],'int8'));
%    server: mssg = netcomm('read',netCommObj); typecast(mssg,'double')
%
% e.g., Send/receive matrix: must convert to vector before sending.
%    client: Z=get(0,'DefaultFigureColormap'); [numRows,numCols]=size(Z); 
%            Z=reshape(Z,1,numRows*numCols);
%            netcomm('write',netCommObj,typecast(Z,'int8'));
%    server: mssg = netcomm('read',netCommObj); 
%            reshape(typecast(mssg,'double'),64,3)
%-------------------------------------------------------------------------

% Improve reading efficiency by downloading and compiling Rodney Thomson's
% DataReader java class. Instruct netcomm.m to use DataReader by changing the
% doUseHelperClass variable (below) to "true" and editing the
% HELPER_CLASS_PATH to point the location of the compiled class.
%
% DataReader class available at:
% http://www.mathworks.com/matlabcentral/fileexchange/25249-tcpip-socket-communications-in-matlab-using-java-classes
% use this only if you have the above class and change the path below accrodingly
doUseHelperClass = false; %do not use helper class if you are using only as a client to send data
 HELPER_CLASS_PATH = 'C:\Program Files\MATLAB\R2007b\toolbox';

% Handle input arguments.
REQUEST = 1;
ACCEPT = 2;
WRITE = 3;
READ = 4;
CLOSE = 5;

remainingArgs = {};

if strcmpi(actionStr,'request')
    % NETCOMMOBJ = NETCOMM('REQUEST',HOST,PORT)
    action = REQUEST;
    
    if nargin < 3
        error([mfilename '.m--REQUEST mode requires at least 3 input arguments.']);
    end % if
    
    host = varargin{1};
    port = varargin{2};
    argNames = {'host' 'port'};
    
    if nargin > 3
        remainingArgs = varargin(3:end);
    end % if
    
elseif strcmpi(actionStr,'accept')
    % NETCOMMOBJ = NETCOMM('ACCEPT',PORT)
    action = ACCEPT;
    
    if nargin < 2
        error([mfilename '.m--ACCEPT mode requires at least 2 input arguments.']);
    end % if
    
    port = varargin{1};
    argNames = {'port'};
    
    if nargin > 2
        remainingArgs = varargin(2:end);
    end % if
    
elseif strcmpi(actionStr,'write')
    % NUMBYTES = NETCOMM('WRITE',NETCOMMOBJ,MSSG)
    action = WRITE;
    
    if nargin < 3
        error([mfilename '.m--WRITE mode requires at least 3 input arguments.']);
    end % if
    
    netCommObj = varargin{1};
    mssg = varargin{2};
    argNames = {'netCommObj' 'mssg'};
    
    if nargin > 3
        remainingArgs = varargin(3:end);
    end % if
    
elseif strcmpi(actionStr,'read')
    % MSSG = NETCOMM('READ',NETCOMMOBJ)
    % MSSG = NETCOMM('READ',NETCOMMOBJ,'MAXNUMBYTES',MAXNUMBYTES)
    % MSSG = NETCOMM('READ',NETCOMMOBJ,'NUMBYTES',NUMBYTES)
    action = READ;
    
    if nargin < 2
        error([mfilename '.m--READ mode requires at least 2 input arguments.']);
    end % if
    
    netCommObj = varargin{1};
    argNames = {'netCommObj'};
    
    if nargin > 2
        remainingArgs = varargin(2:end);
    end % if
    
elseif strcmpi(actionStr,'close')
    % NETCOMM('CLOSE',NETCOMMOBJ)
    action = CLOSE;
    
    if nargin < 2
        error([mfilename '.m--CLOSE mode requires at least 2 input arguments.']);
    end % if
    
    netCommObj = varargin{1};
    argNames = {'netCommObj'};
    
    if nargin > 1
        remainingArgs = varargin(2:end);
    end % if
    
else
    error([mfilename '.m--Unrecognised actionStr ''' actionStr ''.']);
end % if

% Parse remaining arguments.
if isempty(remainingArgs)
    maxNumBytes = +Inf;
    numBytes = NaN;
    timeout = 1000;
else
    defaultStruct.maxNumBytes = +Inf;
    defaultStruct.numBytes = NaN;
    defaultStruct.timeout = 1000;
    
    allowNewFields = 0;
    isCaseSensitive = 0;
    [argStruct,overRidden] = parse_args(defaultStruct,remainingArgs{:},allowNewFields,isCaseSensitive);
    maxNumBytes = argStruct.maxNumBytes;
    numBytes = argStruct.numBytes;
    timeout = argStruct.timeout;
end % if

% ...Check for validity of input arguments.
if maxNumBytes < 1
    error([mfilename '.m--Input argument ''maxNumBytes'' must be positive.']);
elseif isfinite(maxNumBytes)
    if rem(maxNumBytes,1)~=0
        error([mfilename '.m--Input argument ''maxNumBytes'' must be an integer.']);
    end % if
end % if

if numBytes < 1
    error([mfilename '.m--Input argument ''numBytes'' must be positive.']);
elseif ~isnan(numBytes)
    if rem(numBytes,1)~=0
        error([mfilename '.m--Input argument ''numBytes'' must be an integer.']);
    end % if
end % if

if timeout < 0
    error([mfilename '.m--Input argument ''timeout'' must be greater than zero.']);
end % if

if ismember('host',argNames)
    if ~ischar(host)
        error([mfilename '.m--Host name/IP must be a string (e.g., ''www.examplecom'' or ''208.77.188.166''.).']);
    end % if
end % if

if ismember('port',argNames)
    if ~isnumeric(port) | rem(port,1)~=0 | port < 1025 | port > 65535
       error([mfilename '.m--Port number must be an integer between 1025 and 65535.']);
    end % if
end % if

if ismember('netCommObj',argNames)
    
    if ~isstruct(netCommObj)
        error([mfilename '.m--Input argument ''netCommObj'' must be a structure.']);
    end % if
    
    if ~isfield(netCommObj,'socket')
        error([mfilename '.m--Input argument ''netCommObj'' not of recognised format.']);        
    end % if
end % if

if ismember('mssg',argNames)
    if ~isa(mssg,'int8')
        error([mfilename '.m--Input argument ''mssg'' must be of type ''int8''.']);
    end % if
end % if

% Perform specified action.
if action == REQUEST
    netCommObj = netcomm_request_connection(host,port,timeout);        
elseif action == ACCEPT
    netCommObj = netcomm_accept_connection(port,timeout);
elseif action == WRITE
    netcomm_write(netCommObj,mssg);
elseif action == READ
    mssg = netcomm_read(netCommObj,maxNumBytes,numBytes,doUseHelperClass,HELPER_CLASS_PATH); 
elseif action == CLOSE
    netCommObj = netcomm_close(netCommObj);
end % if

if nargout > 0
    
    if ismember(action,[REQUEST ACCEPT CLOSE])
        varargout{1} = netCommObj;
    elseif action == WRITE
        varargout{1} = [];
    elseif action == READ
        varargout{1} = mssg;
    elseif action == CLOSE
        varargout{1} = [];
    end % if
    
end % if

%-------------------------------------------------------------------------
function netCommObj = netcomm_request_connection(host,port,timeout)
%
% netcomm_request_connection.m--Request a TCP connection from server.
%
% Syntax: netCommObj = netcomm_request_connection(host,port,timeout)
%
% e.g., netCommObj = netcomm_request_connection('208.77.188.166',21566,1000)

%-------------------------------------------------------------------------

import java.net.Socket
import java.io.*
import java.net.InetSocketAddress 
             
% Assemble socket address.
socketAddress = InetSocketAddress(host,port); 

% 2009-10-05--Suggestion from Derek Eggiman to clean up code. Instead of a
% while loop for the timeout, create an unconnected socket, then connect it
% to the host/port address while specifying a timeout.

% Establish unconnected socket. 
socket = Socket();

% Connect socket to address.
try 
    socket.connect(socketAddress,timeout); 
catch
    errorStr = sprintf('%s.m--Failed to make TCP connection.\nJava error message follows:\n%s',mfilename,lasterr);
    error(errorStr);
end % try

inputStream  = socket.getInputStream;
dataInputStream = DataInputStream(inputStream);
outputStream   = socket.getOutputStream;
dataOutputStream = DataOutputStream(outputStream);

netCommObj.socket = socket;
netCommObj.remoteHost = host;
netCommObj.port = port;
netCommObj.inputStream = inputStream;
netCommObj.dataInputStream = dataInputStream;
netCommObj.outputStream = outputStream;
netCommObj.dataOutputStream = dataOutputStream;

%-------------------------------------------------------------------------
function netCommObj = netcomm_accept_connection(port,timeout)
%
% netcomm_accept_connection.m--Accept a TCP connection from client.
%
% Syntax: netCommObj = netcomm_accept_connection(port,timeout)
%
% e.g., netCommObj = netcomm_accept_connection(21566,1000)

%-------------------------------------------------------------------------

import java.net.Socket
import java.io.*
import java.net.ServerSocket

serverSocket = ServerSocket(port);
serverSocket.setSoTimeout(timeout);

try
    socket = serverSocket.accept;
    outputStream   = socket.getOutputStream;
    dataOutputStream = DataOutputStream(outputStream);
    inputStream  = socket.getInputStream;
    dataInputStream = DataInputStream(inputStream);
    netCommObj.socket = socket;
    inetAddress = socket.getInetAddress;
    host = char(inetAddress.getHostAddress);
    netCommObj.remoteHost = host;
    netCommObj.port = port;
    netCommObj.outputStream = outputStream;
    netCommObj.dataOutputStream = dataOutputStream;
    netCommObj.inputStream = inputStream;
    netCommObj.dataInputStream = dataInputStream;
catch ME
    serverSocket.close;
    rethrow(ME);
end % try

serverSocket.close;

%-------------------------------------------------------------------------
function [] = netcomm_write(netCommObj,mssg)
%
% netcomm_write.m--Writes the specified message to the TCP/IP connection.
%
% Syntax: netcomm_write(netCommObj,mssg)
%
% e.g.,   netcomm_write(netCommObj,'howdy')

%-------------------------------------------------------------------------

netCommObj.dataOutputStream.write(mssg,0,length(mssg));
netCommObj.dataOutputStream.flush;

%-------------------------------------------------------------------------
function [mssg] = netcomm_read(netCommObj,maxNumBytes,numBytes,doUseHelperClass,HELPER_CLASS_PATH)
%
% netcomm_read.m--Reads the specified message from the TCP/IP connection.
%
% maxNumBytes and numBytes are ignored if specified as NaNs.
%
% Syntax: mssg = netcomm_read(netCommObj,maxNumBytes,numBytes,doUseHelperClass,HELPER_CLASS_PATH);
%
% e.g.,   mssg = netcomm_read(netCommObj,NaN,NaN,true,'/home/bartlett/javaclasses');

%-------------------------------------------------------------------------

numBytesAvailable = netCommObj.inputStream.available;

% Default behaviour is to read in all available bytes.
numBytesToRead = numBytesAvailable;

% If a maximum number of bytes to read has been specified, and if that
% maximum number is less than the number of available bytes, then
% limit the number of bytes read in.
if maxNumBytes <= numBytesAvailable
    numBytesToRead = maxNumBytes;
end % if

% If an exact number of bytes to read in has been specified, then it
% trumps any value of maxNumBytes. 
if ~isnan(numBytes)
    numBytesToRead = numBytes;
end % if

% If the number of bytes to read exceeds the number available, then do
% not attempt to read; return an empty string.
if numBytesToRead > numBytesAvailable
    mssg = '';
else
           
    if doUseHelperClass == true
        % Use of the helper class has been specified, but the class has to
        % be on the java class path to be useable.
        dynamicJavaClassPath = javaclasspath('-dynamic');
        
        % Add the helper class path if it isn't already there.
        if ~ismember(HELPER_CLASS_PATH,dynamicJavaClassPath)
            javaaddpath(HELPER_CLASS_PATH);
            
            % javaaddpath issues a warning rather than an error if it fails, so
            % can't use try/catch here. Test again to see if helper path added.
            dynamicJavaClassPath = javaclasspath('-dynamic');
            
            if ~ismember(HELPER_CLASS_PATH,dynamicJavaClassPath)
                warning([mfilename '.m--Unable to add Java helper class; reverting to byte-by-byte (slow) algorithm.']);
                doUseHelperClass = false;
            end % if
            
        end % if
        
    end % if    
    
    % Read the message.
    if doUseHelperClass
        % Read incoming message using efficient single function call.
        data_reader = DataReader(netCommObj.dataInputStream);
        mssg = data_reader.readBuffer(numBytesToRead);
        mssg = mssg(:)';
    else
        % Read incoming message byte-by-byte with separate function call
        % for each byte.
        mssg = zeros(1, numBytesToRead, 'int8');
        
        for i = 1:numBytesToRead,
            mssg(i) = netCommObj.dataInputStream.readByte;
        end % for
        
    end % if
    
end % if

%-------------------------------------------------------------------------
function [netCommObj] = netcomm_close(netCommObj)
%
% netcomm_close.m--Closes the specified TCP/IP connection.
%
% Syntax: netCommObj = netcomm_close(netCommObj);
%
% e.g.,   netCommObj = netcomm_close(netCommObj);

%-------------------------------------------------------------------------

netCommObj.socket.close;

%-------------------------------------------------------------------------
function [argStruct,varargout] = parse_args(varargin)
%
% parse_args.m--Parses input arguments for a client function. Arguments are
% assumed to be in parameter/value pair form. 
%
% The following example shows the steps involved in using parse_args.m:
%
% (1) Create m-file "myfunc.m" with the following function declaration:
%        function [] = myfunc(varargin)
%
% (2) Inside myfunc.m, include the following lines:
%        defaultVals.figureWidth = 0.8; 
%        defaultVals.figureHeight = 0.5;
%        argStruct = parse_args(defaultVals,varargin{:});
%
% (3) Call your function with the following syntax:
%        myfunc('figureHeight',0.99)
%
% Inside myfunc.m, the structured variable argStruct will contain fields
% named 'figureWidth' and 'figureHeight'. The 'figureWidth' field will
% contain the default value of 0.8, since no non-default value was passed
% to myfunc.m, but the 'figureHeight' field will contain the value 0.99,
% over-riding the default value of 0.5.
%
% There are variations on this pattern:
%
% (a) Your "myfunc.m" program may take arguments in addition to varargin,
%     but they must precede varargin. For example, your function
%     declaration could look like this:
%         function [] = myfunc(numFiles,pathName,varargin)
%
% (b) It is not necessary to declare any default values. Your "myfunc.m"
%     program can call parse_args.m like this:
%         argStruct = parse_args(varargin{:});
%
% (c) You can call myfunc.m with all parameter/value pairs specified, none
%     of them specified, or anything in between. In the example above,
%     myfunc.m could be called like this:
%         myfunc('figureHeight',0.99,'figureWidth',0.2);
%     or like this:
%         myfunc;
%
% (d) Your "myfunc.m" program  can call parse_args.m with two additional
%     input arguments:
%         argStruct = parse_args(...,allowNewFields,isCaseSensitive);
%     where allowNewFields and isCaseSensitive are both Boolean values. By
%     default, isCaseSensitive is true, so parse_args.m will treat the
%     parameters 'lineColour' and 'linecolour' (for example) as different
%     parameters. The allowNewFields parameter is also true by default,
%     meaning that parse_args.m will accept parameters whose names are NOT
%     included as fields in the default values structured variable. You can
%     over-ride the default behaviour by specifying a different value for
%     allowNewFields or isCaseSensitive, but in this case, BOTH of these
%     arguments must be specified in the call to parse_args.m as shown
%     above.
%
% (e) Your program may call parse_args.m with a second output argument:
%         [argStruct,overRidden] = parse_args(...
%     The "overRidden" output argument contains a list of those variables
%     (if any) whose default values were overridden by varargin elements.
%
% N.B., program originally named parvalpairs.m. Program is based on the
% (University of Hawaii) Firing Group's fillstruct.m.
%
% Syntax: [argStruct,<overRidden>] = parse_args(<defaultStruct>,...
%                                    par1,val1,par2,val2,...,
%                                    <allowNewFields,isCaseSensitive>)
%
% e.g.,   argStruct = parse_args('Position',[256 308 512 384],'Units','pixels','Color',[1 0 1])
%
% e.g.,   defaultStruct.a = pi; 
%         defaultStruct.b = 'hello'; 
%         defaultStruct.c = [1;2;3];
%         allowNewFields = 1; 
%         isCaseSensitive = 0; 
%         [argStruct,overRidden] = parse_args(defaultStruct,varargin{:},allowNewFields,isCaseSensitive);
%         % N.B., for demonstration on command line (where you won't have a
%         varargin variable), use this syntax: 
%         [argStruct,overRidden] = parse_args(defaultStruct,'A',pi/2,'b','bye','z','new field',allowNewFields,isCaseSensitive)

%--------------------------------------------------------------------------

% 2009-06-17--Mathworks now supplies the inputParser class to handle input
% arguments. Should probably migrate from parse_args to the "official"
% program.

% Handle input arguments.
args = varargin;

if nargin == 0
    argStruct = struct([]);
    overRidden = {};
    
    if nargout > 1
        varargout{1} = overRidden;
    end % if

    return;
end % if

% If a structured variable containing default field values has been
% supplied, separate it from the other input arguments.
defaultStruct = struct([]);

if isstruct(args{1})

    defaultStruct = args{1};

    if length(args) > 1
        args = args(2:end);
    else
        args = {};
    end % if

end % if

argStruct = defaultStruct;

% Determine if values of the variables "allowNewFields" and
% "isCaseSensitive" have been specified.

% ...Default values:
allowNewFields = 1;
isCaseSensitive = 1;

if length(args) > 1
    
    % If no values of allowNewFields and isCaseSensitive have been
    % specified, then all the remaining arguments will be parameter/value
    % pairs. The second-to-last argument should then be a string.
    if ~ischar(args{end-1})
    
        % The second-to-last argument is NOT a string, so it must be the
        % Boolean variable allowNewFields.
        allowNewFields = args{end-1};
        
        % ...and the last input argument is the Boolean variable
        % isCaseSensitive.
        isCaseSensitive = args{end};
        
        if length(args) > 1
           args = args(1:end-2);
        else
            args = {};
        end % if
        
    end % if
        
end % if

% If no arguments remain after extracting the default field values and the
% Boolean variables "allowNewFields" and "isCaseSensitive", then exit now.
% The value of argStruct returned will contain the same values as
% defaultStruct.
if isempty(args)
    overRidden = {};
    
    if nargout > 1
        varargout{1} = overRidden;
    end % if

    return;
end % if

if ~ismember(allowNewFields,[1 0])
    error([mfilename '.m--Value for "allowNewFields" must be 1 or 0.']);
end % if

if ~ismember(isCaseSensitive,[1 0])
    error([mfilename '.m--Value for "isCaseSensitive" must be 1 or 0.']);
end % if

% Remaining input arguments should be parameter/value pairs.
existingFieldNames = fieldnames(defaultStruct);
lowerExistingFieldNames = lower(existingFieldNames);
overRidden = cell(1,length(args)/2);

for iArg = 1:2:length(args)

    thisFieldName = args{iArg};
    overRidden{1+(iArg-1)/2} = thisFieldName;

    if ~ischar(thisFieldName)
        error([mfilename '.m--Parameter names must be strings.']);
    end % if

    thisField = args{iArg+1};

    % Find out if field already exists.
    if isCaseSensitive == 1

        if ismember(thisFieldName,existingFieldNames)
            fieldExists = 1;
            fieldNameToInsert = thisFieldName;
        else
            fieldExists = 0;
            fieldNameToInsert = thisFieldName;
        end % if

    else

        if ismember(lower(thisFieldName),lowerExistingFieldNames)
            fieldExists = 1;
            matchIndex = strmatch(lower(thisFieldName),lowerExistingFieldNames,'exact');
            fieldNameToInsert = existingFieldNames{matchIndex};
        else
            fieldExists = 0;
            fieldNameToInsert = thisFieldName;
        end % if

    end % if

    % If new fields are not permitted to be added, test that field already exists.
    if allowNewFields == 0 && fieldExists == 0
        
        % If the default structure is empty, and the user is not permitting
        % the addition of new fields, there is no point in running this
        % program; probably the user doesn't intend this.
        if isempty(defaultStruct)
            error([mfilename '.m--Need to permit the addition of new fields if no default structure specified.']);
        end % if

        if isCaseSensitive == 1
            error([mfilename '.m--Unrecognised input argument ''' thisFieldName '''. (arguments are case-sensitive).']);
        else
            error([mfilename '.m--Unrecognised input argument ''' thisFieldName '''.']);
        end % if

    end % if

    if isempty(argStruct)
        argStruct = struct(fieldNameToInsert,thisField);
    else
        argStruct.(fieldNameToInsert) = thisField;
    end % if
            
end % for

if nargout > 1
    varargout{1} = overRidden;
end % if
