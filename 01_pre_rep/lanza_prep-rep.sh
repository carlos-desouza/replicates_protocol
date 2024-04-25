#!/bin/bash
#PBS -N pre-rep
#PBS -l select=1:ncpus=1:ngpus=1
#PBS -l walltime=100:00:00
#PBS -q CCAD_QGPU
#PBS -o output.prep
#PBS -e error.prep
#-----------------------------------#
WORKDIR=$PBS_O_WORKDIR
echo $WORKDIR
cd $WORKDIR
module load md/amber22
#-----------------------------------#
export Exec=pmemd.cuda
export Parm='step3_input.parm7'
export Topo='step3_input.crd'
export minrc=../arq_entrada/01_min
export equilrc=../arq_entrada/02_equil/300k
#----------------------------------#
echo "iniciou teu calculo" ; date
for ((i=1; i<=7; i++)) ##Loop over min steps
do
    if (i=1)
    do
        $Exec -O -i $minrc/min($i).in -p $Parm -c $Topo -o min1.out -r min1.rst -ref $Topo
    fi
    $Exec -O -i $minrc/min($i).in -p $Parm -c min($i-1).rst -o min($i).out -r min($i).rst -ref min($i-1).rst    
done
echo "------------------------------------------------"
echo "            Minimização terminou!              "
echo "------------------------------------------------"
for ((i=1; i<=9; i++)) ##Loop over equil steps
do
    if (i=1)
    do
        $Exec -O -i $equilrc/equil($i).in -p $Parm -c min7.rst -o equil($i).out -r equil($i).rst -x equil($i).mdcrd -ref min7.rst
    fi
    $Exec -O -i $equilrc/equil($i).in -p $Parm -c equil($i-1).rst -o equil($i).out -r equil($i).rst -x equil($i).mdcrd -ref equil($i-1).rst  
done
echo "------------------------------------------------"
echo "      Aquecimento e equilibrio terminou!        "
echo "------------------------------------------------"
cp ../arq_entrada/03_production/prod.in .
#--------------------------------------------------------------------------------------------------------------------------#
export inicio=$PWD
export destino=$PWD/../02_replicas
for ((i=1; i<=10; i++)) # i é o número de replicas... mudar se precisar
do
    mkdir $destino/rep$i ; cp lanza_rep.sh $destino/rep$i/
    sed -i "s/TAL/$i/g" "$destino/rep$i/lanza_rep.sh"
    cd $destino/rep$i ; qsub $destino/rep$i/lanza_rep.sh ; cd $inicio
done
echo "------------------------------------------------"
echo "       Replicas submetidas com sucesso!         "
echo "------------------------------------------------"
