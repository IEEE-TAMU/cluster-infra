{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  buildInputs = builtins.attrValues {
    inherit (pkgs)
      sops
      kubectl
      gnupg
      kubernetes-helm
      fluxcd
      ;
  };

  env.KUBECONFIG = "./k3s.yaml";

  shellHook = ''
    if [ ! -f ./k3s.yaml ]; then
      sops -d k3s.enc.yaml > k3s.yaml
      chmod 0600 k3s.yaml
    fi

    source <(kubectl completion `basename $SHELL`)
    source <(flux completion `basename $SHELL`)

    gpg --list-keys 75B5F14CB9CF5A951C935E86203E3E4D22C1B89B > /dev/null 2>&1 || gpg --import ./.sops.pub.asc
  '';
}
