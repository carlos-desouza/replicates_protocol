import os
import numpy

arquivos_origem = ['1rms_rep1_cd.dat', '1rms_rep2_cd.dat', '1rms_rep3_cd.dat', '1rms_rep4_cd.dat', '1rms_rep5_cd.dat', '1rms_rep6_cd.dat', '1rms_rep7_cd.dat', '1rms_rep8_cd.dat', '1rms_rep9_cd.dat', '1rms_rep10_cd.dat']
arquivos_destino = ['01_tratado/rep1_rmsd.dat', '01_tratado/rep2_rmsd.dat', '01_tratado/rep3_rmsd.dat', '01_tratado/rep4_rmsd.dat', '01_tratado/rep5_rmsd.dat', '01_tratado/rep6_rmsd.dat', '01_tratado/rep7_rmsd.dat', '01_tratado/rep8_rmsd.dat', '01_tratado/rep9_rmsd.dat', '01_tratado/rep10_rmsd.dat']
valor_x = 0
for origem, destino in zip(arquivos_origem, arquivos_destino):
    with open(origem, 'r') as arquivo_origem, open(destino, 'w') as arquivo_destino:
        for linha in arquivo_origem:
            x, y = map(float, linha.split())
            x += valor_x
            arquivo_destino.write(f"{x} {y}\n")
        valor_x += 10000