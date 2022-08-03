{ ... }:

{
  environment.etc."sway/config".source = ./config;
  environment.etc."sway/i3-status.conf".source = ./i3-status.conf;
  environment.etc."sway/bri-dmenu.sh" = {
    source = ./bri-dmenu.sh;
    mode = "0755";
  };
  environment.etc."sway/workspace__1.json".source = ./workspace__1.json;
  environment.etc."sway/workspace__2.json".source = ./workspace__2.json;
  environment.etc."sway/workspace__3.json".source = ./workspace__3.json;
  environment.etc."sway/workspace__5.json".source = ./workspace__5.json;
  environment.etc."sway/workspace__0.json".source = ./workspace__0.json;
  environment.etc."sway/background" = {
    source = ./background;
    mode = "0644";
  };
  environment.etc."sway/lockscreen" = {
    source = ./lockscreen;
    mode = "0644";
  };
  environment.etc."tmuxp/set.yaml" = {
    source = ./set.yaml;
    mode = "0644";
  };
}
