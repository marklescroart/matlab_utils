function eyd = readasl(fname, ver)
%function eyd = readASL(fname, [ver])
% Read ASL EYD file, set ver to 5 for 5000, 6 for 6000 format
% eyd.data is a cell array of data.
% data is an nx10 array
% Fields:
%   1: Field No
%   2: Overtime (no real data during overtime frame)
%   3: Total secs
%   4: Scene
%   5: ES-Dist
%   6: H-pos
%   7: V-pos
%   8: Diam
%   9: XDAT
%   10:Mark

% History: 
%   7/05 Bosco Tjan adapted the code based on ILABCONVERTASL.m from ILAB by Darren Gitelman & Roger Ray
%


NL = 13;	% new line character ascii value

if ~exist('ver','var')
    ver = 6;
end

switch ver
    case 5
        % opening asl file as bigendian avoids any changes with platforms or dependency
        % on byte swapping.

        fid = fopen([fname],'r','b');
        if fid == -1
            msg = sprintf('Cannot open file: %s.',fname);
            error(msg);
            return
        end

        tmp          = check_line(fid);
        eyd.vers    = str2num(tmp(9:end));
        eyd.date    = removeblanks(check_line(fid));
        eyd.time    = removeblanks(check_line(fid));
        eyd.eyd_or_ehd = 'EYD'; % I don't know how to read ehd yet


        % some ASL defines
        ASL_SEGMENTNUM_BYTE     = 808;
        ASL_SEGMENTDESCRIP_BYTE = 874;
        ASL_DATA_START          = 3072;


        % dump next lines (time and system id)
        tmp = check_line(fid);

        tmp = check_line(fid);
        eyd.acqRate = tmp;
        eyd.acqRate = str2num(tmp(1:3));

        data_items = check_line(fid);
        data_items = str2num(data_items(1:2));

        % Get Data Item Names
        for i = 1:data_items
            tmp = fgetl(fid);
            % strip off data descriptor
            s = findstr(tmp,'WORD');
            items{i} = deblank(tmp(1:s-1));
        end

        % Check if we have external data and mark flags, Horizontal and Vertical
        % Eye Position and pupil diameter
        eyedatacheck = [0 0 0 0 0];
        if strmatch('EXTERNAL_DATA',items)
            eyedatacheck(1) = 1;
        end
        if strmatch('MARK_FLAGS',items)
            eyedatacheck(2) = 1;
        end
        if strmatch('HORZ_EYE_POS',items)
            eyedatacheck(3) = 1;
        end
        if strmatch('VERT_EYE_POS',items)
            eyedatacheck(4) = 1;
        end
        if strmatch('PUPIL_DIAMETER',items)
            eyedatacheck(5) = 1;
        end

        % abort if no eye data.
        if sum(eyedatacheck([1, 3:5])) < 4
            fclose(fid);
            msg = sprintf('No eye data in file: %s.',fname);
            error(msg);
            return
        end

        % data reading variables
        % discount external data and mark flags
        discflg = sum(eyedatacheck(1:2));
        dataflg = [6 7];
        if eyedatacheck(5) == 1
            dataflg = [dataflg, 8];
        end
        % setup where in the data stream the horz, vert, and pupil data are
        % located. If values for scene number and/or POG magnitude are present then
        % the data items are shifted. If not then they will be 1,2 and 3.
        readflg = [1 2 3];
        checkstart = 0;
        if strmatch('SCENE_NUMBER',items)
            checkstart = checkstart + 1;
            k = strmatch('SCENE_NUMBER',items)-strmatch('HORZ_EYE_POS',items); %find out the position
            readflg = [1+k, readflg];
            dataflg = [4, dataflg];
        end
        if strmatch('POG_MAGNITUDE',items)
            checkstart = checkstart + 1;
        end
        readflg = readflg + checkstart;


        %=========================================================
        % ASL SEGMENT INFORMATION
        % The Segment Information is a list of  zero or more of
        % the following segment descriptors:

        % User Segment Descriptor (bytes are 8 bits)
        %   0xFF    Byte to Start of Segment    Start Time    Stop Time of Segment
        % (1 byte)	       ( 4 bytes )         ( 4 bytes )       ( 4 bytes )

        % Pseudo Segment Descriptor
        %   0xFE     Byte to Start of Segment    Start Time
        % (1 byte)	        ( 4 bytes )          ( 4 bytes )

        % End of File Segment Descriptor
        %   0xFD    Byte Offset to Last Byte of  Data + 1 ( file size in bytes )
        % (1 byte)	                   ( 4 bytes )

        % Multi-byte values are stored in the file as LSB...MSB.
        % Each user segment descriptor is followed by zero or more
        % pseudo segment descriptors. The last  descriptor in the list
        % is the end of file segment descriptor. A maximum of 169 segment
        % descriptors are possible ( 168 user/pseudo + 1 end of file ).
        % Start and stop times represent the current video field count at
        % the time the segment was started or stopped. If no segment descriptors
        % are present, the file does not contain any eye position data.
        %===========================================================

        % go to the segment descriptors
        fseek(fid,ASL_SEGMENTDESCRIP_BYTE,-1);
        segflag   = 1;
        segnum    = 0;
        segbytes  = [];
        endbyte   = [];

        while segflag
            % check if this is a segment
            switch fread(fid,1,'uint8')
                case 255
                    % read start of segment in bytes
                    tmp = fread(fid,4,'uint8');
                    tmp = convert_segbyte(tmp);
                    segnum = segnum + 1;
                    segbytes(segnum,1) = tmp;
                    if segnum > 1
                        segbytes(segnum-1,2) = tmp - 1;
                    end
                    % skip ahead
                    fseek(fid,8,0);
                case 254
                    % ignore pseudosegments, move ahead 8 bytes;
                    fseek(fid,8,0);
                case 253
                    % get the end of file byte
                    tmp = fread(fid,4,'uint8');
                    segbytes(segnum,2) = convert_segbyte(tmp);
                case 0
                    segflag = 0;
                    if isempty(segbytes)
                        fclose(fid);
                        msg = sprintf('No data in file: %s.',fname);
                        error(msg);
                        return
                    end
            end
        end

        % get the total file size
        fseek(fid,0,1);
        eof = ftell(fid);

        % % move the file marker to the data area
        % % currently ASL always assumes this is at 3072.
        % fseek(fid,ASL_DATA_START,-1);

        % -----------------------------------------------------------------------------------
        % EYEDAT consist of variable length records. Although records always contain
        % eye movement variables, external data or mark flags might be missing.
        % Each record is preceeded by a status byte which indicates whether xdat or
        % mark values are in the record. If no xdat or mark flags are present then the record
        % size is (data_items - 2) int16. Thus each record must be parsed individually.
        % Note that the eye data is in big endian format, unlike the segment descriptions
        % which are little endian. The endian changes are historical and rooted
        % in hardware changes during the history of the software (confirmed by Josh
        % Borah at ASL).
        %
        % status byte table - each of the following represents a bit
        % -----------------------------------------------------------
        % 7 Current record is first record of a user segment
        % 6 Current record is first record of a pseudo segment
        % 5 Current record is last record of a user segment
        % 4 Current record contains an overtime adjustment value (8 bits)
        % 3 Current record contains an external data value (xdat)
        % 2 Current record contains a mark value
        % 1 Unused
        % 0 Unused

        % There can be at most 168 segments in an eyedat file.
        % To start we set up a large matrix as file parsing is then much faster.
        % At the end this will be truncated to where there is actual data.
        % -----------------------------------------------------------------------------------

        % Calculate the number of bytes per record assuming that none of the
        % records has xdat or mark flags, and ignore the status byte.
        % That way we are sure to overestimate the number of rows needed
        % in the data matrix.
        minbytesperrecord = ((data_items-2)*2);

        exitflg  = 0;
        for i = 1:segnum
            exitflg  = 0;
            numrecords = ceil((segbytes(i,2)-segbytes(i,1)+1)/minbytesperrecord);
            datamat  = zeros(numrecords,10);

            % move to the start of each user segment
            fseek(fid,segbytes(i,1),-1);
            fprintf(1,'Segment: %d\n',i);
            j=0;

            while ftell(fid) < segbytes(i,2)
                j = j+1;
                % read and parse the status byte
                status = fread(fid,1,'uint8');
                if status ~= 0
                    flags = bitget(status,1:8);

                    % End of user segment.
                    if flags(6)
                        exitflg = 1;
                    end
                    if flags(5) %3 overtime adjust
                        otime = fread(fid,1,'uint8');
                        % j is the starting index of the overtime
                        % ASL assigns the overtime to the first
                        % data point after the overtime has ended.
                        % i is the current segment number and otime
                        % is the number of overtimes.

                        % during overtimes the data don't change. Get the
                        % data just before the start of the overtime and
                        % assign that to all the overtime points.
                        % Note: if j == 1 we are at the first point. There
                        % is nothing to change. However, ASL does skip
                        % those number of points.
                        % Note 2: The ASL field index for 5000 files is
                        % 0-based so the datapoint is +1 versus ASL.
                        if j > 1
                            tmp = datamat(j-1,:);
                        else
                            tmp = zeros(1,10);
                        end
                        datamat(j:j+otime-1,:) = tmp(ones(otime,1),:);
                        datamat(j:j+otime-1,2) = 1; % mark the overtime
                        % increment j by the length of the overtime.
                        j = j+otime;
                    end
                    if flags(4) %2 xdat_flag
                        datamat(j,9) = fread(fid,1,'uint16');
                    end
                    if flags(3) %1 mark_flag
                        datamat(j,10) = fread(fid,1,'uint16');
                    end
                end
                % read horiz and vert eye coordinates and pupil size
                a = fread(fid,data_items-discflg,'int16')';
                if length(a) >= (data_items - discflg)
                    datamat(j,dataflg) = a(readflg);
                else
                    msg = sprintf('Reached EOF early with file: %s',fname);
                    error(msg);
                end
                if exitflg % end of user segment
                    break
                end
            end
            % enter the segmenet data
            eyd.data{i} = datamat(1:j,:);
            eyd.data{i}(:,1) = (1:j)-1; % Field no.
            eyd.data{i}(:,3) = eyd.data{i}(:,1)/eyd.acqRate; % Total sec

            % in version 1.31 of the ASL data acquisition software the eye position
            % measurements are multiplied by 10 to increase resolution. We divide by 10
            % here.
            if eyd.vers >= 1.31
                eyd.data{i}(:,6:7) = datamat(:,6:7) / 10;
            end
        end

        fclose(fid);


    case 6

        % open the file and get the end of file byte
        fid = fopen([fname],'r','l');
        if fid == -1
            msg = sprintf('Cannot open file: %s.',fname);
            error(msg);
            return
        end

        fseek(fid,0,1);
        eof = ftell(fid);
        fseek(fid,0,-1);

        % data item structure.
        data_item = struct(...
            'start',  struct('pos',[],'siz',[],'typ',[]),...
            'status', struct('pos',[],'siz',[],'typ',[]),...
            'otime',  struct('pos',[],'siz',[],'typ',[]),...
            'mark',   struct('pos',[],'siz',[],'typ',[]),...
            'xdat',   struct('pos',0,'siz',0,'typ',0,'sca',0),...
            'pupil',  struct('pos',0,'siz',0,'typ',0,'sca',0),...
            'horz',   struct('pos',0,'siz',0,'typ',0,'sca',0),...
            'vert',   struct('pos',0,'siz',0,'typ',0,'sca',0),...
            'scene',  struct('pos',0,'siz',0,'typ',0,'sca',0),...
            'es_dist',struct('pos',0,'siz',0,'typ',0,'sca',0));

        % parse the header
        useEH = 0;
        inCalSession = 0;
        tmp = fgetl(fid);

        while ~strcmp(lower(tmp),'[segment_data]') & (ftell(fid) < eof)

            tmp = fgetl(fid);

            if ~isempty(tmp)
                if tmp(1) == '['
                    if strfind(tmp,'[Calibration Values]')
                        inCalSession = 1;
                    else
                        inCalSession = 0;
                    end
                else
                    if inCalSession
                        try
                        eval(lower([tmp, ';']));
                        catch
                            % ignore any error
                        end
                    else
                        % separate labels from info
                        [t, r] = strtok(tmp);
                        % the items
                        switch t
                            case 'File_Version:'
                                eyd.vers = strtok(r);

                            case 'Creation_Date&Time:'
                                % ASL appears to use a dd.mm.yy format. This is not
                                % understood by Matlab's date functions. So
                                % the raw date and time are stored.
                                [n1,n2] = strtok(r);
                                eyd.date = removeblanks(n1);
                                eyd.time = removeblanks(n2);

                            case 'Update_Rate(Hz):'
                                eyd.acqRate  = str2num(strtok(r));

                            case 'Eyd_or_Ehd:'
                                eyd.eyd_or_ehd = strtok(r);

                            case 'Distace_Units:'
                                eye.Distace_Units = strtok(r);

                            case '[User_Description]'
                                tmp = fgetl(fid);
                                eyd.comment = deblank(tmp);

                                % we ignore the number of user recorded segments since
                                % these are read one at a time anyway.
                            case 'Segment_Directory_Start_Address:'
                                ASL_SEGMENTDESCRIP_BYTE = str2num(strtok(r));

                            case 'start_of_record'
                                [pos, siz, typ] = parse_data_items(r);
                                data_item.start.pos = pos;
                                data_item.start.siz = siz;
                                data_item.start.typ = typ;

                            case 'status'
                                [pos, siz, typ] = parse_data_items(r);
                                data_item.status.pos = pos;
                                data_item.status.siz = siz;
                                data_item.status.typ = typ;

                            case 'overtime_count'
                                [pos, siz, typ] = parse_data_items(r);
                                data_item.otime.pos = pos;
                                data_item.otime.siz = siz;
                                data_item.otime.typ = typ;

                            case 'mark_value'
                                [pos, siz, typ] = parse_data_items(r);
                                data_item.mark.pos = pos;
                                data_item.mark.siz = siz;
                                data_item.mark.typ = typ;

                            case 'XDAT'
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.xdat.pos = pos;
                                data_item.xdat.siz = siz;
                                data_item.xdat.typ = typ;
                                data_item.xdat.sca = sca;

                            case 'pupil_diam'
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.pupil.pos = pos;
                                data_item.pupil.siz = siz;
                                data_item.pupil.typ = typ;
                                data_item.pupil.sca = sca;

                            case 'horz_gaze_coord'
                                if ~useEH
                                    [pos, siz, typ, sca] = parse_data_items(r);
                                    data_item.horz.pos = pos;
                                    data_item.horz.siz = siz;
                                    data_item.horz.typ = typ;
                                    data_item.horz.sca = sca;
                                end

                            case 'vert_gaze_coord'
                                if ~useEH
                                    [pos, siz, typ, sca] = parse_data_items(r);
                                    data_item.vert.pos = pos;
                                    data_item.vert.siz = siz;
                                    data_item.vert.typ = typ;
                                    data_item.vert.sca = sca;
                                end

                            case 'EH_horz_gaze_coord'
                                useEH = 1; % use scene coordinate instead if available
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.horz.pos = pos;
                                data_item.horz.siz = siz;
                                data_item.horz.typ = typ;
                                data_item.horz.sca = sca;

                            case 'EH_vert_gaze_coord'
                                useEH = 1; % use scene coordinate instead if available
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.vert.pos = pos;
                                data_item.vert.siz = siz;
                                data_item.vert.typ = typ;
                                data_item.vert.sca = sca;

                            case 'EH_scene_number'
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.scene.pos = pos;
                                data_item.scene.siz = siz;
                                data_item.scene.typ = typ;
                                data_item.scene.sca = sca;

                            case 'EH_gaze_length'
                                [pos, siz, typ, sca] = parse_data_items(r);
                                data_item.es_dist.pos = pos;
                                data_item.es_dist.siz = siz;
                                data_item.es_dist.typ = typ;
                                data_item.es_dist.sca = sca;

                            case 'Total_Bytes_Per_Record:'
                                tot_bytes = str2num(strtok(r));
                        end % switch
                    end
                end
            end % if
        end % while
        %         fclose(fid);

        % get the taget points
        for ti=1:17 % maximum 17-pt calibration
            cmd = sprintf('valid = horiz_ecal_pup_data_%d;',ti);
            eval(cmd);
            if ~valid
                break
            end
            cmd = sprintf('eyd.calpts(ti,:) =  [htgt_data_%d, vtgt_data_%d];',ti,ti);
            eval(cmd);
        end

        % figure out what we have
        allpos = [data_item.xdat.pos, data_item.pupil.pos, data_item.horz.pos,...
            data_item.vert.pos, data_item.scene.pos, data_item.es_dist.pos];
        allbytes = [data_item.xdat.siz, data_item.pupil.siz, data_item.horz.siz,...
            data_item.vert.siz, data_item.scene.siz, data_item.es_dist.siz];
        allitems = {'xdat'; 'pupil'; 'horz'; 'vert'; 'scene'; 'es_dist'};
        alltypes = {data_item.xdat.typ, data_item.pupil.typ, data_item.horz.typ,...
            data_item.vert.typ, data_item.scene.typ, data_item.es_dist.typ};
        % this code will work even if ASL happens to change the order of
        % the fields it exports, so keep it.
        [p q] = sort(allpos);
        idx = find(p);

        item_name = {allitems{q(idx)}};
        item_pos  = allpos(q(idx));
        item_siz  = allbytes(q(idx));
        item_siz  = sum(item_siz) + data_item.start.siz + data_item.status.siz +...
            data_item.otime.siz + data_item.mark.siz;
        item_typ  = {alltypes{q(idx)}};
        leftoverbytes = tot_bytes - item_siz;


        % We should be at the start of the data
        % The Start of each Video Field Byte should be 250. If not we're
        % lost.
        start_of_data = ftell(fid);

        % setup variable to hold the data
        datamat = zeros(round((ASL_SEGMENTDESCRIP_BYTE - start_of_data)/tot_bytes),10);
        j = 0;
        segnum = 1;
        fprintf(1,'Segment: %d\n',segnum);

        % This code reads regular video fields and end of segment markers.
        % We don't need to deal with the segment directory as it doesn't
        % contain anything that isn't in the rest of the file. We also
        % ignore the CU_video_field#. ASL uses it to synchronize with
        % captured eye videos, but ILAB doesn't use it.
        while ftell(fid) < ASL_SEGMENTDESCRIP_BYTE
            j = j + 1;
            start   = fread(fid,1,data_item.start.typ);
            switch start
                case 250 % regular video field
                    status  = fread(fid,1,data_item.status.typ);
                    otime   = fread(fid,1,data_item.otime.typ);
                    if otime ~= 0
                        % j is the starting index of the overtime
                        % ASL assigns the overtime to the first data point
                        % after the overtime has ended. Segnum is the
                        % current segment number and otime is the number of
                        % overtimes.
                        % Note 2: The ASL field index for 6000 files is
                        % one based so the datapoint in the ILAB converted
                        % file is == ASL. That's why we don't subtract 1
                        % versus what we did for the 500 files.
                        % Note 2: The ASL field index for 6000 files is
                        % 1-based so the datapoint in the ILAB converted
                        % file is == ASL. That's why we don't subtract 1
                        % versus what we did for the 5000 files.
                        %
                        % during overtimes the data don't change. Get the
                        % data just before the start of the overtime and
                        % assign that to all the overtime points.
                        if j > 1
                            tmp = datamat(j-1,:);
                        else
                            tmp = zeros(1,10);
                        end
                        datamat(j:j+otime-1,:) = tmp(ones(otime,1),:);
                        datamat(j:j+otime-1,2) = 1; % mark the overtime
                        % increment j by the length of the overtime.
                        j = j+otime;
                    end
                    datamat(j,10) = fread(fid,1,data_item.mark.typ);

                    tmp = [0 0 0 0 0 0];
                    for i = 1:length(item_pos);
                        tmpdata = fread(fid,1,data_item.(item_name{i}).typ);
                        switch item_name{i}
                            case 'scene'
                                tmp(1) = tmpdata*data_item.(item_name{i}).sca;
                            case 'es_dist'
                                tmp(2) = tmpdata*data_item.(item_name{i}).sca;
                            case 'horz'
                                tmp(3) = tmpdata*data_item.(item_name{i}).sca;
                            case 'vert'
                                tmp(4) = tmpdata*data_item.(item_name{i}).sca;
                            case 'pupil'
                                tmp(5) = tmpdata*data_item.(item_name{i}).sca;
                            case 'xdat'
                                tmp(6) = tmpdata*data_item.(item_name{i}).sca;
                        end % switch
                    end % for
                    datamat(j,4:9) = tmp;
                    % dump rest of bytes
                    fread(fid,leftoverbytes,'uint8');
                case 254 % end of segment
                    % end of segment
                    if j==1 % empty segment
                        eyd.data{segnum} = [];
                    else
                        eyd.data{segnum} = datamat(1:j-1,:);
                        eyd.data{segnum}(:,1) = (1:j-1); % Field no., 1-based for 6000
                        eyd.data{segnum}(:,3) = (eyd.data{segnum}(:,1)-1)/eyd.acqRate; % Total sec, count from 0.0
                    end
                    j = 0;
                    segnum = segnum + 1;
                    fprintf(1,'Segment: %d\n', segnum);
                    % ASL then writes a video field's worth of end of
                    % segment markers. So skip ahead
                    fread(fid,tot_bytes - 1,data_item.start.typ);
                    datamat = zeros(round((ASL_SEGMENTDESCRIP_BYTE - start_of_data)/tot_bytes),10);
            end % switch
        end % while
        fclose(fid);

