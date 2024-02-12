#!/bin/bash

main_screen() {
    CHOICE=$(whiptail --title "Main Menu" --menu "Choose an option" 25 78 16 \
            "1)" "List Users" \
            "2)" "Show User Details" \
            "3)" "Add User" \
            "4)" "Edit User" \
            "5)" "Delete User" \
            "6)" "List Groups" \
            "7)" "Add Group" \
            "8)" "Modify Group" \
            "9)" "Delete Group" \
            "10)" "End script"  3>&2 2>&1 1>&3
)

case $CHOICE in
    "1)") current_screen="ListUsers";;
    "2)") current_screen="ShowUserDetails";;
    "3)") current_screen="AddUser";;
    "4)") current_screen="EditUser";;
    "5)") current_screen="DeleteUser";;
    "6)") current_screen="ListGroups";;
    "7)") current_screen="AddGroup";;
    "8)") current_screen="ModifyGroup";;
    "9)") current_screen="DeleteGroup";;
    "10)") exit;;
esac
}
ListUsers_screen(){
    users=$(awk -F: '{ print $1 }' /etc/passwd)
    whiptail --title "User List" --scrolltext --msgbox "$users" 25 78
    current_screen="main"
}
ShowUserDetails_screen(){
    username=$(whiptail --inputbox "Enter username:" 8 40 --title "User Details" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$username" ]; then
        whiptail --msgbox "User Details canceled." 8 40
        current_screen="main"
    else
        details=$(id "$username")
        whiptail --title "$username Details" --msgbox "$details" 25 78
        current_screen="main"
    fi
}
AddUser_screen(){
    username=$(whiptail --inputbox "Enter username:" 8 40 --title "User Creation" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$username" ]; then
        whiptail --msgbox "User creation canceled." 8 40
        current_screen="main"
    else
        password=$(whiptail --passwordbox "Enter password for $username:" 8 40 --title "User Creation" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$password" ]; then
            whiptail --msgbox "User creation canceled." 8 40
            current_screen="main"
        else
            sudo useradd -m -s /bin/bash "$username"
            echo "$password" | sudo passwd --stdin $username
            whiptail --msgbox "User '$username' has been added'." 8 40
            current_screen="main"
        fi
    fi
}
EditUser_screen(){	
    Option=$(whiptail --title "Menu" --menu "Choose an option" 25 78 16 \
        "1)" "Modify User ID" \
        "2)" "Change Password" \
        "3)" "Add to Group" \
        "4)" "Lock Account" \
        "5)" "Back to Main Menu" 3>&2 2>&1 1>&3
    )
    case $Option in
        "1)")  
        username=$(whiptail --inputbox "Enter username to edit:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$username" ]; then
            whiptail --msgbox "User edit canceled." 8 40
            current_screen="EditUser"
        else
            new_uid=$(whiptail --inputbox "Enter new UID for $username:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ] || [ -z "$new_uid" ]; then
                whiptail --msgbox "User edit canceled." 8 40
                current_screen="EditUser"
            else
                sudo usermod -u "$new_uid" "$username"
                whiptail --msgbox "User '$username' UID changed to '$new_uid'." 8 40
                current_screen="EditUser"
            fi
        fi
        ;;

	    "2)")   
        username=$(whiptail --inputbox "Enter username to edit:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$username" ]; then
            whiptail --msgbox "User edit canceled." 8 40
            current_screen="EditUser"
        else
            new_password=$(whiptail --passwordbox "Enter new password for $username:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ] || [ -z "$new_password" ]; then
                whiptail --msgbox "User edit canceled." 8 40
                current_screen="EditUser"
            else
                echo "$new_password" | sudo passwd --stdin $username
                whiptail --msgbox "Password for user '$username' changed." 8 40
                current_screen="EditUser"
            fi
        fi
        ;;

	    "3)")   
		username=$(whiptail --inputbox "Enter username to edit:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$username" ]; then
            whiptail --msgbox "User edit canceled." 8 40
            current_screen="EditUser"
        else
            new_group=$(whiptail --inputbox "Enter new group for $username:" 8 40 --title "Edit User" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ] || [ -z "$new_group" ]; then
                whiptail --msgbox "User edit canceled." 8 40
                current_screen="EditUser"
            else
                sudo usermod -aG "$new_group" "$username"
                whiptail --msgbox "User '$username' was added to group '$new_group'." 8 40
                current_screen="EditUser"
            fi
        fi
        ;;

        "4)")
        username=$(whiptail --inputbox "Enter username to lock:" 8 40 --title "Lock User Account" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$username" ]; then
            whiptail --msgbox "Locking account canceled." 8 40
            current_screen="EditUser"
        else
            sudo chage -E 0 "$username"
            whiptail --msgbox "User '$username' locked." 8 40
            current_screen="EditUser"
        fi
        ;;

	    "5)") current_screen="main"
        ;;  
	esac
}
DeleteUser_screen(){
    username=$(whiptail --inputbox "Enter username:" 8 40 --title "Delete User" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$username" ]; then
        whiptail --msgbox "User deletion canceled." 8 40
        current_screen="main"
    else
        if  whiptail --yesno "Are you sure you want to delete user '$username'?" 8 60; then
            sudo userdel -r "$username"
            whiptail --msgbox "User '$username' deleted." 8 40
            current_screen="main"
        else
            whiptail --msgbox "User deletion canceled." 8 40
            current_screen="main"
        fi
    fi
}
ListGroups_screen(){
    groups=$(awk -F: '{ print $1 }' /etc/group)
    whiptail --title "Group List" --scrolltext --msgbox "$groups" 25 78
    current_screen="main"
}
AddGroup_screen(){ 
    groupname=$(whiptail --inputbox "Enter group name:" 8 40 --title "Group Creation" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$groupname" ]; then
        whiptail --msgbox "Group creation canceled." 8 40
        current_screen="main"
    else
        sudo groupadd "$groupname"
        whiptail --msgbox "group $groupname has been created"
        current_screen="main"
    fi
}
ModifyGroup_screen(){   
    Option=$(whiptail --title "Menu" --menu "Choose an option" 25 78 16 \
        "1)" "Modify Group ID" \
        "2)" "Modify Group Name" \
        "3)" "Back to Main Menu" 3>&2 2>&1 1>&3
    )
    case $Option in
        "1)")  
        gname=$(whiptail --inputbox "Enter group name to edit:" 8 40 --title "Modify Group" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$gname" ]; then
            whiptail --msgbox "Group modification canceled." 8 40
            current_screen="ModifyGroup"
        else
            new_gid=$(whiptail --inputbox "Enter new GID for $gname:" 8 40 --title "Modify Group" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ] || [ -z "$new_gid" ]; then
                whiptail --msgbox "Group modification canceled." 8 40
                current_screen="ModifyGroup"
            else
                sudo groupmod -g "$new_gid" "$gname"
                whiptail --msgbox "Groud '$gname' GID changed to '$new_gid'." 8 40
                current_screen="ModifyGroup"
            fi
        fi
        ;;

	    "2)")   
        gnameO=$(whiptail --inputbox "Enter group name to edit:" 8 40 --title "Modify Group" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ] || [ -z "$gnameO" ]; then
            whiptail --msgbox "Group modification canceled." 8 40
            current_screen="ModifyGroup"
        else
            gnameN=$(whiptail --inputbox "Enter new group name for $gnameO:" 8 40 --title "Modify Group" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ] || [ -z "$gnameN" ]; then
                whiptail --msgbox "Group modification canceled." 8 40
                current_screen="ModifyGroup"
            else
                groupmod -n "$gnameN" "$gnameO"
                whiptail --msgbox "$gnameO group name was changed to $gnameN" 8 40
                current_screen="ModifyGroup"
            fi
        fi
        ;;

	    "3)") current_screen="main"
        ;;  
	esac
}
DeleteGroup_screen(){
    gname=$(whiptail --inputbox "Enter group name:" 8 40 --title "Delete Group" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$gname" ]; then
        whiptail --msgbox "Group deletion canceled." 8 40
        current_screen="main"
    else
        if  whiptail --yesno "Are you sure you want to delete Group '$gname'?" 8 60; then
            sudo groupdel "$gname"
            whiptail --msgbox " group $gname deleted" 8 40
            current_screen="main"
        else
            whiptail --msgbox "Group deletion canceled." 8 40
            current_screen="main"
        fi
    fi
}

current_screen="main"
while true; do
    case $current_screen in
        "main") main_screen;;
        "ListUsers") ListUsers_screen;;
        "ShowUserDetails") ShowUserDetails_screen;;
        "AddUser") AddUser_screen;;
        "EditUser") EditUser_screen;;
        "DeleteUser") DeleteUser_screen;;
        "ListGroups") ListGroups_screen;;
        "AddGroup") AddGroup_screen;;
        "ModifyGroup") ModifyGroup_screen;;
        "DeleteGroup") DeleteGroup_screen;;
    esac
done
