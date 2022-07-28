{ ... }:
final: prev: {
  st = prev.st.override { conf = builtins.readFile ./st/st.h; };
  vampir = prev.callPackage ./vampir { };
}
