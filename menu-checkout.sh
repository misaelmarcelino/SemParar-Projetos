#!/bin/bash
##

# VARIAVEIS
code_posto="$(cat /etc/abastece/lado1/posto.json | grep -e "codigoConveniado" | cut -d'"' -f4)"
pista_lado1="$(cat /etc/abastece/lado1/posto.json | grep -e "numeroPista" | cut -d' ' -f6 | cut -d',' -f1)" 
pista_lado2="$(cat /etc/abastece/lado2/posto.json | grep -e "numeroPista" | cut -d' ' -f6 | cut -d',' -f1)"

menu_checkout(){

    clear
    echo -e "###################################################\n"
    echo -e "\033[1;034m---------------- CHECKOUT ABASTECE ---------------\033[0m\n"        
    echo -e "###################################################\n"
    echo "Opção 1 - Executar Checkout Posto"
    echo "Opção 2 - Mover Arquivos e Desativar EVA"
    echo "Opção 3 - Executar Atualização - Valida Abastece"
    echo "Opção 4 - Ativar EVA"
    echo -e "Opção 5 - Sair\n"
    echo -e "###################################################\n"

}

opcao1(){
    source checkout/checkout-full.v1.sh
}

opcao2(){
    
    echo "SemParar" | sudo -S mv EDI/APL_* EDI/2.RECEBIMENTO

    sudo mv /var/abastece/eva/"$code_posto"_P0"$pista_lado1"_$(date +%Y%m).log /var/abastece/eva/"$code_posto"_P0"$pista_lado1"_$(date +%Y%m).log_ ; sudo mv /var/abastece/eva/"$code_posto"_P0"$pista_lado2"_$(date +%Y%m).log /var/abastece/eva/"$code_posto"_P0"$pista_lado2"_$(date +%Y%m).log_    

}

opcao3(){
    source checkout/valida-apl.sh
}

opcao4(){
    
    sudo mv /var/abastece/eva/"$code_posto"_P0"$pista_lado1"_$(date +%Y%m).log_ /var/abastece/eva/"$code_posto"_P0"$pista_lado1"_$(date +%Y%m).log ; sudo mv /var/abastece/eva/"$code_posto"_P0"$pista_lado2"_$(date +%Y%m).log_ /var/abastece/eva/"$code_posto"_P0"$pista_lado2"_$(date +%Y%m).log

}


#Loop de Inicialização do Menu
while true; do
    
    menu_checkout

    read -p "Digite a opção desejada: " opcao

    case $opcao in
        1) opcao1 ;;
        2) opcao2 ;;
        3) opcao3 ;;
        4) opcao4 ;;
        5) 
            echo "Saindo do Programa!"
            exit 0
            ;;
        *)
            echo "Opção Invalida. Tente Novamente!"
    esac

    read -p "Pressione Enter para continuar..."
done