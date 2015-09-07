classdef FeatureDescriptor < handle
    % FeatureDescriptor: Manage different feature descriptors
    %
    % Example: 
    % im = imread('cameraman.tif');
    % points = detectFASTFeatures(im);
    % fd = FeatureDescriptor(descriptor);
    % fd_im = fd.compute(im_rgb, points.Location);
    %
    % fd_im.kps contains the keypoints after computing the descriptors
    % fd_im.des contains the descriptors
    
    properties
        descriptor_name
        parameters
        supported_descriptors = {'EHD', 'LGHD', 'PCEHD'}                              
    end
    
    %% Methods
    methods
        %% Constructor. Sets the descriptor
        function obj = FeatureDescriptor(descriptor_name)
            obj.set_descriptor_name(descriptor_name);
        end
        
        %% Sets the detector
        function set_descriptor_name(obj, descriptor_name)
            if(sum(strcmpi(descriptor_name, obj.supported_descriptors)) == 1)
                obj.descriptor_name = upper(descriptor_name);
            else
                obj.descriptor_name = upper(obj.supported_descriptors{1});
                fprintf('Descriptor %s is not supported\n', descriptor_name);
                fprintf('Using %s instead\n', obj.supported_descriptors{1});
            end
            obj.set_parameters(struct([]));
        end
        
        %% Sets descriptor parameters
        function set_parameters(obj, parameters)
           if isempty(parameters)
                switch(obj.descriptor_name)
                    case 'EHD'
                        obj.parameters = obj.ehd_default_parameters();
                    case 'LGHD'
                        obj.parameters = obj.lghd_default_parameters();
                    case 'PCEHD'
                        obj.parameters = obj.pcehd_default_parameters();       
                end
           else
                field_names = fieldnames(parameters); 
                for i = 1:numel(field_names) 
                    if isfield(obj.parameters,field_names{i})
                        obj.parameters.(field_names{i}) = parameters.(field_names{i});
                    else
                        fprintf('The parameter %s does not exist',field_names{i})
                    end
                end
           end
        end
        
        %% Get the list of the available descriptors
        function supported_descriptors = get_descriptors_available(obj)
            supported_descriptors = obj.supported_descriptors;
        end
        
        %% Detects features
        function result = compute(obj, im, kps)
            switch(obj.descriptor_name)
                case 'EHD'
                    result = obj.compute_ehd(im, kps');
                case 'LGHD'
                    result = obj.compute_lghd(im, kps');
                case 'PCEHD'
                    result = obj.compute_pcehd(im, kps');
            end
        end
    end
    
    %% Descriptors
    methods
        
        %% EHD
        function res = compute_ehd(obj, im, kps) 
            eh = zeros(80, size(kps,2));
            kps_to_ignore = zeros(1,size(kps,2));
            for i = 1: size(kps,2)
                % Patch location
                x = round(kps(1, i));
                y = round(kps(2, i));
                % Top-left point of patch
                x1 = max(1,x-floor(obj.parameters.patch_size/2));
                y1 = max(1,y-floor(obj.parameters.patch_size/2));
                x2 = min(x+floor(obj.parameters.patch_size/2),size(im,2));
                y2 = min(y+floor(obj.parameters.patch_size/2),size(im,1));
                % Ignore incomplete patches
                if y2-y1 ~= obj.parameters.patch_size || x2-x1 ~= obj.parameters.patch_size
                    kps_to_ignore(i)=1;
                    continue;
                end  
                %[eh1]=ehd(edge_map(y1:y2, x1:x2),[],3,0);  
                [eh1]=ehd(im(y1:y2, x1:x2),[],3,0);  
                eh(:,i)= eh1;
            end           
            res = struct('kps', kps(:,kps_to_ignore ==0)', 'des', eh(:,kps_to_ignore==0)');
        end

        %% LGHD
        function res = compute_lghd(obj, im, kps) 
            [~,~,~,~,~,eo,~] = phasecong3(im,4,6,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1); 
            eh = zeros(384, size(kps,2));
            kps_to_ignore = zeros(1,size(kps,2));
            for i = 1: size(kps,2)
                % Patch location
                x = round(kps(1, i));
                y = round(kps(2, i));
                % Top-left point of patch
                x1 = max(1,x-floor(obj.parameters.patch_size/2));
                y1 = max(1,y-floor(obj.parameters.patch_size/2));
                x2 = min(x+floor(obj.parameters.patch_size/2),size(im,2));
                y2 = min(y+floor(obj.parameters.patch_size/2),size(im,1));
                
                if y2-y1 ~= obj.parameters.patch_size || x2-x1 ~= obj.parameters.patch_size
                    kps_to_ignore(i)=1;
                    continue;
                end  
                patch_eo = eo;
                patch_eo{1,1} = eo{1,1}(y1:y2,x1:x2);
                patch_eo{1,2} = eo{1,2}(y1:y2,x1:x2);
                patch_eo{1,3} = eo{1,3}(y1:y2,x1:x2);
                patch_eo{1,4} = eo{1,4}(y1:y2,x1:x2);
                patch_eo{1,5} = eo{1,5}(y1:y2,x1:x2);
                patch_eo{1,6} = eo{1,6}(y1:y2,x1:x2);
                [eh1]=lghd(patch_eo);
                patch_eo{1,1} = eo{2,1}(y1:y2,x1:x2);
                patch_eo{1,2} = eo{2,2}(y1:y2,x1:x2);
                patch_eo{1,3} = eo{2,3}(y1:y2,x1:x2);
                patch_eo{1,4} = eo{2,4}(y1:y2,x1:x2);
                patch_eo{1,5} = eo{2,5}(y1:y2,x1:x2);
                patch_eo{1,6} = eo{2,6}(y1:y2,x1:x2);
                [eh2]=lghd(patch_eo);
                patch_eo{1,1} = eo{3,1}(y1:y2,x1:x2);
                patch_eo{1,2} = eo{3,2}(y1:y2,x1:x2);
                patch_eo{1,3} = eo{3,3}(y1:y2,x1:x2);
                patch_eo{1,4} = eo{3,4}(y1:y2,x1:x2);
                patch_eo{1,5} = eo{3,5}(y1:y2,x1:x2);
                patch_eo{1,6} = eo{3,6}(y1:y2,x1:x2);
                [eh3]=lghd(patch_eo);
                patch_eo{1,1} = eo{4,1}(y1:y2,x1:x2);
                patch_eo{1,2} = eo{4,2}(y1:y2,x1:x2);
                patch_eo{1,3} = eo{4,3}(y1:y2,x1:x2);
                patch_eo{1,4} = eo{4,4}(y1:y2,x1:x2);
                patch_eo{1,5} = eo{4,5}(y1:y2,x1:x2);
                patch_eo{1,6} = eo{4,6}(y1:y2,x1:x2);
                [eh4]=lghd(patch_eo);
               
                eh(:,i)= [eh1;eh2;eh3;eh4];
            end
            res = struct('kps', kps(:,kps_to_ignore ==0)', 'des', eh(:,kps_to_ignore==0)');
        end
        
        
        %% PCEHD
        function res = compute_pcehd(obj, im, kps) 
            [~,~,~,~,~,eo,~] = phasecong3(im,4,6,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1); 
            eh = zeros(104, size(kps,2));
            kps_to_ignore = zeros(1,size(kps,2));
            for i = 1: size(kps,2)
                % Patch location
                x = round(kps(1, i));
                y = round(kps(2, i));
                % Top-left point of patch
                x1 = max(1,x-floor(obj.parameters.patch_size/2));
                y1 = max(1,y-floor(obj.parameters.patch_size/2));
                x2 = min(x+floor(obj.parameters.patch_size/2),size(im,2));
                y2 = min(y+floor(obj.parameters.patch_size/2),size(im,1));
                if y2-y1 ~= obj.parameters.patch_size || x2-x1 ~= obj.parameters.patch_size
                    kps_to_ignore(i)=1;
                    continue;
                end  
                [eh1]=ehd(im(y1:y2, x1:x2),[],3,0); 
                %add frequency components
                freq=zeros(24,1);
                counter = 1;
                for j=1:4
                    for z=1:6
                        freq(counter) = abs(eo{j,z}(y,x));
                        counter = counter + 1;
                    end
                end
                eh(:,i)= [eh1;freq/norm(freq)];
            end
            res = struct('kps', kps(:,kps_to_ignore ==0)', 'des', eh(:,kps_to_ignore==0)');
        end
  
    end
    
    %% Default Parameters
    methods(Static)
        %% EHD
        function parameters = ehd_default_parameters()
             parameters = struct('patch_size', 100);
        end
        %% LGHD
        function parameters = lghd_default_parameters()
             parameters = struct('patch_size', 100);
        end
        %% PCEHD
        function parameters = pcehd_default_parameters()
             parameters = struct('patch_size', 100);
        end
      
    end
end

