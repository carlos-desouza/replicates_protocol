import sys

# Lista de nomes de arquivos de origem
arquivos_origem = ['1rms-cutinase_1-193_rep1.dat', '1rms-cutinase_1-193_rep2.dat', '1rms-cutinase_1-193_rep3.dat', '1rms-cutinase_1-193_rep4.dat', '1rms-cutinase_1-193_rep5.dat', '1rms-cutinase_1-193_rep6.dat', '1rms-cutinase_1-193_rep7.dat', '1rms-cutinase_1-193_rep8.dat', '1rms-cutinase_1-193_rep9.dat', '1rms-cutinase_1-193_rep10.dat']
arquivo_destino = 'rmsd_cut_free.dat'
colunas_origem = []
for nome_arquivo in arquivos_origem:
    with open(nome_arquivo, 'r') as origem:
        coluna_desejada = [linha.split()[1] for linha in origem.readlines()]
        colunas_origem.append(coluna_desejada)
colunas_transpostas = zip(*colunas_origem)
with open(arquivo_destino, 'w') as destino:
    for linha in colunas_transpostas:
        destino.write('\t'.join(linha) + '\n')