{ ... }:

{
  environment.etc."i3.conf".text = builtins.readFile ./i3.conf;
  environment.etc."i3-status.conf".text = builtins.readFile ./i3-status.conf;
  environment.etc."i3/bri-dmenu.sh".text = builtins.readFile ./bri-dmenu.sh;
  environment.etc."i3/ch-gamma.sh".text = builtins.readFile ./ch-gamma.sh;
  environment.etc."i3/workspace__1.json".text = builtins.readFile ./workspace__1.json;
  environment.etc."i3/workspace__2.json".text = builtins.readFile ./workspace__2.json;
  environment.etc."i3/workspace__3.json".text = builtins.readFile ./workspace__3.json;
  environment.etc."i3/workspace__5.json".text = builtins.readFile ./workspace__5.json;
}
