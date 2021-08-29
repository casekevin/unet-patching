%close all;
clear;
clc;
q = 0; % being cut
k = 0; % less than 256
j = 0; % recheck the actual img_list size
%Table with manually labeled images for analyzability
analyzable_data = readtable('');

%Folder Names (change these)
img_folder = '';
lbl_folder = '';
final_img_folder = '';
final_lbl_folder = '';

mkdir(final_img_folder); mkdir(final_lbl_folder);

direc = dir(img_folder);
img_list = extractfield(direc(3:end), 'name')';
Only preprocess the analyzable images
 temp = analyzable_data.Filename; %copy the original list
 C = strcmp('analyzable', analyzable_data.Analyzability);
 x = find(C == 0);
 temp(x) = [];
 
 for i= 1:length(img_list)
     if ismember(img_list(i),temp) == 1
         i = i + 1;
     else img_list(i) = [];
     end
 end        

for f = 1:length(img_list)
    
    %Load the image and corresponding label, conver the image from uint8 to
    %double type
    filename = img_list{f};
    disp(filename);
    filesplit = split(filename, '.');
    filetype = filesplit{2};
    disp(filename);
    img = imread([img_folder, filename]);
    
    img = img(:,:,1);
    img_double = im2double(img);% added,dont know the diff between img_double and new_img
    lbl = imread([lbl_folder, filename]);
    if strcmp(filetype, 'jpg')
        lbl(lbl < 100) = 0;
        lbl(lbl > 100) = 1;
    end
    
    new_img = double(img);
    
    
    
%   The following crops the dark and bright columns and rows
    %line 56 should be here
    [crop_img, crop_lbl, crop_array(f, 1:4)] = crop_march(new_img, lbl);%changed the sequence
    if isempty(crop_img)
        q = q+1;
        crop_array(f, 1:4) = [0, 0, 0, 0];
        continue
    end
  
    [m,n]=size(crop_img);
    if m < 256 || n <256
        k = k+1 ;
        disp(img_list{f});
        img_list{f} = '';
               
    else

     
     %The following is to remove the varying illumination from all images
    [adjust_img] = remove_gradient(crop_img);
    [adjust_img] = anyingmeihua(adjust_img);
    
    
    %Saving the Images and Labels
    imwrite(adjust_img, [final_img_folder, filename(1:end-4), '.bmp']);
    imwrite(255*crop_lbl, [final_lbl_folder, filename(1:end-4), '.bmp']);
    j = j + 1;
    end
end
    

disp('number of the image that is cropped of dark and bright columns : ')
disp(1029 - q);
disp('the number of picture which is less than 256 after being cropped:')
disp(k);       
disp('number of picture after screening in the img_list')
disp(j);

function [crop_img, crop_lbl, crop_array] = crop_march(new_img, lbl)

    sum_cols = sum(new_img, 1);
    sum_rows = sum(new_img, 2);
        
    thresh_dark = 0.22*mean(sum_cols);
    thresh_bright = 110000;
    
    cols_left = 1;
    for c = 1:length(sum_cols)
        if sum_cols(c) <= thresh_dark || sum_cols(c) >= thresh_bright
            cols_left = c;
        elseif c - cols_left == 25
            break
        end
    end
    
    cols_right = length(sum_cols);
    for c = length(sum_cols):-1:1
        if sum_cols(c) <= thresh_dark || sum_cols(c) >= thresh_bright
            cols_right = c;
        elseif cols_right - c == 25
            break
        end
    end    
    
    thresh_dark = 0.22*mean(sum_rows);
    thresh_bright = 110000;
   
    rows_top = 1;
    for r = 1:length(sum_rows)
        if sum_rows(r) <= thresh_dark || sum_rows(r) >= thresh_bright
            rows_top = r;
        elseif r - rows_top == 25
            break
        end
    end
    
    rows_bot = length(sum_rows);
    for r = length(sum_rows):-1:1
        if sum_rows(r) <= thresh_dark || sum_rows(r) >= thresh_bright
            rows_bot = r;
        elseif rows_bot - r == 25
            break
        end
    end    
    
    crop_img = new_img(rows_top + 5:rows_bot - 5, cols_left + 5:cols_right - 5);
    crop_lbl = lbl(rows_top + 5:rows_bot - 5, cols_left + 5:cols_right - 5);
    crop_lbl = [ones(size(crop_lbl, 1), 1), crop_lbl(:, 2:end-1), ones(size(crop_lbl, 1), 1)];
    crop_lbl = [ones(1, size(crop_lbl, 2)); crop_lbl(2:end-1, :); ones(1, size(crop_lbl, 2))];

    crop_array = [rows_top + 5, rows_bot - 5, cols_left + 5, cols_right - 5];
    
    
end

function [adjust_img] = remove_gradient(crop_img)

% New Method
imgGS1 = imgaussfilt(crop_img, 21, 'FilterSize', [65, 65]);
imgsub = im2double(crop_img)-imgGS1;
imgsub2 = imgsub - min(imgsub(:));
subnorm8 = im2uint8(255*imgsub2./max(255*imgsub2(:)));
adjust_img = imadjust(subnorm8);

end

function [adjust_img] = anyingmeihua(file)

global omit;
div = 0;%deviate
m = 0;
oo=file;%copy a copy
I = imadjust(file,[0 1],[0.3 0.7]);
[h,w] = size(I);
I2 = uint8(I);

for i=1:h
    for j=1:w
        m = m + double(I(i,j));
    end
end
m = (m)/(h*w);
disp('m:');
%disp(m);

for i=1:h
    for j=1:w
        %disp((double(I(i,j))));
        div= div + abs(double(I(i,j))-m)*abs(double(I(i,j))-m);
        %disp(m);
    end
end
div = div^0.5;
%disp('diviate');
disp(div);


for i=1:h
    for j=1:w       
        if I(i,j)> m
            I2(i,j)=255;
        end
        if I(i,j) < m+2
            I2(i,j)=30;
        end        
    end
end
adjust_img = imadd(I2,I);
adjust_img = imadd(adjust_img*0.25,oo);
end