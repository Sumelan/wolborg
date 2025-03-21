{ config, ... }:
{
  home.file.".local/share/rofi/themes/system.rasi".text = ''
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
        background:     #${config.lib.stylix.colors.base00};
        background-alt: #${config.lib.stylix.colors.base09};
        foreground:     #${config.lib.stylix.colors.base05};
        selected:       #${config.lib.stylix.colors.base08};
        active:         #${config.lib.stylix.colors.base0B};
        urgent:         #${config.lib.stylix.colors.base0E};
    }
    /*
    USE_ICON=NO
    */

    /*****----- Main Window -----*****/
    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       400px;
        x-offset:                    0px;
        y-offset:                    0px;
        margin:                      0px;
        padding:                     0px;
        border:                      1px solid;
        border-radius:               20px;
        border-color:                @selected;
        cursor:                      "default";
        background-color:            @background;
    }

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     20px;
        background-color:            transparent;
        children:                    [ "inputbar", "message", "listview" ];
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        spacing:                     10px;
        padding:                     0px;
        border:                      0px;
        border-radius:               0px;
        border-color:                @selected;
        background-color:            transparent;
        text-color:                  @foreground;
        children:                    [ "textbox-prompt-colon", "prompt"];
    }

    textbox-prompt-colon {
        enabled:                     true;
        expand:                      false;
        str:                         "Good Night";
        padding:                     10px 13px;
        border-radius:               0px;
        background-color:            @urgent;
        text-color:                  @background;
    }
    prompt {
        enabled:                     true;
        padding:                     10px;
        border-radius:               0px;
        background-color:            @active;
        text-color:                  @background;
    }

    /*****----- Message -----*****/
    message {
        enabled:                     true;
        margin:                      0px;
        padding:                     10px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @selected;
        background-color:            @background-alt;
        text-color:                  @foreground;
    }
    textbox {
        background-color:            inherit;
        text-color:                  inherit;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     1;
        lines:                       6;
        cycle:                       true;
        scrollbar:                   false;
        layout:                      vertical;

        spacing:                     5px;
        background-color:            transparent;
        cursor:                      "default";
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        padding:                     10px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @selected;
        background-color:            transparent;
        text-color:                  @foreground;
        cursor:                      pointer;
    }
    element-text {
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }

    element normal.normal {
        background-color:            var(background);
        text-color:                  var(foreground);
    }
    element alternate.normal {
        background-color:            var(background);
        text-color:                  var(foreground);
    }
    element normal.urgent {
        background-color:            var(urgent);
        text-color:                  var(background);
    }
    element alternate.urgent {
        background-color:            var(urgent);
        text-color:                  var(background);
    }
    element selected.active {
        background-color:            var(urgent);
        text-color:                  var(background);
    }
    element normal.active {
        background-color:            var(active);
        text-color:                  var(background);
    }
    element alternate.active {
        background-color:            var(active);
        text-color:                  var(background);
    }
    element selected.urgent {
        background-color:            var(active);
        text-color:                  var(background);
    }
    element selected.normal {
        background-color:            var(selected);
        text-color:                  var(background);
    }
  '';
}
