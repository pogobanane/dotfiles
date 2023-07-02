let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  configGood = {
    config = {
      hostname = "foo";
      networking = {
        ip = "1.1.1.1";
        # firewall = throw "foo";
      };
    };
  };
  configBad = {
    config = {
      hostname = "foo";
      networking = {
        ip = "1.1.1.1";
        firewall = throw "foo";
      };
    };
    pkgs = "some pkgs";
  };
  configBadList = lib.recursiveUpdate configBad {
    config.packages = [
      "foo"
      "bar"
      3
      (throw "fizz")
      ({ buzz = { fizz = "fizz"; buzz = throw "buzz"; }; })
    ];
  };
  e = { x = throw ""; };
  sanitizerFn1 = (config:
    lib.mapAttrsRecursive
      (path: value:
        let
          result = builtins.tryEval (builtins.deepSeq value value);
        in
        (if result.success then result.value else "error")
      )
      config
  );
  sanitizerFn2 = (config:
    (builtins.tryEval (builtins.deepSeq config config)).success
  );
  tryEvalRecursive = (e: builtins.tryEval (builtins.deepSeq e e));
  # not recursive, but works:
  sanitizerFn3 = (config:
    lib.mapAttrs
      (name: value:
        let
          result = tryEvalRecursive value;
        in
        (if result.success then result.value else "error")
      )
      config
  );

  # the sanitizers here remove errors from an nix expression, replacing them with error strings. Thus a throwing nix expression becomes evaluatable.

  # needs to use shallow tryEval to yield correct results
  sanitizingError = (tryEvalResult:
    "Error: value of type ${builtins.typeOf tryEvalResult.value} cannot be evaluated due to an error (throw or assert)"
  );
  sanitize = (value: 
        let
          resultDeep = tryEvalRecursive value;
          resultShallow = builtins.tryEval value;
          valueType = builtins.typeOf resultShallow.value;
        in
        (if resultDeep.success then resultDeep.value else
          (if (valueType == "set") then 
              (sanitizerAttrset value) 
            else (if (valueType == "list") then
              (sanitizerList value)
            else
              (sanitizingError resultShallow)
          ))
        )
  );
  sanitizerAttrset = (config:
    lib.mapAttrs
      (name: value:
        (sanitize value)
      )
      config
  );
  sanitizerList = (config: 
    builtins.map
      (value:
        (sanitize value)
      )
      config
  );
in
# sanitizerFn1 nixosConfig
sanitizerAttrset configBadList
