#!/bin/bash

#############################################################
#                                                            #
# DESCRIÇÃO:APLICAÇÃO DE CHECKOUT - 2024                     #
#                                                            #
# Departamento: SUSTENTAÇÃO                                  #
#                                                            #
# Author: v1.4                                               #
#                                                            #
# Author: Misael S. Marcelino                                #
#                                                            #
#############################################################

###DIRETORIOS
file_version_slt="/var/abastece/SLT/VERSION"
file_version_sltStatus="/var/abastece/SLT/sltStatus.xml"
dir_presveic="/var/abastece/compsis"
file_log_presveic1="/var/abastece/compsis/presveic1/log/$(date +%Y%m%d)_PresVeic.log"
file_log_presveic2="/var/abastece/compsis/presveic2/log/$(date +%Y%m%d)_PresVeic.log"
file_version_forseti="/var/abastece/forseti/VERSION"
file_log_superService="/var/SuperService/SuperService.log"
file_version_img="/home/pi/Documentos/.img_version.txt"

# VARIAVEIS Globais DAS VERSÕES ATUAIS
nuc_version="NUC_X64_23.07.28.1"
architecture_version="x86_64"
abastece_version="23.09.06.2"
screen_abastece="IMG_052024"
superService_version="v1.42.7.1"
forseti_version="23.09.28.1"
slt_version="3.0"
saturno_version="Saturno3411"
vpar_version="2023.03.22"
preveic_version="1.18a"
standin_version="17042024"
version_agent="2024.1.0.1492"

echo 'SemParar' | sudo cat /etc/NetworkManager/system-connections/Wired\ connection\ 1 >> .network.log
address1="$(grep -E "address1=" /home/pi/.network.log | cut -c10- | cut -d'/' -f1)"
address2="$(grep -E "address2=" /home/pi/.network.log | cut -c10- | cut -d'/' -f1)"
novpn="$(grep -E "$address1" /home/pi/.network.log | cut -c10-12 | head -n 1 | awk '{if($1 == 192) {print "VPN"} else {print "NO"}}')"

## VALIDAÇÃO DE VERSÕES E APLICAÇÃO ABASTECE
station_code="$(cat /var/abastece/SLT/configpista/ifadapter.ini | grep -E 'plaza_code=' | cut -c12-16)"
station_name="$(cat /var/abastece/SLT/configpista/ifadapter.ini | grep -E 'plaza_name=' | cut -c12-)"

Nuc_Address(){
    ## VALIDAÇÃO ANYDESK INSTALL
    
    if [ "$novpn" = "VPN" ]; then
        
        anydesk="$(dpkg -l | grep "anydesk-" | wc -l)"

        if [ "$anydesk" = "1" ]; then
            id_anydesk="$(anydesk-client-abastece --get-id)"
            alias_novpn="$(anydesk-client-abastece --get-alias)"

            echo -e "NUC IP/Endereço:\t\tPOSTO NOVPN "
            echo -e "ID de Acesso AnyDesk:\t\t\033[1;034m$id_anydesk\033[0m"
            echo -e "Link de acesso NOVPN:\t\t\033[1;034m$alias_novpn\033[0m\n"
        fi
    else
        echo -e "Endereço IP VPN:\t\t$address1"
        echo -e "Endereço IP Local:\t\t$address2 \n"
    fi
    
}

