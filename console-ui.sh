#!/bin/bash


OMNIPY_HOME="/home/pi/omnipy"

function UpdateOmnipy(){
	cd $OMNIPY_HOME/../
	backupfilename="omnipy_backup_"$(date +%d-%m-%y-%H%M%S)".tar.gz omnipy"
	tar -cvzf $backupfilename
	cd $OMNIPY_HOME
	git stash
	git pull -f
	bash $OMNIPY_HOME/scripts/pi-update.sh
}

function NewPODActivation(){
		cd $OMNIPY_HOME
		echo "cd $OMNIPY_HOME"
		echo "./omni.py readpdm"
		whiptail --title "Activate new POD" --msgbox "The pi is in waiting state, press Status on your PDM to the radio address." 8 45
		READPDM=$(./omni.py readpdm)
		#READPDM=$(cat readpdm.json)
		echo $READPDM
		STATUS=$(echo $READPDM | jq .success)
		echo $STATUS
		if [ $STATUS != "true" ]; then MainMenu; fi;

		RadioAddress=$(echo $READPDM | jq .response.radio_address)
		
		whiptail --title "POD Activation" --msgbox "The radio address is $RadioAddress." 10 60

		LotID=$(whiptail --title "Input" --inputbox "What is the LOT Number ?" 10 60 3>&1 1>&2 2>&3)
 		exitstatus=$?
		if [ $exitstatus -ne 0 ]; then MainMenu; fi;

		SerialID=$(whiptail --title "Input" --inputbox "What is the Serial Number ?" 10 60 3>&1 1>&2 2>&3)
                exitstatus=$?
                if [ $exitstatus -ne 0 ]; then MainMenu; fi;


		./omni.py newpod $LotID $SerialID $RadioAddress



}

function PODDeactivation(){
	whiptail --title "POD Deactivation" --msgbox "Don't forget to deactivate the POD on the PDM too !!!" 10 60
	echo "./omni.py deactivate"
}

function DeveloperMenu(){
			echo "Developer Menu"
		SUBOPTION=$(whiptail --title "Omnipy Developers Menu" --menu "Choose the action you want to perform" --cancel-button "Back" 20 50 9 \
			"1" "Rig status" \
			"2" "View POD.log" \
			"3" "View omnipy.log" \
			"4" "Stop Services" \
			"5" "Restart Services" \
			"6" "Check RileyLink" \
			"7" "Reconfigure Bluetooth" \
			"8" "Reset REST-API password" \
			"9" "Restore backup"  3>&1 1>&2 2>&3)

		exitstatus=$?
		if [ $exitstatus -ne 0 ]; then MainMenu; fi;


		case $SUBOPTION in
			1)
				cat ./omni.py status
			;;

			2)
				cat pod.log
			;;

			3)
				cat omnipy.log
			;;

			4)
				echo "sub menu 4"
			;;

			5)
				echo "sub menu 5"

			;;

			6)
				echo "sub menu 6"

			;;
			7)
				echo "sub menu 7"

			;;
			8)
				echo "sub menu 8"

			;;

			9)
				echo "sub menu 9"

			;;

		esac


}

function MainMenu(){

while true
do

OPTION=$(whiptail --title "Omnipy Menu" --menu "Choose the action you want to perform" --cancel-button "Back to shell" 20 50 6 \
"1" "Developer Menu" \
"2" "Activate New Pod" \
"3" "Deactivate Pod" \
"4" "Update Omnipy" \
"5" "Safe Reboot" \
"6" "Safe Shutdown"  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus -ne 0 ]; then exit; fi;

case $OPTION in
	1)
		DeveloperMenu
	;;

	2) #Activate a new pod
		NewPODActivation
	;;
	
	3)
		echo "POD Deactivation"
                if(whiptail --title "POD Deactivation" --yesno "Do you really want to deactivate the POD ?" 8 45)
			then
				echo "./omni.py deactivate"
				whiptail --title "POD Deactivation" --msgbox "Don't forget to deactivate the POD on the PDM too !!!" 10 60
			else
				whiptail --title "POD Deactivation" --msgbox "Deactivation cancelled" 8 45
		fi


	;;
	
	4)
		echo "Update Omnipy"
                if(whiptail --title "Update Omnipy" --yesno "Do you want to update omnipy to the latest master branch ?" 8 45)
                        then
                                UpdateOmnipy
                        else
                                echo "no reboot"
                fi

	;;

	5)
		echo "Safe Reboot"
                if(whiptail --title "Safe Reboot" --yesno "Do you want to reboot your pi ?" 8 45)
                        then
                                echo "sudo reboot"
                        else
                                echo "no reboot"
                fi

	;;

	6)
		echo "Safe Shutdown"
                if(whiptail --title "Safe Shutdown" --yesno "Do you want to shutdown your pi ?" 8 45)
                        then
                                echo "sudo shutdown now"
                        else
                                echo "no shutdown"
                fi
	;;

esac

done
}

MainMenu
