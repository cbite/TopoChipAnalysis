%% topoCropper crops images
% over an user-defined grid
% requires readPoints.m
clc, clear all
imtool close all
disp('Cleaning workspace \n')

%%%%%%%%%%%USER PARAMETERS%%%%%%%%%%%%%
%define screen name
screen_name = 'SMA';

%define channel names
c0 = 'DAPI';
c1 = 'FITC';
c2 = 'TRITC';

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
chipno = 0;
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
        %Create path into directory
        disp(append('It is Chip ', chips{chip,1}, ' proceed.'));
        %iterate the chipnumber counter
        chipno = chipno + 1;
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
                DAPI = name{ind,1};
            end
            k = strfind(name{ind,1}, c2); 
            test = isempty(k);
            if test == 0
                TRITC = name{ind,1};
            end
            k = strfind(name{ind,1}, c1);
            test = isempty(k);
            if test == 0
                FITC = name{ind,1};
            end
        end

        %read the first image belonging to c2
        im_dest = imread(append(replicatemap,'\',TRITC));

        %return image has been succesfully loaded
        disp('Img loaded')


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

        %intrapolation of gridpoints
        for yi = 2:y_n
            x_grid(yi,:) = linspace(x_grid(yi,1),x_grid(yi,x_n+1),x_n+1); %intrapolate xs
            y_grid(yi,:) = linspace(y_grid(yi,1),y_grid(yi,x_n+1),x_n+1); %intrapolate ys
        end

        % Draw lines and points
        f = figure;
        imshow(im_dest); 

        %plot y lines 
        hold on;
        for yi = 1:(y_n+1)
            plot([x_grid(yi,1),x_grid(yi,x_n+1)],[y_grid(yi,1),y_grid(yi,x_n+1)], 'g-')
            hold on;
            %plot dots
            scatter(x_grid(yi,:), y_grid(yi,:),'go')
            hold on;
        end
        
        %plot x lines
         for xi = 1:(x_n+1)   
            plot([x_grid(1,xi),x_grid(y_n+1,xi)],[y_grid(1,xi),y_grid(y_n+1,xi)], 'g-')
            hold on;
         end
         
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
            end
            if index == 3
                channel = c0;
                disp(append('Processing ',channel,' now.'));
                im_dest = imread(append(replicatemap,'\',DAPI));
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
                    file_name = append(destmap,chips{chip,1},'\',screen_name,'_Chip',num2str(chipno, '%02d'),'_Col',num2str(o, '%02d'),'_Row',num2str(i, '%02d'),'_Seq',num2str(count, '%04d'),'_',channel,'.tif'); % Create filename.
 
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
