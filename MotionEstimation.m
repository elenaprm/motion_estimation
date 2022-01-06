function [searchWindow,reconstructedImage,MSE,totalComparisons] = MotionEstimation(originalFrame,referenceFrame,MBSize)
totalComparisons = 0;

[row,col] = size(originalFrame);
c = 1;
for RowMB = 1:MBSize:row
    for ColMB = 1:MBSize:col
        currentMb = originalFrame([RowMB:(RowMB+MBSize-1)],[ColMB:(ColMB+MBSize-1)]);
        min_loss = 999999999;
        elements = zeros(1,2);
        for RowBlock = -1:1
            for ColBlock = -1:1
                paddedRow = RowMB+RowBlock;
                paddedCol = ColMB+ColBlock;
                if ((paddedRow + MBSize - 1) <= row) && ((paddedCol +MBSize - 1)<= col) && (paddedRow > 0) && (paddedCol > 0)
                    RefMb = referenceFrame(paddedRow:(paddedRow+MBSize-1),paddedCol:(paddedCol+MBSize-1));
                    difference_matrix = RefMb - currentMb;
                    %Computing SAD
                    diff = abs(sum(difference_matrix(:)));
                    if (diff<min_loss)
                        min_loss = diff;
                        elements = [paddedRow,paddedCol];
                        % Calculate the MSE
                        MSE = sum(sum(difference_matrix.^2));
                        MSE = MSE./256;
                    end
                    totalComparisons = totalComparisons +1;
                end
            end
        end
        VectDisplay = [elements(1) - RowMB,elements(2) - ColMB];
        %Get the reconstructed image
        reconstructedImage(RowMB:(RowMB+MBSize - 1),ColMB:(ColMB+MBSize -1)) = referenceFrame(elements(1):(elements(1)+MBSize - 1),elements(2):(elements(2)+MBSize -1));
        % Update the searching window
        searchWindow(c,:,1) = [RowMB,ColMB];
        searchWindow(c,:,2) = VectDisplay;
        c = c+1;
    end
end

end