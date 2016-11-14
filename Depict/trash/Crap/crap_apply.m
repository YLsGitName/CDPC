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



 brain = spm_read_vols(The_mask);
 brind=find(brain);

 data_coord = [];

 MM = The_files_to_cluster(1).mat % voxel-to-coord matrix
 dim = The_files_to_cluster(1).dim

 count=0;

 for i=1:dim(1)
   for j=1:dim(2)
     for k=1:dim(3)
       if(brain(i,j,k)>0)
         count=count+1;
         coord(1,count)=MM(1,1)*i+MM(1,2)*j+MM(1,3)*k+MM(1,4);
         coord(2,count)=MM(2,1)*i+MM(2,2)*j+MM(2,3)*k+MM(2,4);
         coord(3,count)=MM(3,1)*i+MM(3,2)*j+MM(3,3)*k+MM(3,4);
       end
     end
   end
 end

 count

 scal=zeros(1,3);
 scal(1)=sqrt(MM(1,1:3)*MM(1,1:3)')
 scal(2)=sqrt(MM(2,1:3)*MM(2,1:3)')
 scal(3)=sqrt(MM(3,1:3)*MM(3,1:3)')


 for vol=vol_begin:vol_end


   data_intensity = [];


   for ind=1:winlen
      dat = spm_read_vols(The_files_to_cluster(vol+ind-1)); % reads the data from the structure
      dat=dat(brind);
      data_intensity(ind,:) = dat(:)'; %%% to have data in the format nvolumes x number of voxels
   end   

    [data_intensity]=FT_intensity(data_intensity,[0]);

    [final_assignation,density,dist_to_higher]=Cluster_brain(data_coord,scal,data_intensity,[NCUT,SPATIALCUT,RHO,NCLUST_MAX,interactive,connectedcut]);

    final_assignation(1:3)











 end





 

