function xVal = linePlot(diameters, pic, nmPerPixel, lines)
    
    %Initialize variables
    j = 1;
    lineTag = 0;
    lineTag2 = 0;
    currentLineTag = 0;
    deleted = [];
    
    %Set up the figure
    figure
    
    %make a subplot that contains 2 rows and 1 column
    a = subplot(2,1,1);
    
    %plot the graph of diameters
    plot(diameters(:,1), diameters(:,2));
    set(a, 'XLim', [0 diameters(end,1)]);
    set(a, 'YLim', [min(diameters(:,2))-5 max(diameters(:,2))+5]);
    
    %get the position of the graph. 1=left, 2=bottom, 3=width, 4=height.
    %All measured from the bottom left corner
    pos1 = get(a, 'Position');  
    
    %second plot
    b = subplot(2,1,2); 
    aspectRatio1 = pos1(4)/pos1(3);
    height = aspectRatio1*numel(pic(1,:));
    [row col] = find(pic>1);
    
    %Makes all the values greater than 1 now equal to 1
    for i = 1:numel(row)
        pic(row(i), col(i)) = 1;
    end
    
    %project the current picture to 3 more dimensions for RGB
    if numel(pic(:,1)) > height
        newPic = pic((numel(pic(:,1))-height)/2:...
            (numel(pic(:,1))+height)/2,:);
    else
        newPic = pic(:,:);
    end
    newPic(:,:,2) = newPic(:,:);
    newPic(:,:,3) = newPic(:,:,2);
    
    %Sets the position of picture. image as opposed to imshow makes 
    %this work
    h = image(newPic);
    pos2 = get(b, 'Position');
    pos2(3) = pos1(3);
    pos2(2) = pos1(2) - pos2(4);
    set(b, 'Position', pos2);
    
    
    if nargin == 4
        for i = 1:numel(lines(:,1))
            yLim = get(a, 'ylim');
            l = line([lines(i,1)*nmPerPixel lines(i,1)*nmPerPixel], ...
                yLim, 'Color', 'red',...
                'tag',strcat('line', int2str(j)));
            set(l, 'parent', a)
            yLim = get(b, 'yLim');
            l = line([lines(i,1) lines(i,1)],yLim,...
                'Color', 'red', 'tag',strcat('line', int2str(j),'_2'));
            set(l, 'parent', b);
            j = j+1;
        end
    end
    
    %Sets the functions to be called for button press and mouse click. 
    %Also waits for the @endAndOutput function to call uiresume.
    set(gcf,'WindowButtonDownFcn',@createLine)
    set(gcf,'KeyPressFcn', @endAndOutput)
    uiwait(gcf);
    
    
    %This function makes a line or finds the closest line to the mouse
    %click to determine the line to be moved.
    function createLine(src, event)
        
        %This first part will create a line for a left click
        if strcmp(get(src,'SelectionType'),'alt')
            clicked=get(gca,'currentpoint');
            xcoord=clicked(1,1,1);
            yLim = get(a, 'ylim');
            line([xcoord xcoord],yLim, 'Color', 'red',...
                'tag',strcat('line', int2str(j)));
            yLim = get(b, 'yLim');
            l = line([xcoord/nmPerPixel xcoord/nmPerPixel],yLim,...
                'Color', 'red', 'tag',strcat('line', int2str(j),'_2'));
            set(l, 'parent', b);
            j = j+1;
            
        %This else part cycles through all the lines and picks which 
        %one is closest in order to pick which line to drag
        else
            clicked=get(gca,'currentpoint');
            xcoord=clicked(1,1,1);
            minDist = inf;
            for i=1:j-1
                if ~any(deleted == i)
                    l1 = findobj(a, 'tag', strcat('line', int2str(i)));
                    l2 = findobj(b, 'tag', ...
                        strcat('line', int2str(i), '_2'));
                    lineX = get(l1, 'xdata');
                    lineX = lineX(1,1);
                    if abs(lineX-xcoord) < minDist
                        minDist = abs(lineX-xcoord);
                        lineTag = l1;
                        lineTag2 = l2;
                        currentLineTag = i;
                    end %end if the distance is smaller than the 
                        %current min distance
                end %end for determining if the line was deleted
            end %end looping over all the lines
            
            set(gcf,'windowbuttonmotionfcn',@moveLine)
            set(gcf,'KeyPressFcn', @deleteLine)
            set(gcf,'windowbuttonupfcn',@moveDone)
        end %end if right click or left click
        
    end %end createLine function

    function moveLine(src, event)
        clicked=get(gca,'currentpoint');
        xcoord=clicked(1,1,1);
        set(lineTag,'xdata',[xcoord xcoord]);
        set(lineTag2,'xdata',[xcoord/nmPerPixel xcoord/nmPerPixel]);
    end %end moveLine function

    function moveDone(src, event)
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        set(gcf,'KeyPressFcn', @endAndOutput)
    end %end moveDone function

    function endAndOutput(src, event)
        if strcmp(event.Character, ' ')
            k = 1;
            for i=1:j-1
                if ~any(deleted == i)
                    temp = findobj(gcf, 'tag', ...
                        strcat('line', int2str(i)));
                    temp2 = get(temp, 'xdata');
                    xVal(k,1) = k;
                    xVal(k,2) = temp2(1,1); 
                    k = k+1;
                end %end if line has been deleted
            end %end loop over all lines
            xVal = sortrows(xVal, 2);
            uiresume(gcf);
            close;
        end %end if the keypress was a space
    end %end endAndOutput function

    function deleteLine(src, event)
        if strcmp(event.Character, 'd')
            delete(lineTag);
            delete(lineTag2);
            deleted = [deleted currentLineTag];
            set(gcf,'windowbuttonmotionfcn','')
            set(gcf,'windowbuttonupfcn','')
            set(gcf,'KeyPressFcn', @endAndOutput)
        end %end if key press was d
    end %end deleteLine function
    
end