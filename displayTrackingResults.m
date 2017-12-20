function showId = displayTrackingResults( frame,mask,showId)
    global obj;
    global tracks;
        % Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

        minVisibleCount = 8;
        if ~isempty(tracks)

            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            
            for i=1:length(tracks)
                if reliableTrackInds(i) == 1 && tracks(i).showId == 0
                    tracks(i).showId = showId;
                    showId = showId + 1;
                end
            end
                    
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);

                % Get ids.
                ids = int32([reliableTracks(:).showId]);

                % Create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location.
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);

                % Draw the objects on the frame.
%                 for i=1:length(labels)
                    frame = insertObjectAnnotation(frame, 'circle', ...
                        [tracks(1).particleFilter.Particles(:,1),tracks(1).particleFilter.Particles(:,2) ones(1000,1)*1],0);
%                 end
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
%                 plot(tracks(1).particleFilter.Particles(1),tracks(1).particleFilter.Particles(2),'ro');hold on;
                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end

        % Display the mask and the frame.
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);
    end