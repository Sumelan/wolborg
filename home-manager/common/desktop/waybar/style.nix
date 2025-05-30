{ config, ... }:
{
  programs.waybar.style =
    with config.lib.stylix.colors.withHashtag;
    let
      trayBackgroundColor = if config.stylix.polarity == "dark" then "${base00}" else "${base05}";
      tray-css =
        # css
        ''
          #tray {
            background: shade(alpha(${trayBackgroundColor}, 0.9), 1);
          }
        '';

      animation-css =
        # css
        ''
          @keyframes gradient {
            0% {
              background-position: 0% 50%;
            }
            50% {
              background-position: 100% 30%;
            }
            100% {
              background-position: 0% 50%;
            }
          }

          @keyframes gradient_f {
            0% {
              background-position: 0% 200%;
            }
            50% {
              background-position: 200% 0%;
            }
            100% {
              background-position: 400% 200%;
            }
          }

          @keyframes gradient_f_nh {
            0% {
              background-position: 0% 200%;
            }
            100% {
              background-position: 200% 200%;
            }
          }

          @keyframes gradient_rv {
            0% {
              background-position: 200% 200%;
            }
            100% {
              background-position: 0% 200%;
            }
          }
        '';
    in
    # css
    ''
      ${animation-css}

      * {
        /* all: unset; */
        font-family: "Maple Mono NF";
        font-weight: bold;
        font-size: ${builtins.toString (config.stylix.fonts.sizes.desktop + 3)}px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      tooltip {
        background: ${base01};
        border-radius: 5px;
        border-width: 2px;
        border-style: solid;
        border-color: ${base09};
      }

      #image,
      #clock,
      #battery,
      #wireplumber,
      #workspaces,
      #backlight,
      #tray {
        padding: 8px 8px;
        background: shade(alpha(${base00}, 0.9), 1);
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
        color: ${base05};
        margin-top: 6px;
        margin-bottom: 6px;
        margin-left: 4px;
        margin-right: 2px;
        box-shadow: 1px 2px 2px #101010;
        border-radius: 10px;
      }

      #image {
        padding: 6px 6px;
        border-radius: 20px;
        background: radial-gradient(circle, ${base00} 0%, ${base08} 100%);
        background-size: 400% 400%;
        animation: gradient_f 40s ease-in-out infinite;
        transition: all 0.3s cubic-bezier(0.55, -0.68, 0.48, 1.682);

      }

      #workspaces {
        font-size: 0px;
        padding: 8px 8px;
        border-radius: 20px;
      }

      #workspaces button {
        font-size: 0px;
        background-color: ${base06};
        padding: 0px 1px;
        margin: 0px 4px;
        border-radius: 20px;
        transition: all 0.25s cubic-bezier(0.55, -0.68, 0.48, 1.682);
      }

      #workspaces button.active {
        font-size: 1px;
        background-color: ${base09};
        border-radius: 20px;
        min-height: 30px;
        background-size: 400% 400%;
      }

      #workspaces button.empty {
        font-size: 1px;
        background-color: ${base04};
      }

      #battery {
        background: ${base0F};
        background: linear-gradient(
          124deg,
          ${base0E} 5%,
          ${base0D} 5%,
          ${base0D} 20%,
          ${base0E} 20%,
          ${base0E} 40%,
          ${base0D} 40%,
          ${base0D} 60%,
          ${base0E} 60%,
          ${base0E} 80%,
          ${base0D} 80%,
          ${base0D} 95%,
          ${base0E} 95%
        );
        background-size: 200% 300%;
        animation: gradient_f_nh 6s linear infinite;
        color: ${base01};
      }

      #battery.charging,
      #battery.plugged {
        background: linear-gradient(
          124deg,
          ${base0B} 5%,
          ${base0C} 5%,
          ${base0C} 20%,
          ${base0B} 20%,
          ${base0B} 40%,
          ${base0C} 40%,
          ${base0C} 60%,
          ${base0B} 60%,
          ${base0B} 80%,
          ${base0C} 80%,
          ${base0C} 95%,
          ${base0B} 95%
        );
        background-size: 200% 300%;
        animation: gradient_rv 4s linear infinite;
      }

      #battery.full {
        background: linear-gradient(
          124deg,
          ${base0B} 5%,
          ${base0C} 5%,
          ${base0C} 20%,
          ${base0B} 20%,
          ${base0B} 40%,
          ${base0C} 40%,
          ${base0C} 60%,
          ${base0B} 60%,
          ${base0B} 80%,
          ${base0C} 80%,
          ${base0C} 95%,
          ${base0B} 95%
        );
        background-size: 200% 300%;
        animation: gradient_rv 20s linear infinite;
      }

      ${tray-css}

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }
    '';
}