NUC_Status(){
    if [ -e "$file_version_img" ]; then
        current_version_nuc="$(cat $file_version_img | \
        awk -v nuc_version="$nuc_version" '{if ($1 == nuc_version) {print "\033[1;32m"$1 " - IMAGEM NUC ATUALIZADA \033[0m"} else {print "\033[1;31m"$1 " - IMAGEM NUC DESATUALIZADA \033[0m"}}')"
        
        echo -e "IMAGEM NUC: $current_version_nuc \n"
    fi

    architecture_nuc="$(arch | \
    awk -v architecture_version="$architecture_version" '{if($1 == architecture_version) {print "\033[1;32m"$1 " - Atualizado \033[0m"} else {print "\033[1;31m"$1 " - Desatualizado\033[0m"}}')"

    Nuc_Address
    
    echo -e "Arquitetura do S.O:\t\t\033[0;36m$architecture_nuc\033[0m"
    
}


## SERVIÇOS OPERACIONAIS ABASTECE V4

Abastece_Status() {
    current_version_abastece="$( dpkg -l abastece | grep "abastece" | cut -d' ' -f10 |\
    awk -v version_abastece="$abastece_version" '{if($1 == version_abastece) {print "\033[1;32m"$1 " - Atualizado \033[0m"} else {print "\033[1;31m"$1 " - Desatualizadas \033[0m"}}' )"

    current_version_screen="$(head -n 1 /var/abastece/imagens/VERSION | \
    awk -v version_screen="$screen_abastece" '{if($1 == version_screen) {print "\033[1;32m"$1 " - Atualizadas\033[0m"} else {print "\033[1;31m"$1 " - Desatualizadas \033[0m"}}')"

    echo -e "Versão Abastece:\t\t$current_version_abastece"
    echo -e "Versão Telas Abastece:\t\t$current_version_screen"
}

## VALIDAÇÃO SERVIÇO SUPERSERVICE
superService_Status(){
    superservice="$(sudo superServiceStatus | grep "running" | wc -l)"

    if [ "$superservice" = "1" ] ; then
    if [ -e "$file_log_superService" ]; then 
            current_version_superservice="$(cat /var/SuperService/SuperService.log | grep "SuperService" | head -n 1 | cut -d' ' -f11 | awk -v version_superservice="$superService_version" '{if($1 == version_superservice) {print "\033[1;32m"$1 " - Atualizado\033[0m"} else {print "\033[1;31m"$1 " - Desatualizado \033[0m"}}')"
        fi
    else
        current_version_superservice="$(echo -e "\033[1;32mDesativado - Posto +BOMBAS\033[0m")"
    fi
    echo -e "Versão SuperService:\t\t$current_version_superservice"
    

    # VALIDA O TIPO DE CONCENTRADOR
    concentrador_type="$(grep -v "#" /var/SuperService/SuperService.ini | grep "DEV" | cut -d' ' -f3 | cut -d',' -f1)"
    concentrador_address="$(grep -v "#" /var/SuperService/SuperService.ini | grep "DEV" | cut -d' ' -f3 | cut -d',' -f3 | cut -d':' -f1)"
    concentrador_port="$(grep -v "#" /var/SuperService/SuperService.ini | grep "DEV" | cut -d' ' -f3 | cut -d',' -f3 | cut -d':' -f2)"
    stn_concentrador_address="$(grep "#" /var/SuperService/SuperService.ini | grep "STN" | cut -d' ' -f4 | cut -d',' -f2 | cut -d':' -f1)"
    if [ "$concentrador_type" = "STN" ]; then
        echo -e "Concentrador:\t\t\t\033[1;32m$concentrador_type - $stn_concentrador_address - $concentrador_port\033[0m"
    else
        echo -e "Concentrador:\t\t\t\033[1;32m$concentrador_type - $concentrador_address - $concentrador_port\033[0m"
    fi    
}

Slt_Status(){
    if [ -e "$file_version_slt" ]; then
        current_version_slt="$(cat "$file_version_slt" | awk -v version_saturno="$saturno_version" '{if($1 == version_saturno) print "\033[1;32mSaturno 3411 - Atualizado\033[0m"}')"
    else
        current_version_slt="$(cat "$file_version_sltStatus" | grep -oE "sltvs.{1,10}" | cut -d'"' -f2 | awk -v version_slt="$slt_version" '{if($1 == version_slt) {print "\033[1;31mSaturno - " $1 " - Desatualizado\033[0m"} else {print "\033[1;31mSltSlave " $1 " - Desatualizado\033[0m"}}')"
    fi

    echo -e "Versão SLT:\t\t\t$current_version_slt"


}

forseti_Status(){
    if [ -e "$file_version_forseti" ]; then
        current_version_forseti="$(grep  "$forseti_version" $file_version_forseti | \
        awk -v version_forseti="$forseti_version" '{if($1 == version_forseti) {print "\033[1;32m"$1 " - Atualizado\033[0m"} else {print "\033[1;31m"$1 " - Desatualizado \033[0m"}}')"
        else
            current_version_forseti="$(cat /var/abastece/forseti/logs/EVF_"$station_code"_$(date +%Y%m).log | head -n 1 | grep -e "Forseti Versao" | cut -d' ' -f7 | cut -d':' -f2 | \
            awk -v version_forseti="$forseti_version" '{if($1 == version_forseti) {print "\033[1;32m"$1 " - Atualizado\033[0m"} else {print "\033[1;31m"$1 " - Desatualizado \033[0m"}}' )"
    fi

    echo -e "Versão Forseti:\t\t\t$current_version_forseti"

}
Vpar_Status() {
    current_version_vpar="$(grep -ia "$vpar_version" patente/version.json | cut -d' ' -f6 | cut -d'"' -f2 | \
    awk -v version_vpar="$vpar_version" '{if($1 == version_vpar) {print "\033[1;32m"$1 " - Atualizado\033[0m"} else {print "\033[1;31m"$1 " - Desatualizado \033[0m"}}')"
    
    echo -e "Versão Vpar:\t\t\t$current_version_vpar"
}

StandIn_Status(){
    current_version_standin="$(cat /var/abastece/dados/STANDIN_VERSION | awk '{print $1}'| \
    awk -v version_standin="$standin_version" '{if($1 == version_standin) {print "\033[1;32m"$1 " - Atualizado\033[0m"} else {print "\033[1;31m"$1 " - Desatualizado\033[0m"}}')"

    echo -e "Versão StandIn:\t\t\t$current_version_standin"
}

Edi_Status(){
    net_command="netstat"

    if command -v "$net_command" &> /dev/null; then
        current_version_edi="$($net_command -tunl | grep "6443" | wc -l | awk '{if($1 >= 1) {print "\033[1;32mInstalado\033[0m" } else {print "\033[1;31mNão Instalado\033[0m"}}')"
    
        echo -e "Serviço EDI:\t\t\t$current_version_edi\n"
    fi
    
}

#STATUS E VALIDAÇÃO DAS VERSÃO DO SERVIÇO PRESVEIC
Presveic_Status(){
    
 # VALIDA SE O PRESVEIC ESTÁ INSTALADO 
    if [ -d  $dir_presveic ]; then
        presveic_status="$(presveicStatus | grep "dead" | wc -l)"
        if [ "$presveic_status" -eq 3 ]; then
            service_presveic="DESATIVADO"

            echo -e "Status Presveic:\t\t\033[1;31m$service_presveic\n\033[0m"   
        
        else 
            service_presveic="ATIVO"

            if [ -e "$file_log_presveic1" ] && [ -e "$file_log_presveic2" ] ; then
                current_presveic_lado1="$(grep -oP '"vprv":"\K[^"]*' /var/abastece/compsis/presveic1/log/$(date +%Y%m%d)_PresVeic.log | tail -n 1 | \
                awk '{if($1 != "1.18a") {print $1} else {print $1}}')"
                current_presveic_lado2="$(grep -oP '"vprv":"\K[^"]*' /var/abastece/compsis/presveic2/log/$(date +%Y%m%d)_PresVeic.log | tail -n 1 | \
                awk '{if($1 != "1.18a") {print $1} else {print $1}}')"
                current_version_presveic="$(grep -oP '"vprv":"\K[^"]*' /var/abastece/compsis/presveic1/log/$(date +%Y%m%d)_PresVeic.log | tail -n 1)"
                date_time_presveic_license="$(cat /var/abastece/compsis/presveic*/log/$(date +%Y%m%d)_PresVeic.log | grep -ia "licenca ate:" | tail -n 1 | cut -c34-44)"
            fi

            echo -e "Status Presveic:\t\t\033[1;32m$service_presveic\n\033[0m"

            if [ "$current_presveic_lado1" = "$current_presveic_lado2" ]; then
                echo -e "Versão Atual:\t\t\t\033[1;32m$current_version_presveic \033[0m"
                echo -e "Validade da Licença:\t\t\033[1;32m$date_time_presveic_license\033[0m\n"
                else
                    if [ "$current_presveic_lado1" != "$current_presveic_lado2" ]; then
                        echo -e "Versão Atual:\033[5;31mPRESVEIC DIFERENTES - LADO 1 E LADO 2!\033[0m"
                        echo -e "\t\033[5;31mFavor seguir com a validação das bibliotecas!\n\033[0m"
                    fi
            fi        

        fi
    else 
        echo -e "Status Presveic:\t\t\033[1;31mNÃO INSTALADO \n\033[0m"
    fi
}

# VALIDAÇÃO DA INSTALAÇÃO DO AGENTE SOLAR - VALIDAÇÃO DE MONITORAMENTO

Agente_Monitoramento(){
    
    if [ "$novpn" = "VPN" ]; then
        solar="$(sudo dpkg -l | grep "swiagent" | cut -d' ' -f55 | cut -d'-' -f1 | awk -v version_agent="$version_agent" '{if ($1 == version_agent) {print "\033[1;32m" $1 " - Atualizado\033[0m"} else {print "\033[1;31m" $1 " - Desatualizado\033[0m"}}')"
        echo -e "Agente de Monitoramento Instalado: $solar\n"
    else
        echo -e "\033[1;32mPOSTO VPN - Monitorado por ICMP\033[0m\n"
    fi
}

############################################################################################################
#                                           Execução da aplicação
############################################################################################################

clear
echo -e "=========================================================================\n"
echo -e "\n\n\033[1;33m\t\t\tCHECKOUT INICIAL - ABASTECE V4\n\n\033[0m"
echo -e "=========================================================================\n"
echo -e "\t\t\033[1;0m   $station_code" - "$station_name\n\033[0m"
echo -e "=========================================================================\n"

    NUC_Status
    Abastece_Status
    superService_Status
    Slt_Status
    forseti_Status
    Vpar_Status
    StandIn_Status
    Edi_Status
    Presveic_Status
    Agente_Monitoramento

echo -e "=========================================================================\n"
rm -f /home/pi/.network.log