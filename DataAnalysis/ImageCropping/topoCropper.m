%% topoCropper crops images
% over an user-defined grid
% requires readPoints.m
clc, clear all
imtool close all
disp('Cleaning workspace \n')

%%%%%%%%%%%USER PARAMETERS%%%%%%%%%%%%%
%define screen name
screen_name = 'aSMA';

%define channel names
c0 = 'TRITC';
c1 = 'FITC';
c2 = 'DAPI';


disp(append('Performing screen: ', screen_name,'\n Channel 0: ', c0, '\n Channel 1: ', c1, '\n Channel 0: ', c2, ' \n'));
%%%%%%%%%%%USER PARAMETERS%%%%%%%%%%%%%

% maindir should be where the script is
maindir = pwd;
disp(append('Active in:', maindir));

%navigate to image location maps
imagemap = append(maindir, '\RawImages\'); %contains raw files
destmap = append(maindir, '\CroppedImages\'); %contains destination files

%get directories of Chip replicate folders in the Raw Image map
chipreps = dir(imagemap);
chips = {chipreps.name}.';

%initialize chipnumber counter


%Set topochip cell number on x
x_n = 66;
%Set topochip cell number on y
y_n = 66;

%% Loop through the chip replicate directories
for chip = 1:(size(chips))

    %Test if file in directory is actually a chip folder
    k = strfind(chips{chip,1}, 'Chip');
    test = isempty(k);
    
    %If file in directory is chip, proceed
    if test == 0
        chipno = input('Give the Chip number:');
        rotation_angle=input('Give the rotation angle')
        %Create path into directory
        disp(append('It is Chip ', chips{chip,1}, ' proceed.'));
        %iterate the chipnumber counter
        %chipno = chipno + 10;
        %create folder for that same chip in the destination directory
        %(where the crops go)
        mkdir(append(destmap,chips{chip,1}));

        %retrieve filenames in the chipfolder
        replicatemap = append(imagemap,chips{chip,1});
        imgfiles = dir(replicatemap);
        name = {imgfiles.name}.';

        %find the user-defined channel string in each of the filenames and
        %save these filenames to a variable if it exists
        for ind = 1:(size(name,1))
            k = strfind(name{ind,1}, c0);
            test = isempty(k);
            if test == 0
                TRITC = name{ind,1};
            end
            k = strfind(name{ind,1}, c2); 
            test = isempty(k);
            if test == 0
                DAPI = name{ind,1};
            end
            k = strfind(name{ind,1}, c1);
            test = isempty(k);
            if test == 0
                FITC = name{ind,1};
            end
        end


        %read the first image belonging to c2
        im_dest = imread(append(replicatemap,'\',DAPI));

        %return image has been succesfully loaded
        disp('Img loaded')
                
        im_dest=imrotate(im_dest,rotation_angle);
        disp('image is rotated')
        %% Perform image correction for easier visual check and set interrogation area parameters
        %store image dimensions
        [nrows, ncols, numberOfColorChannels] = size(im_dest);
        %dax is the interrogation area of each corner in pixels
        dax = 3000;

        %brightness increase
        im_desto = im_dest + 10000;
        %perform histogram stretch operation to increase visibility
        im_desto = imadjust(im_desto,stretchlim(im_desto),[0.1 0.9]);
        disp('Image correction performed.')

        %% Retrieve points from input image
        
        %take corner pieces
        disp('Point out the TOP-LEFT quadrant')
        q4 = readPoints(im_desto(1:dax+1,1:dax+1,:),1);    %X1 = 1; dax | Y1 = 1; Y2 = day
        disp('Point out the TOP-RIGHT quadrant')
        q1 = readPoints(im_desto(1:dax+1,ncols-dax:ncols,:),1);    %X1 = ncols - dax; X2 = ncols | Y1 = 1; Y2 = day
        disp('Point out the BOTTOM-RIGHT quadrant')
        q2 = readPoints(im_desto(nrows-dax:nrows,ncols-dax:ncols,:),1);    %X1 = ncols - dax; X2 = ncols | Y1 = nrows - day; Y2 = nrows
        disp('Point out the BOTTOM-LEFT quadrant')
        q3 = readPoints(im_desto(nrows-dax:nrows,1:dax+1,:),1);    %X1 = 1; dax | Y1 = nrows - day; Y2 = nrows
        
        
        %readjust adjust to full scale
        q4 = q4;
        q1(1,1) = q1(1,1) + ncols-dax;
        q2 = q2 + [ncols-dax; nrows-dax];
        q3(2,1) = q3(2,1) + nrows-dax;
        
        %prepare the corner coordinates in a list
        qs = [q4 q1 q2 q3];
        disp('Cornerpoints defined')
        
        
        
        %% Defining the gridspace and returning figure

        %initialize gridspace
        x_grid = zeros(y_n+1,x_n+1);
        y_grid = zeros(y_n+1,x_n+1);

        %assign and compute increments to gridspaces
        %top
        x_grid(1,:) = linspace(qs(1,1),qs(1,2),x_n+1); %xt
        y_grid(1,:) = linspace(qs(2,1),qs(2,2),x_n+1); %yt
        %right
        x_grid(:,x_n+1) = linspace(qs(1,2),qs(1,3),y_n+1)'; %xr
        y_grid(:,x_n+1) = linspace(qs(2,2),qs(2,3),y_n+1)'; %yr
        %bottom
        x_grid(y_n+1,:) = linspace(qs(1,4),qs(1,3),x_n+1); %xb
        y_grid(y_n+1,:) = linspace(qs(2,4),qs(2,3),x_n+1); %yb
        %left
        x_grid(:,1) = linspace(qs(1,1),qs(1,4),y_n+1)'; %xl
        y_grid(:,1) = linspace(qs(2,1),qs(2,4),y_n+1)'; %yl
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %intrapolation of gridpoints
        for yi = 2:y_n
            x_grid(yi,:) = linspace(x_grid(yi,1),x_grid(yi,x_n+1),x_n+1); %intrapolate xs
            y_grid(yi,:) = linspace(y_grid(yi,1),y_grid(yi,x_n+1),x_n+1); %intrapolate ys
        end
        y_grid_tmp=y_grid;
        x_grid_tmp=x_grid;
        %select 2 additional points between each edge, at pos 22 and 44
        % q122 is right side under
        %q122 = readPoints(im_desto(y_grid(44,67):y_grid(46,67),x_grid(23,64):x_grid(25,67)),1);
        %q122 = [x_grid(23,66)-520+q122(1);y_grid(44,67)+q122(2)];
        
                %select 2 additional points between each edge, at pos 22 and 44
        %select 2 additional points between each edge, at pos 22 and 44
        q411 = readPoints(im_desto(y_grid(1,23)-100:y_grid(2,23),x_grid(1,22):x_grid(1,24),1),1);
        q411 = [x_grid(1,22)+q411(1);y_grid(1,23)-100+q411(2)];
        q412 = readPoints(im_desto(y_grid(1,23)-100:y_grid(2,23),x_grid(1,44):x_grid(1,46),1),1);
        q412 = [x_grid(1,44)+q412(1);y_grid(1,23)-100+q412(2)];
        
        q121 = readPoints(im_desto(y_grid(22,67):y_grid(24,67),x_grid(23,66):x_grid(23,67)+100,1),1);
        q121 = [x_grid(23,66)+q121(1);y_grid(22,67)+q121(2)];
        q122 = readPoints(im_desto(y_grid(44,67):y_grid(46,67),x_grid(23,66):x_grid(23,67)+100,1),1);
        q122 = [x_grid(23,66)+q122(1);y_grid(44,67)+q122(2)];
        
        q231 = readPoints(im_desto(y_grid(66,23):y_grid(67,23)+100,x_grid(67,22):x_grid(67,24),1),1);
        q231 = [x_grid(67,22)+q231(1);y_grid(66,23)+q231(2)];
        q232 = readPoints(im_desto(y_grid(66,45):y_grid(67,45)+100,x_grid(67,44):x_grid(67,46),1),1);
        q232 = [x_grid(67,44)+q232(1);y_grid(66,45)+q232(2)];
        
        q341 = readPoints(im_desto(y_grid(22,1):y_grid(24,1),x_grid(23,1)-100:x_grid(23,2),1),1);
        q341 = [x_grid(23,1)-100+q341(1);y_grid(22,1)+q341(2)];
        q342 = readPoints(im_desto(y_grid(44,1):y_grid(46,1),x_grid(45,1)-100:x_grid(45,2),1),1);
        q342 = [x_grid(45,1)-100+q342(1);y_grid(44,1)+q342(2)];
        disp("Additional cornerpoints defined")
        
        %Determine points within array
        int1 = readPoints(im_desto(y_grid(23,23)-100:y_grid(23,23)+100,x_grid(23,23)-100:x_grid(23,23)+100,1),1);
        int1 = [x_grid(23,23)-100+int1(1);y_grid(23,23)-100+int1(2)];
        
        int2 = readPoints(im_desto(y_grid(23,45)-100:y_grid(23,45)+100,x_grid(23,45)-100:x_grid(23,45)+100,1),1);
        int2 = [x_grid(23,45)-100+int2(1);y_grid(23,45)-100+int2(2)];
        
        int3 = readPoints(im_desto(y_grid(45,23)-100:y_grid(45,23)+100,x_grid(45,23)-100:x_grid(45,23)+100,1),1);
        int3 = [x_grid(45,23)-100+int3(1);y_grid(45,23)-100+int3(2)];
        
        int4 = readPoints(im_desto(y_grid(45,45)-100:y_grid(45,45)+100,x_grid(45,45)-100:x_grid(45,45)+100,1),1);
        int4 = [x_grid(45,45)-100+int4(1);y_grid(45,45)-100+int4(2)];
        
        %Determine points within array
        int1 = readPoints(im_desto(y_grid(23,23)-100:y_grid(23,23)+100,x_grid(23,23)-100:x_grid(23,23)+100,1),1);
        int1 = [x_grid(23,23)-100+int1(1);y_grid(23,23)-100+int1(2)];
        
        int2 = readPoints(im_desto(y_grid(23,45)-100:y_grid(23,45)+100,x_grid(23,45)-100:x_grid(23,45)+100,1),1);
        int2 = [x_grid(23,45)-100+int2(1);y_grid(23,45)-100+int2(2)];
        
        int3 = readPoints(im_desto(y_grid(45,23)-100:y_grid(45,23)+100,x_grid(45,23)-100:x_grid(45,23)+100,1),1);
        int3 = [x_grid(45,23)-100+int3(1);y_grid(45,23)-100+int3(2)];
        
        int4 = readPoints(im_desto(y_grid(45,45)-100:y_grid(45,45)+100,x_grid(45,45)-100:x_grid(45,45)+100,1),1);
        int4 = [x_grid(45,45)-100+int4(1);y_grid(45,45)-100+int4(2)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %initialize gridspace
        gridList = [q4'; q411'; q412'; q1'; q341'; int1'; int2'; q121'; q342'; int3'; int4'; q122'; q3'; q231'; q232'; q2'];
        
        tempListx=[];
        tempListy=[];
        for y = 0:2
            for x = 1:3
                x_grid = zeros(23,23);
                y_grid = zeros(23,23);

                %assign and compute increments to gridspaces
                %top
                x_grid(1,:) = linspace(gridList(x+(y*4),1),gridList(x+1+(y*4),1),23); %xt
                y_grid(1,:) = linspace(gridList(x+(y*4),2),gridList(x+1+(y*4),2),23); %yt
                %right
                x_grid(:,23) = linspace(gridList(x+1+(y*4),1),gridList(x+5+(y*4),1),23)'; %xr
                y_grid(:,23) = linspace(gridList(x+1+(y*4),2),gridList(x+5+(y*4),2),23)'; %yr
                %bottom
                x_grid(23,:) = linspace(gridList(x+4+(y*4),1),gridList(x+5+(y*4),1),23); %xb
                y_grid(23,:) = linspace(gridList(x+4+(y*4),2),gridList(x+5+(y*4),2),23); %yb
                %left
                x_grid(:,1) = linspace(gridList(x+(y*4),1),gridList(x+4+(y*4),1),23)'; %xl
                y_grid(:,1) = linspace(gridList(x+(y*4),2),gridList(x+4+(y*4),2),23)'; %yl



                %intrapolation of gridpoints
                for yi = 2:22
                    x_grid(yi,:) = linspace(x_grid(yi,1),x_grid(yi,23),23); %intrapolate xs
                    y_grid(yi,:) = linspace(y_grid(yi,1),y_grid(yi,23),23); %intrapolate ys
                end
                tempListx=[tempListx,x_grid];
                tempListy=[tempListy,y_grid];
            end
        end
        
        %remove double columns
        tempListx(:,185)= [];
        tempListx(:,162)= [];
        tempListx(:,116)= [];
        tempListx(:,93)= [];
        tempListx(:,47)= [];
        tempListx(:,24)= [];
        tempListy(:,185)= [];
        tempListy(:,162)= [];
        tempListy(:,116)= [];
        tempListy(:,93)= [];
        tempListy(:,47)= [];
        tempListy(:,24)= [];
        
        x_grid = [tempListx(1:22,1:67);tempListx(1:22,68:134);tempListx(1:23,135:201)];
        y_grid = [tempListy(1:22,1:67);tempListy(1:22,68:134);tempListy(1:23,135:201)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Plot the image and the points of the grid
        figure()
        imshow(im_desto);
        hold on
        scatter(x_grid,y_grid);
         
        disp('Intrapolation made')

        %% Crop and save images 
        % loop through three chip channels
        for index = 1:3
            if index == 1
                channel = c2;
                disp(append('Processing ',channel,' now.'));
            end
            if index == 2
                channel = c1;
                disp(append('Processing ',channel,' now.'));
                im_dest = imread(append(replicatemap,'\',FITC));
                im_dest=imrotate(im_dest,rotation_angle);
            end
            if index == 3
                channel = c0;
                disp(append('Processing ',channel,' now.'));
                im_dest = imread(append(replicatemap,'\',TRITC));
                im_dest=imrotate(im_dest,rotation_angle);
            end

            count = 1;
            
            %move over topochip
            for o = 1:y_n
                for i = 1:x_n
                    
                    % top (y)
                    if  int64(y_grid(o,i)) > int64(y_grid(o,i+1)) % a > b
                        row_start = int64(y_grid(o,i+1)); % go with b
                    else
                        row_start = int64(y_grid(o,i)); % go with a
                    end
                    % bottom (y)
                    if int64(y_grid(o+1,i)) > int64(y_grid(o+1,i+1)) %c > d
                        row_end = int64(y_grid(o+1,i+1)); % go with d
                    else
                        row_end = int64(y_grid(o+1,i)); % go with c
                    end
                    % left (x)
                    if int64(x_grid(o,i)) > int64(x_grid(o+1,i))% a > c
                        col_start = int64(x_grid(o,i)); % go with a
                    else
                        col_start = int64(x_grid(o+1,i)); % go with c
                    end
                    % right (x)
                    if int64(x_grid(o,i+1)) > int64(x_grid(o+1,i+1)) %b > d
                        col_end = int64(x_grid(o,i+1)); % go with b
                    else
                        col_end = int64(x_grid(o+1,i+1)); % go with d
                    end
                    
                    %Saved cropped image to a cell 
                    topocrop{o,i}=im_dest(row_start-2:row_end+2,col_start-2:col_end+2,:);
                    
                    %define filename
                    file_name = append(destmap,chips{chip,1},'\',screen_name,'_Chip',num2str(chipno, '%02d'),'_Col',num2str(i, '%02d'),'_Row',num2str(o, '%02d'),'_Seq',num2str(count, '%04d'),'_',channel,'.tif'); % Create filename.
 
                    %savefile 
                    imwrite(topocrop{o,i}, file_name);
                    
                    %iterate sequence index
                    count = count + 1;
                end
            end
        end


    else
        disp('No chip found in folder. (Ignore if on first pass)')        
    end
    disp(['Cropped ',chips{chip,1}])

end
disp('Done.')
