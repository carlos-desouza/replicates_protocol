#PBS -S /bin/sh
#PBS -m abe
#PBS -q gpune
#PBS -l select=2:ncpus=2:ngpus=2:Qlist=Allnodes
#PBS -l walltime=148:00:00
#PBS -N 01_3WN2_novo_holo
#PBS -V
#PBS -o serial.log
#PBS -e serial.err
cd $PBS_O_WORKDIR
module load amber22
#module load openmpi/openmpi-4.0.5

export CUDA_VISIBLE_DEVICES=0,1

#Configura o executavel
#exeCUDA=pmemd.cuda
exeCUDA=pmemd.cuda
#exeMPI=pmemd.MPI
#exeCUDA=pmemd.cuda.MPI

#exibe informações sobre o executável
#/usr/bin/ldd $exeCUDA

######################## Min 
$exeCUDA -O -i min1.in -p step3_input.parm7 -c step3_input.rst7 -o min1.out -r min1.rst -ref step3_input.rst7
$exeCUDA -O -i min2.in -p step3_input.parm7 -c min1.rst -o min2.out -r min2.rst -ref min1.rst 
$exeCUDA -O -i min3.in -p step3_input.parm7 -c min2.rst -o min3.out -r min3.rst -ref min2.rst 
$exeCUDA -O -i min4.in -p step3_input.parm7 -c min3.rst -o min4.out -r min4.rst -ref min3.rst 
$exeCUDA -O -i min5.in -p step3_input.parm7 -c min4.rst -o min5.out -r min5.rst -ref min4.rst 
$exeCUDA -O -i min6.in -p step3_input.parm7 -c min5.rst -o min6.out -r min6.rst -ref min5.rst 
$exeCUDA -O -i min7.in -p step3_input.parm7 -c min6.rst -o min7.out -r min7.rst -ref min6.rst 

###################### Min Duplicat
$exeCUDA -O -i min1.in -p step3_input.parm7 -c min6.rst -o min1.out -r min1.rst -ref min6.rst 
$exeCUDA -O -i min2.in -p step3_input.parm7 -c min1.rst -o min2.out -r min2.rst -ref min1.rst 
$exeCUDA -O -i min3.in -p step3_input.parm7 -c min2.rst -o min3.out -r min3.rst -ref min2.rst 
$exeCUDA -O -i min4.in -p step3_input.parm7 -c min3.rst -o min4.out -r min4.rst -ref min3.rst 
$exeCUDA -O -i min5.in -p step3_input.parm7 -c min4.rst -o min5.out -r min5.rst -ref min4.rst 
$exeCUDA -O -i min6.in -p step3_input.parm7 -c min5.rst -o min6.out -r min6.rst -ref min5.rst 
$exeCUDA -O -i min7.in -p step3_input.parm7 -c min6.rst -o min7.out -r min7.rst -ref min6.rst 

###### 'Aquecimento com equilibrio : 10 etapas' ####################
$exeCUDA -O -i equil1.in -p step3_input.parm7 -c min7.rst -o equil1.out -r equil1.rst -x equil1.mdcrd -ref min7.rst 
$exeCUDA -O -i equil2.in -p step3_input.parm7 -c equil1.rst -o equil2.out -r equil2.rst -x equil2.mdcrd -ref equil1.rst 
$exeCUDA -O -i equil3.in -p step3_input.parm7 -c equil2.rst -o equil3.out -r equil3.rst -x equil3.mdcrd -ref equil2.rst 
$exeCUDA -O -i equil4.in -p step3_input.parm7 -c equil3.rst -o equil4.out -r equil4.rst -x equil4.mdcrd -ref equil3.rst 
$exeCUDA -O -i equil5.in -p step3_input.parm7 -c equil4.rst -o equil5.out -r equil5.rst -x equil5.mdcrd -ref equil4.rst 
$exeCUDA -O -i equil6.in -p step3_input.parm7 -c equil5.rst -o equil6.out -r equil6.rst -x equil6.mdcrd -ref equil5.rst 
$exeCUDA -O -i equil7.in -p step3_input.parm7 -c equil6.rst -o equil7.out -r equil7.rst -x equil7.mdcrd -ref equil6.rst 
$exeCUDA -O -i equil8.in -p step3_input.parm7 -c equil7.rst -o equil8.out -r equil8.rst -x equil8.mdcrd -ref equil7.rst 
$exeCUDA -O -i equil9.in -p step3_input.parm7 -c equil8.rst -o equil9.out -r equil9.rst -x equil9.mdcrd -ref equil8.rst 
$exeCUDA -O -i equil10.in -p step3_input.parm7 -c equil9.rst -o equil10.out -r equil10.rst -x equil10.mdcrd -ref equil9.rst 

####### 'DM : 100ns de produção' ####################
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c equil10.rst -o prod10ns.out -r prod10ns.rst -x prod10ns.mdcrd -ref equil10.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod10ns.rst -o prod20ns.out -r prod20ns.rst -x prod20ns.mdcrd -ref prod10ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod20ns.rst -o prod30ns.out -r prod30ns.rst -x prod30ns.mdcrd -ref prod20ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod30ns.rst -o prod40ns.out -r prod40ns.rst -x prod40ns.mdcrd -ref prod30ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod40ns.rst -o prod50ns.out -r prod50ns.rst -x prod50ns.mdcrd -ref prod40ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod50ns.rst -o prod60ns.out -r prod60ns.rst -x prod60ns.mdcrd -ref prod50ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod60ns.rst -o prod70ns.out -r prod70ns.rst -x prod70ns.mdcrd -ref prod60ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod70ns.rst -o prod80ns.out -r prod80ns.rst -x prod80ns.mdcrd -ref prod70ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod80ns.rst -o prod90ns.out -r prod90ns.rst -x prod90ns.mdcrd -ref prod80ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod90ns.rst -o prod100ns.out -r prod100ns.rst -x prod100ns.mdcrd -ref prod90ns.rst 

