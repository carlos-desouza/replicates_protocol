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

#module load amber22
source ~/amber22/amber.sh
module load gnu9/9.4.0
module load openmpi4/4.1.1

export Step1Dir=../../01_pre_rep
export Exec=pmemd.cuda
export Parm=complex_box.top

$Exec -O -i $Step1Dir/equil10.in -p $Step1Dir/$Parm -c $Step1Dir/equil9.rst -o equil10.out -r equil10.rst -x equil10.mdcrd -ref $Step1Dir/equil9.rst      
for ((i=1; i<=50; i++))
do
    if [ $i -eq 1 ]; then
        $Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c equil10.rst -o prod${i}0ns.out -r prod${i}0ns.rst -x prod${i}0ns.mdcrd -ref equil10.rst           
    else
        $Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod$((i-1))0ns.rst -o prod${i}0ns.out -r prod${i}0ns.rst -x prod${i}0ns.mdcrd -ref prod$((i-1))0ns.rst
    fi
done
## Ultima etapa de equilibrio + produção de 100ns

echo "------------------------------------------------"
echo "        Replica finalizada com sucesso!         "
echo "------------------------------------------------"
