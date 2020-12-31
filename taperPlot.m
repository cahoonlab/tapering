function taperPlot(extracted)
% TAPERPLOT MATLAB code
% This function creates the final result for the function SigmaExtract.
% It takes the extracted results and plots the diameter profile, the
% diameter profile as calculated by the linear regression, and plots the
% beginning and end lines marking where the linear regression was
% performed.

    %calculate diameter profile from linear regression (y=mx+b)
    d = extracted.lin_reg.Coefficients{2,1} .* ...
        extracted.alldata(:,1) + extracted.lin_reg.Coefficients{1,1};
    slope = [extracted.alldata(:,1) d];
    
    %get the transition points (nm points along length)
    transitions = extracted.alldata(extracted.transitions,1); 
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set up the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure
    
    %make a subplot that contains 2 rows and 1 column
    a = subplot(2,1,1);
    
    %plot the measured diameter profile
    plot(extracted.alldata(:,1), extracted.alldata(:,2));
    set(a, 'XLim', [0 extracted.alldata(end,1)]);
    set(a, 'YLim', [min(slope(:,2))-mean(d)/2 ...
        max(slope(:,2))+mean(d)/2]);
    xlabel('Length (nm)')
    ylabel('Diameter (nm)')
    title(strrep(extracted.filename,'_','\_'))
    
    hold on
    plot(slope(:,1), slope(:,2),'r-')  %plot the linear regression line
    
    %plot the start and end line to mark where the linear regression 
    %took place
    line([transitions(1) transitions(1)], ...
        get(gca,'ylim'),'LineStyle','--','color','r') 
    line([transitions(2) transitions(2)], ...
        get(gca,'ylim'),'LineStyle','--','color','r')
    
    
    
    %get the position of the graph. 1=left, 2=bottom, 3=width, 4=height.
    %All measured from the bottom left corner
    pos1 = get(a, 'Position');  
    
        
    %second plot
    b = subplot(2,1,2); 
    aspectRatio1 = pos1(4)/pos1(3);
    height = aspectRatio1 * numel(extracted.pic(1,:));
    [row col] = find(extracted.pic > 1);
    
    %Makes all the values greater than 1 now equal to 1
    for i = 1:numel(row)
        extracted.pic(row(i), col(i)) = 1;
    end
    
    %project the current picture to 3 more dimensions for RGB
    if numel(extracted.pic(:,1)) > height
        newPic = extracted.pic((numel(extracted.pic(:,1)) - height) ...
            / 2 : (numel(extracted.pic(:,1)) + height) / 2, :);
    else
        newPic = extracted.pic(:,:);
    end
    newPic(:,:,2) = newPic(:,:);
    newPic(:,:,3) = newPic(:,:,2);
    
    %add a text box to the image to easily show sigma value
    show_sig = insertText(newPic, [40 length(newPic(:,1))-120], ...
        sprintf('%s = %.4f', char(963), extracted.sigma), ...
        'BoxOpacity', 0, 'FontSize', 48, 'TextColor', 'white');
%     h = image(newPic); %if you don't want to add text to the image
    imshow(show_sig)
    pos2 = get(b, 'Position');
    pos2(3) = pos1(3);
    pos2(2) = pos1(2) - 1.3*pos2(4);  %can shift the lower plot down
    set(b, 'Position', pos2);
    set(b, 'XTick', []);
    set(b, 'YTick', []);

end