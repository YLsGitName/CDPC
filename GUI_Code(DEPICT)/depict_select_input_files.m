function depict_select_input_files(varargin)

global st
global defaults
global The_files_to_cluster
global lstselclusterui

  ctrl=0;

  prompt_select='Select files to cluster';

  count=0;

  while(ctrl==0 && count < 2)

     count=count+1;

     file_names_cell=spm_select(Inf,'any',prompt_select,[],pwd,'.*.nii$');
     if(isempty(file_names_cell)==1) 
         strerr=strcat('You did not select any file. Please Select 4D NIfTI file or at least six 3D NIfTI files');
         herror1 = errordlg(strerr,'error1');
         uiwait(herror1); 
         continue; 
     end
 
     file_names=cellstr(file_names_cell);

     ctrl2=1;
     for ii=1:size(file_names)
        [tok,rem]=strtok(file_names{ii},'.');
        if(strcmp(rem,'.nii')==0) 
           strerr=strcat('You selected a file which is not NIfTI. Please Select a 4D NIfTI file or at least six 3D NIfTI files');
           herror1 = errordlg(strerr,'error1');
           uiwait(herror1); 
           ctrl2=0; 
        end
     end
 
     if(ctrl2==0) 
        continue; 
     end

     if(size(file_names,1)==1)
          files_to_cluster=spm_vol(file_names{1});
          if(size(files_to_cluster,1)<2)
            strerr=strcat('The file you chose is a 3D NIfTI file. Please Select a 4D NIfTI file or at least six 3D NIfTI files');
            herror1 = errordlg(strerr,'error1');
            uiwait(herror1); 
          elseif(size(files_to_cluster,1)<6)
            strerr=strcat('The fileis you chose include only  ', num2str(size(files_to_cluster,1)),' images. Please select at least 6 images');
            herror1 = errordlg(strerr,'error1');
            uiwait(herror1); 
          else
             ctrl2=1;
             ctrl=1;
          end 
     elseif(size(file_names,1)>1 && size(file_names,1)<6)
          strerr=strcat('You chose a list of  ', num2str(size(file_names,1)),' NIfTi files. Please select at least six (3D) NIfTI files');
          herror1 = errordlg(strerr,'error1');
          uiwait(herror1); 
     else
          ctrl2=1;
          for ii=1:size(file_names,1)
              file_to_cluster=spm_vol(file_names{ii});
              if(size(file_to_cluster,1)>1)
                  strerr=strcat('The list you chose includes at least one 4D NIfTi file. Please Select a single 4D NIfTI or at least six 3D NIfTI');
                  herror1 = errordlg(strerr,'error1');
                  uiwait(herror1); 
                  ctrl2=0; 
                  break;
              end
          end
          if(ctrl2==1) 
             ctrl=1;
             files_to_cluster=spm_vol(file_names_cell);  
          %else
          %   prompt_select='Please Select 4D image or at least six 3D images'  
          end
      end

  end

  try, The_files_to_cluster=files_to_cluster; end

  filenames=[];

  if(strcmp(The_files_to_cluster(1).descrip, '4D image')==1)
     filenames=The_files_to_cluster(1).fname;
  else
     for ii=1:size(The_files_to_cluster,1)
        filenames=[filenames;The_files_to_cluster(ii).fname];
     end
  end

  set(lstselclusterui,'string',filenames);
  set(lstselclusterui,'Value',[1:size(filenames,1)]);

end % end function



