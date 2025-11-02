{ pkgs, ... }:
let
  theme = pkgs.writeText "powermenu.rasi" ''
    /**
     *
     * Author : Aditya Shakya (adi1090x)
     * Github : @adi1090x
     * 
     * Rofi Theme File
     * Rofi Version: 1.7.3
     **/

    /*****----- Configuration -----*****/
    configuration {
        show-icons:                 false;
    }

    /*****----- Global Properties -----*****/
    * {
        font:                        "JetBrains Mono Nerd Font 10";
        background:                  #11092D;
        background-alt:              #281657;
        foreground:                  #FFFFFF;
        selected:                    #DF5296;
        active:                      #6E77FF;
        urgent:                      #8E3596;
    }

    /*
    USE_BUTTONS=YES
    */

    /*****----- Main Window -----*****/
    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       800px;
        x-offset:                    0px;
        y-offset:                    0px;

        padding:                     0px;
        border:                      0px solid;
        border-color:                @selected;
        cursor:                      "default";
        background-color:            @background;
    }

    /*****----- Main Box -----*****/
    mainbox {
        background-color:            transparent;
        orientation:                 horizontal;
        children:                    [ "imagebox", "listview" ];
    }

    /*****----- Imagebox -----*****/
    imagebox {
        spacing:                     30px;
        padding:                     30px;
        background-color:            transparent;
        background-image:            url("${./powermenu.png}", height);
        children:                    [ "inputbar", "dummy", "message" ];
    }

    /*****----- User -----*****/
    userimage {
        margin:                      0px 0px;
        border:                      10px;
        border-radius:               10px;
        border-color:                @background-alt;
        background-color:            transparent;
        background-image:            url("${./powermenu.png}", height);
    }

    /*****----- Inputbar -----*****/
    inputbar {
        padding:                     15px;
        border-radius:               10px;
        background-color:            @urgent;
        text-color:                  @foreground;
        children:                    [ "dummy", "prompt", "dummy"];
    }

    dummy {
        background-color:            transparent;
    }

    prompt {
        background-color:            inherit;
        text-color:                  inherit;
    }

    /*****----- Message -----*****/
    message {
        enabled:                     true;
        margin:                      0px;
        padding:                     15px;
        border-radius:               10px;
        background-color:            @active;
        text-color:                  @background;
    }
    textbox {
        background-color:            inherit;
        text-color:                  inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     2;
        lines:                       2;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
    
        spacing:                     30px;
        margin:                      30px;
        background-color:            transparent;
        cursor:                      "default";
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        padding:                     40px 10px;
        border-radius:               10px;
        background-color:            @background-alt;
        text-color:                  @foreground;
        cursor:                      pointer;
    }
    element-text {
        font:                        "feather bold 32";
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }
    element selected.normal {
        background-color:            var(selected);
        text-color:                  var(background);
    }      
  '';
in
pkgs.writeShellApplication {
  name = "powermenu";
  runtimeInputs = with pkgs; [
    gnused
    nettools
    procps
    rofi
  ];
  text = ''
    uptime=$(uptime -p | sed -e 's/up //g')
    host=$(hostname)

    rofi_cmd() {
      rofi -dmenu \
        -p " $USER@$host" \
        -mesg " Uptime: $uptime" \
        -theme ${theme}
    }

    lock=""
    reboot=""
    logout=""
    shutdown=""

    run_rofi() {
    	echo -e "$lock\n$reboot\n$logout\n$shutdown" | rofi_cmd
    }

    run_cmd() {
    		if [[ $1 == '--lock' ]]; then
            dm-tool lock
    		elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
    		elif [[ $1 == '--logout' ]]; then
        		loginctl kill-user "$USER"
    		elif [[ $1 == '--shutdown' ]]; then
        		systemctl poweroff
    		fi
    }

    chosen=$(run_rofi)
    case $chosen in
        "$lock")
            run_cmd --lock
        ;;
        "$reboot")
            run_cmd --reboot
        ;;
        "$logout")
            run_cmd --logout
        ;;
        "$shutdown")
            run_cmd --shutdown
        ;;
    esac
  '';
}
