addpath('/scratch/mallegra/spm12/');

global The_files_to_cluster
global The_mask

global connectedcut
global interactive
global vol_begin
global vol_end
global winlen
global NCUT
global SPATIALCUT
global RHO
global NCLUST_MAX


connectedcut=0
interactive=0
vol_begin=1
vol_end=1
winlen=12
NCUT=200
SPATIALCUT=5
RHO=0
NCLUST_MAX=10

The_mask=spm_vol(spm_select('FPlist','/scratch/mallegra/clenching_final/s0/anat/','^all_shima.nii$'));


The_files_to_cluster=spm_vol(spm_select('FPlist','/scratch/mallegra/clenching_final/s0/','^4Dras.nii$'));

 

 brain = spm_read_vols(The_mask);
 brain=permute(brain,[2 1 3]);
 
 brain=permute(brain,[3 2 1]);

 brind=find(brain);

 brind(1)

 brain=permute(brain,[3 2 1]);


 data_coord = [];

 MM = The_files_to_cluster(1).mat; % voxel-to-coord matrix
 dim = The_files_to_cluster(1).dim;

 count=0;


 scal=zeros(1,3);
 scal(1)=sqrt(MM(1,1:3)*MM(1,1:3)');
 scal(2)=sqrt(MM(2,1:3)*MM(2,1:3)');
 scal(3)=sqrt(MM(3,1:3)*MM(3,1:3)');


 for i=1:dim(1)
   for j=1:dim(2)
     for k=1:dim(3)
       if(brain(i,j,k)>0)
         count=count+1;
%         data_coord(1,count)=MM(1,1)*i+MM(1,2)*j+MM(1,3)*k+MM(1,4);
%         data_coord(2,count)=MM(2,1)*i+MM(2,2)*j+MM(2,3)*k+MM(2,4);
%         data_coord(3,count)=MM(3,1)*i+MM(3,2)*j+MM(3,3)*k+MM(3,4);
         data_coord(1,count)=scal(1)*i;
         data_coord(2,count)=scal(2)*j;
         data_coord(3,count)=scal(3)*k;

       end
     end
   end
 end

 size(data_coord)

 dlmwrite('merda1', data_coord', '\t');



 for vol=vol_begin:vol_end


   data_intensity = [];

  
   for ind=1:winlen
      dat = spm_read_vols(The_files_to_cluster(vol+ind-1)); % reads the data from the structure
      dat=permute(dat,[2 1 3]);
      dat=permute(dat,[3 2 1]);
      dat=dat(brind);
      data_intensity(ind,:) = dat(:)'; %%% to have data in the format nvolumes x number of voxels
   end   



    [data_intensity]=FT_intensity(data_intensity,[0]);



    [density,dist_to_higher,final_assignation]=Cluster_brain(data_coord,scal,data_intensity,[NCUT,SPATIALCUT,RHO,NCLUST_MAX,interactive,connectedcut]);

    true_NCLUST=max(final_assignation);    
    dmax=max(density);  

    dlmwrite('dd', density','\t');
    dlmwrite('hh', dist_to_higher','\t');


    out_data=zeros(dim(1),dim(2),dim(3),true_NCLUST);

    count=0;

    for i=1:dim(1)
      for j=1:dim(2)
        for k=1:dim(3)
          if(brain(i,j,k)>0 )
          count=count+1;
            if(final_assignation(count)>0)
              density(count)/dmax*100
              out_data(i,j,k,final_assignation(count))=density(count)/dmax*100;
            end
          end
        end
      end
    end



    for cl=1:true_NCLUST
       output(cl)=The_files_to_cluster(1);
       [path, name, ext] = fileparts(The_files_to_cluster(1).fname);
       outfname=strcat(path, '/cluster_map_', name,'_', num2str(vol_begin),'_',num2str(vol_begin+ind-1),'_',num2str(cl),'.nii')
       output(cl).fname = outfname;
       Image = spm_create_vol(output(cl));
       Image=spm_write_vol(output(cl), out_data(:,:,:,cl));
    end



    clear matlabbatch;
    outfname=strcat('cluster_map_', name,'_', num2str(vol_begin),'_',num2str(vol_begin+ind-1),'_.*.nii$')
    spm_select('FPList', path, outfname)
    temp = cellstr(spm_select('FPList', path, outfname))
    matlabbatch{1}.spm.util.cat.vols = temp;
    matlabbatch{1}.spm.util.cat.name = strcat('cluster_map_', name,'_', num2str(vol_begin),'_',num2str(vol_begin+ind-1),'.nii');
    matlabbatch{1}.spm.util.cat.dtype = 0;
    spm_jobman('run',matlabbatch);


    outfname=strcat('cluster_map_', name,'_', num2str(vol_begin),'_',num2str(vol_begin+ind-1),'_*');
    command=['rm -f ', path,'/',outfname];
    out=system(command);
 

 end





 

