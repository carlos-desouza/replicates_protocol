#!/bin/bash
#SBATCH -n 1
#SBATCH --time 5-00:00:00
#SBATCH -p gpu
#SBATCH -J repTAL

Exibe os nós alocados para o Job
echo $SLURM_JOB_NODELIST
nodeset -e $SLURM_JOB_NODELIST
cd $SLURM_SUBMIT_DIR

module load md/amber20

export Step1Dir=../../01_pre_rep
export Exec=pmemd.cuda
export Parm=step3_input.parm7

## Ultima etapa de equilibrio + produção de 100ns
$Exec -O -i $Step1Dir/equil11.in -p $Step1Dir/$Parm -c $Step1Dir/equil10.rst -o equil11.out -r equil11.rst -x equil11.mdcrd -ref $Step1Dir/equil10.rst

$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c equil11.rst -o prod10ns.out -r prod10ns.rst -x prod10ns.mdcrd -ref equil11.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod10ns.rst -o prod20ns.out -r prod20ns.rst -x prod20ns.mdcrd -ref prod10ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod20ns.rst -o prod30ns.out -r prod30ns.rst -x prod30ns.mdcrd -ref prod20ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod30ns.rst -o prod40ns.out -r prod40ns.rst -x prod40ns.mdcrd -ref prod30ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod40ns.rst -o prod50ns.out -r prod50ns.rst -x prod50ns.mdcrd -ref prod40ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod50ns.rst -o prod60ns.out -r prod60ns.rst -x prod60ns.mdcrd -ref prod50ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod60ns.rst -o prod70ns.out -r prod70ns.rst -x prod70ns.mdcrd -ref prod60ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod70ns.rst -o prod80ns.out -r prod80ns.rst -x prod80ns.mdcrd -ref prod70ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod80ns.rst -o prod90ns.out -r prod90ns.rst -x prod90ns.mdcrd -ref prod80ns.rst
$Exec -O -i $Step1Dir/prod.in -p $Step1Dir/$Parm -c prod90ns.rst -o prod100ns.out -r prod100ns.rst -x prod100ns.mdcrd -ref prod90ns.rst

echo "------------------------------------------------"
echo "        Replica finalizada com sucesso!         "
echo "------------------------------------------------"
