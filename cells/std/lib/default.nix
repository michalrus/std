{ inputs
, cell
}:
let
  nixpkgs = inputs.nixpkgs;
in
{
  fromMakesWith = inputs': let
    inputsChecked =
      assert nixpkgs.lib.assertMsg (builtins.hasAttr "makes" inputs') (
        nixpkgs.lib.traceSeqN 1 inputs' ''

          In order to be able to use 'std.lib.fromMakesWith', an input
          named 'makes' must be defined in the flake. See inputs above.
        ''
      );
      # assert nixpkgs.lib.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
      #   nixpkgs.lib.traceSeqN 1 inputs' ''

      #     In order to be able to use 'std.lib.fromMakesWith', an input
      #     named 'nixpkgs' must be defined in the flake. See inputs above.
      #   ''
      # );
      inputs';
    makes = nixpkgs.lib.fix (
      nixpkgs.lib.extends (
        _: prev: {
          inputs = inputsChecked;
          __nixpkgs__ = nixpkgs;
          __nixpkgsSrc__ = nixpkgs.path;
          __system__ = nixpkgs.system;
          # makeScript = args: let
          #   d = prev.makeScript args;
          # in d // {
          #   meta.platforms = [ "x86_64-linux" "x86_64-darwin" ];
          # };
          # makeDerivation = args: let
          #   d = prev.makeDerivation args;
          # in d // {
          #   meta.platforms = [ "x86_64-linux" "x86_64-darwin" ];
          # };
        }
      )
      (
        # system is incorporated above while moving the fix point
        import (inputsChecked.makes + /src/args/agnostic.nix) { system = null; }
      )
      .__unfix__
    );
  in nixpkgs.lib.customisation.callPackageWith makes;
    # if inputsChecked.nixpkgs.stdenv.isLinux || inputsChecked.nixpkgs.stdenv.isDarwin
    # then nixpkgs.lib.customisation.callPackageWith makes
    # else (_: _: null);
}
