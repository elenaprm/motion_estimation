% compE565 Homework 3
% Nov. 15, 2021
% Name: Elena Pérez-Ródenas Martínez
% ID: 827-22-2533
% email: eperezrodenasm3836@sdsu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video Compression
% Location of input video: C:\Users\Elena Pérez-Ródenas\Desktop\SDSU\MULTIMEDIA 
% COMMUNICATION SYSTEMS\HW3\walk_qcif.avi (user should change this 
% according to the location of the file)
% M-file name: MotionEstimation.m
% output image: Figure 1: I-Frame
% Figure 2: Motion vector for image 7 and 8
% Figure 3: Y component of the original video frame 7, predicted video frame 8 and error frame
% Figure 4: Motion vector for image 8 and 9
% Figure 5: Y component of the original video frame 8, predicted video frame 9 and error frame
% Figure 6: Motion vector for image 9 and 10
% Figure 7: Y component of the original video frame 9, predicted video frame 10 and error frame
% Figure 8: Motion vector for image 10 and 11
% Figure 9: Y component of the original video frame 10, predicted video frame 11 and error frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;
clf;

video = VideoReader('C:\Users\Elena Pérez-Ródenas\Desktop\SDSU\MULTIMEDIA COMMUNICATION SYSTEMS\HW3\walk_qcif.avi');

width = video.Width;
height = video.Height;

% First we convert every frame to YCbCr
% With these variables we will count the number of frames of the video
i=0;
j=1;
while hasFrame(video)
    videoFrame(j).cdata = readFrame(video);
    Frame_YCbCr = rgb2ycbcr(videoFrame(j).cdata(:,:,:));
    Y_Comp(:,:,j) = Frame_YCbCr(:,:,1);
    Cb_Comp(:,:,j) = Frame_YCbCr(1:2:end,1:2:end,2);
    Cr_Comp(:,:,j) = Frame_YCbCr(1:2:end,1:2:end,3);
    i = i+1;
    j = j+1;
end

% We access the I-frame GoP(6:10)
I_Frame = Y_Comp(:,:,6);
imshow(I_Frame)
title('I-Frame')

total_MB = (width/16)*(height/16);
fprintf("The total number of blocks in the image is:%d\n",total_MB);

for i = 7:10
    Y_Comp(:,:,i-1) = Frame_YCbCr(:,:,1);
    Cb_Comp(:,:,i-1) = Frame_YCbCr(1:2:end,1:2:end,2);
    Cr_Comp(:,:,i-1) = Frame_YCbCr(1:2:end,1:2:end,3);
    
    originalFrame = Y_Comp(:,:,i);
    referenceFrame = Y_Comp(:,:,i+1);
    MBSize = 16;
    searchWindow = zeros(total_MB,2,2);
    
    [searchWindow,reconstructedImage, MSE,totalComparisons] = MotionEstimation(originalFrame,referenceFrame,MBSize);
    
    % Display Motion Vector, MSE and Error
    figure()
    quiver(searchWindow(:,2,1),searchWindow(:,1,1),searchWindow(:,2,2),searchWindow(:,1,2));
    title(['Motion vector for image ',num2str(i),' and ',num2str(i+1)]);
    
    fprintf("MSE between frame %d and %d is %d\n",i,i+1,MSE);
    
    figure()
    subplot(2,2,1),imshow(originalFrame),title(['Y Component of Original Video Frame:',num2str(i)])
    
    reconstructedImage = uint8(reconstructedImage);
    subplot(2,2,2),imshow(reconstructedImage),title(['Predicted video frame',num2str(i+1)])
    errorFrame = originalFrame - reconstructedImage;
    subplot(2,2,3),imshow(errorFrame),title('Error between original frame and predicted frame')
    
end

% Computational load

additionsSAD = 2*(MBSize*MBSize)-1;
w = 1;
posValues = (2*w+1)^2;
add = posValues*additionsSAD;
fprintf("\nTotal comparisons:%d\n",totalComparisons);
fprintf("\nTotal additions:%d",add);
