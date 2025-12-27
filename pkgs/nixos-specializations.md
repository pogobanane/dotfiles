# NixOS-Specialisations

### History

In 2020, nested configurations were renamed to specialisations. Nesting exists since at least 2009 though (https://github.com/NixOS/nixpkgs/commit/65908cccd16f8b5f42b7d958f5819711293f2c2c)


### Motivation/Background

I believe the core feature of specialisations to be the following:
A specialisation is a NixOS configuration that must be realised, when its parent is active.
This guarantee makes it useful for a couple of use-cases:

- Multiple kernel versions, if you need to switch between them sometimes.
- Multiple hardware configurations for mobile computers (e.g. to set up network drivers or proxy)
- Multiple nix versions

In such cases you always want the specialisations of your current NixOS generation to be realised in the store so that you can directly activate it when needed without rebuilding the config.
Imagine, when you have a broken kernel, network, or nix, you won't be able to realize a different system.


### The Problem

People switch between nixos specialisations via the boot menu entries, via `nixos-rebuild switch --specialisation`, or by calling the specialisation's activation script manually.
All of which are inconvenient though:
Rebooting is slow.
Nixos-rebuild re-evaluates it, which contradicts the idea of the specialisation being relised already.
Finding the activation script manually takes too many brain cycles each time, especially when switching back from the specialisation to the parent config (because the specialisation does not know who is its parent config to prevent recursive dependencies).


### A Bad Workaround

When the active config is not a specialisation, we can list (and activate) specialisations using /etc/current-system/specialisation.
However, when the active config is a specialisation, /etc/current-system/specialisation is empty to prevent cyclic dependencies between the parent config and it's specialisation.
A naive workaround is to search all /nix/var/nix/profiles/**/specialisation for symlinks to the current-system to find a likely parent NixOS system.
This approach is imperfect and breaks when parent system but not the specialisation changes - and when users create multiple, similar profiles.


### This PR's approach