##### 'DM : 200ns de produção' ####################
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod100ns.rst -o prod110ns.out -r prod110ns.rst -x prod110ns.mdcrd -ref prod100ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod110ns.rst -o prod120ns.out -r prod120ns.rst -x prod120ns.mdcrd -ref prod110ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod120ns.rst -o prod130ns.out -r prod130ns.rst -x prod130ns.mdcrd -ref prod120ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod130ns.rst -o prod140ns.out -r prod140ns.rst -x prod140ns.mdcrd -ref prod130ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod140ns.rst -o prod150ns.out -r prod150ns.rst -x prod150ns.mdcrd -ref prod140ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod150ns.rst -o prod160ns.out -r prod160ns.rst -x prod160ns.mdcrd -ref prod150ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod160ns.rst -o prod170ns.out -r prod170ns.rst -x prod170ns.mdcrd -ref prod160ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod170ns.rst -o prod180ns.out -r prod180ns.rst -x prod180ns.mdcrd -ref prod170ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod180ns.rst -o prod190ns.out -r prod190ns.rst -x prod190ns.mdcrd -ref prod180ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod190ns.rst -o prod200ns.out -r prod200ns.rst -x prod200ns.mdcrd -ref prod190ns.rst 

###### 'DM : 300ns de produção' ####################
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod200ns.rst -o prod210ns.out -r prod210ns.rst -x prod210ns.mdcrd -ref prod200ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod210ns.rst -o prod220ns.out -r prod220ns.rst -x prod220ns.mdcrd -ref prod210ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod220ns.rst -o prod230ns.out -r prod230ns.rst -x prod230ns.mdcrd -ref prod220ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod230ns.rst -o prod240ns.out -r prod240ns.rst -x prod240ns.mdcrd -ref prod230ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod240ns.rst -o prod250ns.out -r prod250ns.rst -x prod250ns.mdcrd -ref prod240ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod250ns.rst -o prod260ns.out -r prod260ns.rst -x prod260ns.mdcrd -ref prod250ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod260ns.rst -o prod270ns.out -r prod270ns.rst -x prod270ns.mdcrd -ref prod260ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod270ns.rst -o prod280ns.out -r prod280ns.rst -x prod280ns.mdcrd -ref prod270ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod280ns.rst -o prod290ns.out -r prod290ns.rst -x prod290ns.mdcrd -ref prod280ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod290ns.rst -o prod300ns.out -r prod300ns.rst -x prod300ns.mdcrd -ref prod290ns.rst 

###### 'DM : 400ns de produção' ####################
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod300ns.rst -o prod310ns.out -r prod310ns.rst -x prod310ns.mdcrd -ref prod300ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod310ns.rst -o prod320ns.out -r prod320ns.rst -x prod320ns.mdcrd -ref prod310ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod320ns.rst -o prod330ns.out -r prod330ns.rst -x prod330ns.mdcrd -ref prod320ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod330ns.rst -o prod340ns.out -r prod340ns.rst -x prod340ns.mdcrd -ref prod330ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod340ns.rst -o prod350ns.out -r prod350ns.rst -x prod350ns.mdcrd -ref prod340ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod350ns.rst -o prod360ns.out -r prod360ns.rst -x prod360ns.mdcrd -ref prod350ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod360ns.rst -o prod370ns.out -r prod370ns.rst -x prod370ns.mdcrd -ref prod360ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod370ns.rst -o prod380ns.out -r prod380ns.rst -x prod380ns.mdcrd -ref prod370ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod380ns.rst -o prod390ns.out -r prod390ns.rst -x prod390ns.mdcrd -ref prod380ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod390ns.rst -o prod400ns.out -r prod400ns.rst -x prod400ns.mdcrd -ref prod390ns.rst 

##### 'DM : 500ns de produção' ####################
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod400ns.rst -o prod410ns.out -r prod410ns.rst -x prod410ns.mdcrd -ref prod400ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod410ns.rst -o prod420ns.out -r prod420ns.rst -x prod420ns.mdcrd -ref prod410ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod420ns.rst -o prod430ns.out -r prod430ns.rst -x prod430ns.mdcrd -ref prod420ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod430ns.rst -o prod440ns.out -r prod440ns.rst -x prod440ns.mdcrd -ref prod430ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod440ns.rst -o prod450ns.out -r prod450ns.rst -x prod450ns.mdcrd -ref prod440ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod450ns.rst -o prod460ns.out -r prod460ns.rst -x prod460ns.mdcrd -ref prod450ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod460ns.rst -o prod470ns.out -r prod470ns.rst -x prod470ns.mdcrd -ref prod460ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod470ns.rst -o prod480ns.out -r prod480ns.rst -x prod480ns.mdcrd -ref prod470ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod480ns.rst -o prod490ns.out -r prod490ns.rst -x prod490ns.mdcrd -ref prod480ns.rst 
$exeCUDA -O -i prod_constra.in -p step3_input.parm7 -c prod490ns.rst -o prod500ns.out -r prod500ns.rst -x prod500ns.mdcrd -ref prod490ns.rst
                                                                                                                                                                                                                                     
~              
