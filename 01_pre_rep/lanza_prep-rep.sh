#!/bin/bash
#SBATCH --job-name=BsEst_repTAL   # Nome do job
#SBATCH --nodes=1                          # Numero de nós
#SBATCH --ntasks=1                         # Numero de tarefas (uma única tarefa)
#SBATCH --cpus-per-task=1                  # Numero de CPUs por tarefa
#SBATCH --gpus 1                           # Numero de GPUs por tarefa
#SBATCH --time=3-00:00:00                  # Tempo máximo de execução (3 dias)
#SBATCH --partition=gpu-x                  # Nome da partição
#SBATCH -o slurm/slurm.%j.out              # Nome do arquivo de saída
#SBATCH -e slurm/slurm.%j.err              # Nome do arquivo de erro

cd $SLURM_SUBMIT_DIR

source /home/users/gabrielc/chem/gcc-13.2/gcc-13.2-all
source /home/users/gabrielc/chem/amber25/amber.sh

#-----------------------------------#
export Exec=pmemd.cuda
export Parm='complex_box.top'
export Topo='complex_box.crd'
export minrc=../arq_entrada/01_min
export equilrc=../arq_entrada/02_equil/300k
#----------------------------------#
echo "iniciou teu calculo" ; date
for ((i=1; i<=7; i++)) ##Loop over min steps
do
    if [ $i -eq 1 ]
    then
        $Exec -O -i $minrc/min$i.in -p $Parm -c $Topo -o min$i.out -r min$i.rst -ref $Topo
    else
        $Exec -O -i $minrc/min$i.in -p $Parm -c min$(($i-1)).rst -o min$i.out -r min$i.rst -ref min$(($i-1)).rst
    fi
done
echo "------------------------------------------------"
echo "            Minimização terminou!              "
echo "------------------------------------------------"
for ((i=1; i<=9; i++)) ##Loop over equil steps
do
    if [ $i -eq 1 ]
    then
        $Exec -O -i $equilrc/equil$i.in -p $Parm -c min7.rst -o equil$i.out -r equil$i.rst -x equil$i.mdcrd -ref min7.rst
    else
        $Exec -O -i $equilrc/equil$i.in -p $Parm -c equil$(($i-1)).rst -o equil$i.out -r equil$i.rst -x equil$i.mdcrd -ref equil$(($i-1)).rst
    fi
done

echo "------------------------------------------------"
echo "      Aquecimento e equilibrio terminou!        "
echo "------------------------------------------------"
cp ../arq_entrada/03_production/prod_constra.in $equilrc/equil10.in .
#--------------------------------------------------------------------------------------------------------------------------#
export inicio=$PWD
export destino=$PWD/../02_replicas
mkdir $destino

for ((i=1; i<=3; i++)) # i é o número de replicas... mudar se precisar
do
    mkdir $destino/rep$i ; cp lanza_rep.sh $destino/rep$i/
    sed -i "s/TAL/$i/g" "$destino/rep$i/lanza_rep.sh"
    cd $destino/rep$i ; qsub $destino/rep$i/lanza_rep.sh ; cd $inicio
done
echo "------------------------------------------------"
echo "       Replicas submetidas com sucesso!         "
echo "------------------------------------------------"
date
