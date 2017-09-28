#!/bin/bash

echo "#########################################"
echo "########## Tests automaticos  ###########"
echo "#########################################"


echo "#----------# COMIENZA test ejercicio 1 del informe y entrada estandar #----------#"

./tp0 -i - -o ./outputs/outputInformeEjemplo1.txt < ./inputs/inputInformeEjemplo1.txt

if diff -b ./outputs-aut/outputInformeEjemplo1-aut.txt ./outputs/outputInformeEjemplo1.txt; then echo "OK"; else
		echo ERROR;
fi


echo "#----------# FIN test ejercicio 1 del informe y entrada estandar #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test ejercicio 2 del informe y salida estandar #----------#"

./tp0 -i ./inputs/inputInformeEjemplo2.txt -o - > ./outputs/outputInformeEjemplo2.txt

if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test ejercicio 2 del informe y salida estandar #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con /-i -o - #----------#"

./tp0 -i -o - <./inputs/inputInformeEjemplo2.txt > ./outputs/outputInformeEjemplo2.txt

if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con /-i -o - #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con /-o -i - #----------#"

./tp0 -o -i - <./inputs/inputInformeEjemplo2.txt > ./outputs/outputInformeEjemplo2.txt

if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con /-o -i - #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test palabras con acentos #----------#"

./tp0 -i ./inputs/input0.txt -o ./outputs/output0.txt

if diff -b ./outputs-aut/output0-aut.txt ./outputs/output0.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test palabras con acentos #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con caritas #----------#"

./tp0 -i ./inputs/input1.txt -o ./outputs/output1.txt

if diff -b ./outputs-aut/output1-aut.txt ./outputs/output1.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con caritas #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con entrada estandar #----------#"

./tp0 --output ./outputs/outputStdin.txt < ./inputs/inputStdin.txt

if diff -b ./outputs-aut/outputStdin-aut.txt ./outputs/outputStdin.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con entrada estandar #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con salida estandar #----------#"

./tp0 --input ./inputs/inputStdout.txt > ./outputs/outputStdout.txt

if diff -b ./outputs-aut/outputStdout-aut.txt ./outputs/outputStdout.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con salida estandar #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test con entrada y salida estandar #----------#"

./tp0 < ./inputs/inputStdinStdout.txt > ./outputs/outputStdinStdout.txt

if diff -b ./outputs-aut/outputStdinStdout-aut.txt ./outputs/outputStdinStdout.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test con entrada y salida estandar #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test menu version (-V) #----------#"

./tp0 -V > ./outputs/outputMenuV.txt

if diff -b ./outputs-aut/outputMenuVersion-aut.txt ./outputs/outputMenuV.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test menu version (-V) #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test menu version (--version) #----------#"

./tp0 --version > ./outputs/outputMenuVersion.txt

if diff -b ./outputs-aut/outputMenuVersion-aut.txt ./outputs/outputMenuVersion.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test menu version (--version) #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test menu help (-h) #----------#"

./tp0 -h > ./outputs/outputMenuH.txt

if diff -b ./outputs-aut/outputMenuHelp-aut.txt ./outputs/outputMenuH.txt; then echo "OK"; else
		echo ERROR;
fi


echo "#----------# FIN test menu version (-h) #----------#"

echo "#-----------------------------------------------------#"

echo "#----------# COMIENZA test menu help (--help) #----------#"

./tp0 --help > ./outputs/outputMenuHelp.txt

if diff -b ./outputs-aut/outputMenuHelp-aut.txt ./outputs/outputMenuHelp.txt; then echo "OK"; else
		echo ERROR;
fi

echo "#----------# FIN test menu version (--help) #----------#"

echo "#-----------------------------------------------------#"

echo "#########################################"
echo "####### FIN Tests automaticos  ###########"
echo "#########################################"
