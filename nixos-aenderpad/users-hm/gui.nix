{ pkgs, ... }:
{
  home.file.".imapfilter/config.lua".source = ./imapfilter.lua;

  home.packages = with pkgs; [
    imapfilter
    #(weechat.override {
    #  configure = { availablePlugins, ... }: {
    #    scripts = with pkgs.weechatScripts; [
    #      weechat-otr
    #      wee-slack
    #      multiline
    #      weechat-matrix
    #    ];
    #    plugins = [
    #      availablePlugins.python
    #      availablePlugins.perl
    #      availablePlugins.lua
    #    ];
    #  };
    #})
  ];
}
