function time = pupilGetCurrentTime(hUDP, eyeProperties)

time = -1
pupil_vals.gazeTime = NaN(1,'single');

% return early if not connected
if ~eyeProperties.isConnected,return;end

% get data
pkt = nan;
num_iter = 0;
max_iter = 20;
fclose(hUDP);
fopen(hUDP);
while all(isnan(pkt)) && num_iter<max_iter
    tic;
    data = cast(fread(hUDP), 'uint8');
    elapsed=toc;
    if ~isempty(data)
        %         keyboard
    end
    if elapsed>=eyeProperties.timerPeriod
        fprintf('Elapsed time was %.2f\n',elapsed);
        %         break;
    end
    num_iter = num_iter + 1;
    
    % split the data up into packets
    pktbyte = 0;
    while pktbyte < length(data)
        % read out the number of bytes in the packet:
        % 2 accounts for:
        % 1st byte payload length
        % and last byte checksum
        pktlen = cast(data(1),'single');
        
        % make sure we read sufficient data for the packet
        if pktbyte+pktlen > length(data)
            sprintf('Bad packet: expected %d bytes but found %d',pktlen,length(data));
            break;
        end
        
        % pull out bytes for this packet
        pkt = data(pktbyte+(1:pktlen));
        
        pktID = pkt(2);
        pkt(2) = [];
        % validate the checksum calculated just based off payload
        %         if pkt(end) ~= mod(sum(double(pkt(2:end-1))),256)
        %
        %             % invalid checksum, kill this packet
        %           warning('Invalid checksum!');
        %             pkt = nan;
        %         end
        
        % increment byte counter
        pktbyte = pktbyte + pktlen + 1;
    end
end

% remove unused pkt entries and check for remaining
if isnan(pkt)
    warning('No valid packets received');
    pktID = 3;
    % return;
end

switch pktID
    case {0, 1}
        time = typecast(pkt(14:17),'single');
    case 3
        % default value: all NaNs
    otherwise
        fprintf('ERROR NO PACKETID RECEIVED\n')
end % END of switch pktID
% fprintf('test.\n')
% if ~isnan(pupil_vals.gazeConfidence)
%     fprintf('NaNs found....\n');
% else
%    fprintf('Eye tracking data: [%.2f, %.2f], confidence: %.2f, time: %.2f\n',pupil_vals.gazePosition(1),...
%        pupil_vals.gazePosition(2),pupil_vals.gazeConfidence, pupil_vals.gazeTime)
% end
fclose(hUDP);
fopen(hUDP);
end % END function read