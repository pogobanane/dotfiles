let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  currentHostname = builtins.head (builtins.match "([a-zA-Z0-9]+)\n" (builtins.readFile "/etc/hostname"));
  flake = (builtins.getFlake (toString ./.));
  hostConfig = flake.nixosConfigurations.${currentHostname}.config;

  configGood = {
    config = {
      hostname = "foo";
      networking = {
        ip = "1.1.1.1";
        # port = { dev = "/dev/eth0"; gateway = "1.1.1.1"; };
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
  configBadRec = rec {
    config = {
      hostname = "foo";
      networking = {
        ip = "1.1.1.1";
        firewall = throw "foo";
        hostConfig = config;
      };
    };
    pkgs = "some pkgs";
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
          resultShallow = builtins.tryEval value;
          valueType = builtins.typeOf resultShallow.value;
        in
        (if resultShallow.success then 
          (if (valueType == "set") then 
              (sanitizerAttrset value) 
            else (if (valueType == "list") then
              (sanitizerList value)
            else
              resultShallow.value
          ))
        else
          (if (valueType == "set") then 
              (sanitizerAttrset value) 
            else (if (valueType == "list") then
              (sanitizerList value)
            else
              (sanitizingError resultShallow)
          ))
        )
  );
  # leaf can be any type except containers (set, list)
  sanitizeLeaf = (leaf: 
        let
          resultShallow = builtins.tryEval leaf;
          valueType = builtins.typeOf resultShallow.value;
        in
        (if resultShallow.success then 
              resultShallow.value
        else
              (sanitizingError resultShallow)
        )
  );
  sanitizerAttrset = (config:
    lib.mapAttrs
      (name: value:
        (sanitize value)
      )
      config
  );
  # recursively map attributes of recursive attrsets
  mapRecAttrsRec = (config: path: visited:
    lib.mapAttrs
      (name: value: let
        type = builtins.typeOf value;
        isAttrset = type == "set";
        currentPath = path ++ [name];
      in
        if isAttrset then 
          mapRecAttrsRec value currentPath (visited ++ [currentPath])
        else 
          "${currentPath}" # terminate recursion (return)
      )
      config
  );
  # recursively list all attribute paths of a recursive (infinite) attrset
  listRecAttrsRec = (attrset: path:
    lib.mapAttrsToList
    (name: value: let 
        currentPath = path ++ [name];
        type = builtins.typeOf value;
        isAttrset = type == "set";
        childrenPaths = (
          if isAttrset then 
            listRecAttrsRec value currentPath 
         else 
            []
        );
      in (lib.trace (childrenPaths) (
        [currentPath]
        ++ childrenPaths
      ))
    )
    attrset
  );

  # constructor so that i can add checks or documentation if i want to
  # TODO rename to mkNode
  mkValue = (args:
    # mytype: { attrset | leaf | reference}
    # value: the value of this node. If mytype==reference, then the referencing path.
    { inherit (args) mytype path value; }
  );

  trace = (expr: ret: lib.trace (builtins.deepSeq expr expr) ret);

  # recursively list all attribute paths of a recursive (infinite) attrset
  listRecAttrsRec2 = (attrset: path: seen: let
    parent = mkValue {
      mytype = "attrset";
      inherit path;
      value = attrset;
    };
    # TODO i guess we can also throw in attrsets when it contains a name like "${throw foo}"
    getChildren = attrset: lib.mapAttrsToList (name: value: 
      { inherit value; path = path ++ [name]; }
      ) attrset;
    children = getChildren attrset;

    childPaths = (seen: child: let
        childValue = sanitizeLeaf child.value;
        type = builtins.typeOf childValue;
        isAttrset = type == "set";
        firstSeenFn = (expr:
          lib.findFirst (node: node.value == expr) null seen
        );
        firstSeen = firstSeenFn childValue;
        isSeen = firstSeen != null;
      in
        (if isAttrset then
          (if isSeen then
            [(mkValue { 
              mytype = "reference"; 
              value = firstSeen.path; 
              inherit (child) path;
            })]
          else
            (listRecAttrsRec2 childValue child.path seen)
          )
        else
          [(mkValue {
            inherit (child) path;
            value = childValue;
            mytype = "leaf";
          })]
        )
    );

    childrenPathsFlat = lib.foldl 
      (list: child: let
          seen' = seen ++ list ++ [parent];
        in 
          (list ++ (childPaths seen' child))
      ) 
      []
      children
    ;
    msg = {
      inherit children;
    };
  in 
    # trace msg 
    ([parent] ++ childrenPathsFlat)
  );
  sanitizerList = (config: 
    builtins.map
      (value:
        (sanitize value)
      )
      config
  );
  nodes = listRecAttrsRec2 configBadRec [] [];
  path2String = path: builtins.concatStringsSep "." path;
  attrsetUpdates = builtins.map (node:
    if node.mytype == "attrset" then
      {
        # TODO not sure how to create an empty attrset here. If there is already something in the attrset, it is just replaced with an empty one. 
        path = [ "TODO" ];
        update = old: true;
      }
    else (if node.mytype == "reference" then
      # use references to break recursion
      {
        path = node.path;
        update = old: "reference#${path2String node.value}";
      }
    else
      # actual values
      {
        path = node.path;
        update = old: node.value;
      }
    )
  ) nodes;
  result = lib.updateManyAttrsByPath attrsetUpdates {};
in
  result
# sanitizerFn1 nixosConfig
# (sanitizerAttrsetRec configBadRec).config.hostname
# (mapRecAttrsRec configGood [] [])
# sanitizerAttrset hostConfig.networking
# sanitizerAttrset configBad
# listRecAttrsRec2 configGood [] []
# listRecAttrsRec2 configGood [] []
# builtins.toJSON configBadRec 

# This currently doesnt work on recursive configurations:
# works: nix-repl> :p rec { a = { b = 1; c= a; }; }
# but we cannot work on it without infinite recursion: :p lib.mapAttrsRecursive (name: value: if name == "b" then 2 else value) rec { a = { b = 1; c= a; }; }
# we could just set b, that requires knowledge of the name "b" at evaluation time. 
# Instead we want to (1) filter for values matching a criterion (throws) 
# and then (2) apply a map operation on them
#
# Simplification:
# Given a recursive attrset, we want to find all attrs, that fulfill a condition (say `value == "needle"`)
# `:p` in `nix repl` does this, but i need it as a nix function. 
# `lib.mapAttrsRecursiveCond` has no path/key-name available to `cond`. Hence we cannot use it to avoid recursion.
# Should we just build the list of visited paths ourselves?