end % case for 6000 files
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pts = getTargetPoints(fid)

tmp = fgetl(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tmp = check_line(fid)

% This function checks if tmp is empty and returns only non-empty strings
% This is necessary because the transfer of EYD 5000 files can result in variable
% formats depending on whether the transfer is direct pc-disk -> mac, or
% indirect via ftp. The former results in carriage return/new line while the
% latter results in carriage return/carriage return. This messes up fgetl.

i = 0;
while i == 0
    tmp = fgetl(fid);
    if tmp == -1
        error('Reached end-of-file in ASL conversion. This is a problem');
    elseif ~isempty(tmp)
        i = 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = removeblanks(in)

% remove leading and trailing blanks in a string
out = fliplr(deblank(fliplr(deblank(in))));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function segbyte = convert_segbyte(tmp)
% converts byte information to decimal format. See ASL segment description.

segbyte = hex2dec([dec2hex(tmp(4),2),dec2hex(tmp(3),2),...
    dec2hex(tmp(2),2),dec2hex(tmp(1),2)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pos, siz, typ, sca] = parse_data_items(r)
% returns the position_byte, byte_size and scale_factor for ASL data items
pos = [];
siz = [];
typ = [];
sca = [];

% nibble at the string
[t, r] = strtok(r);
pos    = str2num(t);

[t, r] = strtok(r);
[t, r] = strtok(r);
siz    = str2num(t);
if siz == 1
    typ = 'uint8';
elseif siz == 2
    typ = 'int16';
end

[t, r] = strtok(r);
if ~isempty(t)
    sca = str2num(t);
    if sca == 0
        sca = 1;
    end
end