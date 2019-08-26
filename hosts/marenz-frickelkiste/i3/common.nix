{ ... }:

{
  environment.etc."i3.conf".source = ./i3.conf;
  environment.etc."i3-status.conf".source = ./i3-status.conf;
  environment.etc."i3/bri-dmenu.sh" = {
    source = ./bri-dmenu.sh;
    mode = "0755";
  };
  environment.etc."i3/ch-gamma.sh" = {
    source = ./ch-gamma.sh;
    mode = "0755";
  };
  environment.etc."i3/workspace__1.json".source = ./workspace__1.json;
  environment.etc."i3/workspace__2.json".source = ./workspace__2.json;
  environment.etc."i3/workspace__3.json".source = ./workspace__3.json;
  environment.etc."i3/workspace__5.json".source = ./workspace__5.json;
  environment.etc."i3/background" = {
    source = ./background;
    mode = "0644";
  };
  environment.etc."i3/lockscreen" = {
    source = ./lockscreen;
    mode = "0644";
  };
  environment.etc."tmuxp/set.yaml" = {
    source = ./set.yaml;
    mode = "0644";
  };
}
