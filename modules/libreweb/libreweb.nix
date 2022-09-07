{ pkgs, lib, config, ... }: let 

  hosts = {
    "188.114.96.3" = [ "kinox.to" "movie4k.to" "kinox.tv" "kinox.am"
    "movie4k.tv" "thepiratebay.gd" "thepiratebay.la" "thepiratebay.fm"
    "libgen.unblocked.at" "burning-series.net" "serienstream.be"
    "serienjunkies.org" "kinox.io" "kinox.sh" "kinox.lol" "kinox.wtf"
    "kinox.fun" "kinox.fyi" "ffmovies.biz" "fmovies.kim" "fmovies.mom"
    "seasonvar.ru" "kinokiste.club" "kkiste.ru" "kkiste.ac" "streamcloud.cam"
    "streamcloud-de.com" "filmpalast.to" "kinoz.to" "www13.kinoz.to"
    "movie4k.tv" "kinox.click" "kinox.club" "kinox.direct" "kinox.space"
    "kinox.bz" "kinox.am" "kinox.unblockit.buzz" "kinox.unblockit.bz"
    "kinox.unblockit.cam" "kinox.unblockit.club" "kinox.unblockit.link"
    "kinox.unblockit.ws" "kinox.unblockit.blue"
    "newalbumreleases.unblockit.buzz" "newalbumreleases.unblockit.link"
    "serienjunkies.org" "kinox.to" "NSW2U.com" ];

    "188.114.97.3" = [ "kinox.to" "movie4k.to" "kinox.tv" "kinox.am"
    "movie4k.tv" "thepiratebay.gd" "thepiratebay.la" "thepiratebay.fm"
    "libgen.unblocked.at" "burning-series.net" "serienstream.be"
    "serienjunkies.org" "kinox.io" "kinox.sh" "kinox.lol" "kinox.wtf"
    "kinox.fun" "kinox.fyi" "ffmovies.biz" "fmovies.kim" "fmovies.mom"
    "seasonvar.ru" "kinokiste.club" "kkiste.ru" "kkiste.ac" "streamcloud.cam"
    "streamcloud-de.com" "filmpalast.to" "kinoz.to" "www13.kinoz.to"
    "movie4k.tv" "kinox.click" "kinox.club" "kinox.direct" "kinox.space"
    "kinox.bz" "kinox.am" "kinox.unblockit.buzz" "kinox.unblockit.bz"
    "kinox.unblockit.cam" "kinox.unblockit.club" "kinox.unblockit.link"
    "kinox.unblockit.ws" "kinox.unblockit.blue"
    "newalbumreleases.unblockit.buzz" "newalbumreleases.unblockit.link"
    "serienjunkies.org" "kinox.to" "NSW2U.com" ];

    "2a06:98c1:3120::3" = [ "kinox.to" "kinox.tv" "kinox.am" "movie4k.tv"
    "thepiratebay.gd" "thepiratebay.la" "thepiratebay.fm" "libgen.unblocked.at"
    "burning-series.net" "serienstream.be" "serienjunkies.org" "kinox.io"
    "kinox.sh" "kinox.lol" "kinox.wtf" "kinox.fun" "kinox.fyi" "ffmovies.biz"
    "fmovies.kim" "fmovies.mom" "kinokiste.club" "kkiste.ru" "kkiste.ac"
    "streamcloud.cam" "streamcloud-de.com" "filmpalast.to" "kinoz.to"
    "www13.kinoz.to" "movie4k.tv" "kinox.click" "kinox.club" "kinox.direct"
    "kinox.space" "kinox.bz" "kinox.am" "kinox.unblockit.buzz"
    "kinox.unblockit.bz" "kinox.unblockit.cam" "kinox.unblockit.club"
    "kinox.unblockit.link" "kinox.unblockit.ws" "kinox.unblockit.blue"
    "newalbumreleases.unblockit.buzz" "newalbumreleases.unblockit.link"
    "serienjunkies.org" "kinox.to" "NSW2U.com" ];

    "2a06:98c1:3121::3" = [ "kinox.to" "kinox.tv" "kinox.am" "movie4k.tv"
    "thepiratebay.gd" "thepiratebay.la" "thepiratebay.fm" "libgen.unblocked.at"
    "burning-series.net" "serienstream.be" "serienjunkies.org" "kinox.io"
    "kinox.sh" "kinox.lol" "kinox.wtf" "kinox.fun" "kinox.fyi" "ffmovies.biz"
    "fmovies.kim" "fmovies.mom" "kinokiste.club" "kkiste.ru" "kkiste.ac"
    "streamcloud.cam" "streamcloud-de.com" "filmpalast.to" "kinoz.to"
    "www13.kinoz.to" "movie4k.tv" "kinox.click" "kinox.club" "kinox.direct"
    "kinox.space" "kinox.bz" "kinox.am" "kinox.unblockit.buzz"
    "kinox.unblockit.bz" "kinox.unblockit.cam" "kinox.unblockit.club"
    "kinox.unblockit.link" "kinox.unblockit.ws" "kinox.unblockit.blue"
    "newalbumreleases.unblockit.buzz" "newalbumreleases.unblockit.link"
    "serienjunkies.org" "kinox.to" "NSW2U.com" ];

    "70.34.195.168" = [ "kinox.nu" ];
    "172.67.134.61" = [ "kinox.me" ];
    "104.21.25.127" = [ "kinox.me" ];
    "2606:4700:3034::ac43:863d" = [ "kinox.me" ];
    "2606:4700:3030::6815:197f" = [ "kinox.me" ];
    "104.31.16.119" = [ "movie4k.me" "fmovies.to" "movie4k.me" "newalbumreleases.net" "newalbumreleases.net" ];
    "104.31.16.10" = [ "movie4k.me" "fmovies.to" "movie4k.me" "newalbumreleases.net" "newalbumreleases.net" ];
    "104.31.16.125" = [ "movie.to" "movie4k.org" "fmovies.coffee" ];
    "104.31.16.4" = [ "movie.to" "movie4k.org" "fmovies.coffee" ];
    "103.224.182.252" = [ "movie2k.cm" ];
    "69.16.230.42" = [ "szene-streams.com" "libgen.unblocked.vet" "libgen.unblocked.tv" "scihub.unblocked.vet" ];
    "2600:3c02::f03c:91ff:fee2:5b0f" = [ "szene-streams.com" "piratebayblocked.com" ];
    "103.224.182.251" = [ "filme-streamz.com" ];
    "199.59.243.222" = [ "kkiste.to" "movie4k.pe" "libgen.unblocked.la" "libgen.unblocked.pet" "movie4k.sg" ];
    "185.53.177.54" = [ "thepiratebay.sh" ];
    "185.53.177.52" = [ "thepiratebay.ms" ];
    "104.21.54.197" = [ "thepiratebay.vg" ];
    "172.67.141.94" = [ "thepiratebay.vg" ];
    "2606:4700:3032::6815:36c5" = [ "thepiratebay.vg" ];
    "2606:4700:3033::ac43:8d5e" = [ "thepiratebay.vg" ];
    "185.225.18.165" = [ "isohunt.to" ];
    "2a0a:c800:1:d::154" = [ "isohunt.to" ];
    "104.31.16.118" = [ "1337x.to" ];
    "104.31.16.11" = [ "1337x.to" ];
    "162.159.137.6" = [ "thepiratebay.org" ];
    "162.159.136.6" = [ "thepiratebay.org" ];
    "2606:4700:7::a29f:8906" = [ "thepiratebay.org" ];
    "2606:4700:7::a29f:8806" = [ "thepiratebay.org" ];
    "185.53.178.52" = [ "thepiratebay.red" ];
    "67.227.226.240" = [ "piratebayblocked.com" ];
    "99.83.154.118" = [ "pirateproxy.cam" "libgen.unblocked.pro" "movie4k.lol" ];
    "104.31.16.120" = [ "1337x.st" ];
    "104.31.16.9" = [ "1337x.st" ];
    "104.31.16.126" = [ "x1337x.ws" ];
    "104.31.16.3" = [ "x1337x.ws" ];
    "103.224.182.253" = [ "kinox.sg" "sci-hub.tw" "kinox.si" "fmovies.cx" ];
    "104.31.16.122" = [ "movie4k.am" "fmovies.taxi" ];
    "104.31.16.7" = [ "movie4k.am" "fmovies.taxi" ];
    "185.53.177.53" = [ "libgen.unblocked.win" ];
    "185.53.177.51" = [ "libgen.unblocked.lc" "scihub.unblocked.lc" "movie2k.nu" ];
    "217.26.63.20" = [ "libgen.unblocked.li" ];
    "2a00:d70:0:a::400" = [ "libgen.unblocked.li" ];
    "162.210.199.87" = [ "libgen.unblocked.red" ];
    "185.107.56.55" = [ "libgen.unblocked.uno" ];
    "81.171.28.44" = [ "libgen.unblocked.ink" ];
    "162.210.199.65" = [ "libgen.unblocked.sh" ];
    "72.52.178.23" = [ "libgen.unblocked.gdn" ];
    "193.218.118.42" = [ "gen.lib.rus.ec" ];
    "186.2.163.219" = [ "sci-hub.se" ];
    "104.21.70.220" = [ "sci-hub.ren" ];
    "172.67.139.245" = [ "sci-hub.ren" ];
    "2606:4700:3030::ac43:8bf5" = [ "sci-hub.ren" ];
    "2606:4700:3033::6815:46dc" = [ "sci-hub.ren" ];
    "104.21.9.230" = [ "sci-hub.shop" ];
    "172.67.161.98" = [ "sci-hub.shop" ];
    "2606:4700:3033::ac43:a162" = [ "sci-hub.shop" ];
    "2606:4700:3034::6815:9e6" = [ "sci-hub.shop" ];
    "190.115.31.20" = [ "bs.to" "bs.to" ];
    "186.2.163.237" = [ "s.to" "s.to" ];
    "104.21.66.208" = [ "streamkiste.tv" "streamkiste.tv" ];
    "172.67.164.93" = [ "streamkiste.tv" "streamkiste.tv" ];
    "2606:4700:3035::6815:42d0" = [ "streamkiste.tv" "streamkiste.tv" ];
    "2606:4700:3035::ac43:a45d" = [ "streamkiste.tv" "streamkiste.tv" ];
    "172.67.156.149" = [ "kinos.to" ];
    "104.21.8.4" = [ "kinos.to" ];
    "2606:4700:3030::ac43:9c95" = [ "kinos.to" ];
    "2606:4700:3037::6815:804" = [ "kinos.to" ];
    "172.67.148.31" = [ "kinox.sx" ];
    "104.21.55.128" = [ "kinox.sx" ];
    "2606:4700:3030::6815:3780" = [ "kinox.sx" ];
    "2606:4700:3031::ac43:941f" = [ "kinox.sx" ];
    "104.21.10.99" = [ "kinox.gratis" ];
    "172.67.131.78" = [ "kinox.gratis" ];
    "2606:4700:3032::ac43:834e" = [ "kinox.gratis" ];
    "2606:4700:3036::6815:a63" = [ "kinox.gratis" ];
    "172.67.168.167" = [ "kinox.mobi" ];
    "104.21.87.18" = [ "kinox.mobi" ];
    "2606:4700:3035::6815:5712" = [ "kinox.mobi" ];
    "2606:4700:3030::ac43:a8a7" = [ "kinox.mobi" ];
    "172.67.149.244" = [ "kinox.cloud" ];
    "104.21.57.211" = [ "kinox.cloud" ];
    "2606:4700:3030::6815:39d3" = [ "kinox.cloud" ];
    "2606:4700:3035::ac43:95f4" = [ "kinox.cloud" ];
    "89.191.237.192" = [ "www.rt.com" ];
    "178.176.128.128" = [ "de.rt.com" ];
    "91.215.41.7" = [ "francais.rt.com" ];
    "2.63.192.83" = [ "actualidad.rt.com" ];
    "91.215.41.5" = [ "actualidad.rt.com" ];
    "178.248.238.130" = [ "sputniknews.com" ];
    "89.191.237.195" = [ "deutsch.rt.com" ];
    "185.79.236.191" = [ "deutsch.rt.com" ];
    "185.79.236.192" = [ "fr.rt.com" ];
    "89.191.237.196" = [ "fr.rt.com" ];
    "178.248.234.228" = [ "radiosputnik.ria.ru" ];
    "80.247.32.209" = [ "www.rtr-planeta.com" ];
    "178.248.232.222" = [ "www.vesti.ru" ];
    "178.248.233.127" = [ "www.tvc.ru" ];
    "186.2.163.173" = [ "burningseries.co" ];
    "186.2.163.137" = [ "burningseries.tw" ];
    "190.115.31.145" = [ "burningseries.sx" ];
    "186.2.163.227" = [ "burningseries.ac" ];
    "190.115.31.148" = [ "burningseries.vc" ];
    "190.115.31.154" = [ "burningseries.nz" ];
    "190.115.31.37" = [ "burningseries.se" ];
    "186.2.163.190" = [ "serienstream.to" ];
    "186.2.163.71" = [ "serien.cam" ];
    "104.31.16.121" = [ "fmovies.media" "fmovies.wtf" "fmovies.cafe" ];
    "104.31.16.8" = [ "fmovies.media" "fmovies.wtf" "fmovies.cafe" ];
    "104.26.10.92" = [ "fmovies.ps" ];
    "172.67.74.185" = [ "fmovies.ps" ];
    "104.26.11.92" = [ "fmovies.ps" ];
    "2606:4700:20::681a:b5c" = [ "fmovies.ps" ];
    "2606:4700:20::ac43:4ab9" = [ "fmovies.ps" ];
    "2606:4700:20::681a:a5c" = [ "fmovies.ps" ];
    "104.21.69.166" = [ "fmovies.town" ];
    "172.67.210.140" = [ "fmovies.town" ];
    "2606:4700:3037::ac43:d28c" = [ "fmovies.town" ];
    "2606:4700:3037::6815:45a6" = [ "fmovies.town" ];
    "104.31.16.6" = [ "fmovies.world" ];
    "104.31.16.123" = [ "fmovies.world" ];
    "104.31.16.5" = [ "fmovies.pub" "fmovies.solar" ];
    "104.31.16.124" = [ "fmovies.pub" "fmovies.solar" ];
    "172.67.156.118" = [ "ww2.fmovies.cab" ];
    "104.21.81.25" = [ "ww2.fmovies.cab" ];
    "2606:4700:3035::ac43:9c76" = [ "ww2.fmovies.cab" ];
    "2606:4700:3032::6815:5119" = [ "ww2.fmovies.cab" ];
    "104.21.234.7" = [ "fmoviesto.cc" ];
    "104.21.234.6" = [ "fmoviesto.cc" ];
    "2606:4700:3038::6815:ea07" = [ "fmoviesto.cc" ];
    "2606:4700:3038::6815:ea06" = [ "fmoviesto.cc" ];
    "104.21.233.247" = [ "fmovies.hn" ];
    "104.21.233.248" = [ "fmovies.hn" ];
    "2606:4700:3038::6815:e9f8" = [ "fmovies.hn" ];
    "2606:4700:3038::6815:e9f7" = [ "fmovies.hn" ];
    "104.21.75.156" = [ "fmovies.ink" ];
    "172.67.178.110" = [ "fmovies.ink" ];
    "2606:4700:3031::6815:4b9c" = [ "fmovies.ink" ];
    "2606:4700:3036::ac43:b26e" = [ "fmovies.ink" ];
    "172.67.133.4" = [ "fmoviesf.co" ];
    "104.21.5.57" = [ "fmoviesf.co" ];
    "2606:4700:3030::ac43:8504" = [ "fmoviesf.co" ];
    "2606:4700:3032::6815:539" = [ "fmoviesf.co" ];
    "193.106.30.58" = [ "kinokiste.me" "movie2k.ag" ];
    "172.67.156.191" = [ "kinokiste.ru" ];
    "104.21.13.158" = [ "kinokiste.ru" ];
    "2606:4700:3032::ac43:9cbf" = [ "kinokiste.ru" ];
    "2606:4700:3036::6815:d9e" = [ "kinokiste.ru" ];
    "104.21.62.228" = [ "kkiste.club" ];
    "172.67.139.233" = [ "kkiste.club" ];
    "2606:4700:3031::ac43:8be9" = [ "kkiste.club" ];
    "2606:4700:3030::6815:3ee4" = [ "kkiste.club" ];
    "172.67.129.239" = [ "primekiste.com" ];
    "104.21.2.248" = [ "primekiste.com" ];
    "2606:4700:3034::ac43:81ef" = [ "primekiste.com" ];
    "2606:4700:3034::6815:2f8" = [ "primekiste.com" ];
    "172.67.216.250" = [ "kinox.express" ];
    "104.21.59.64" = [ "kinox.express" ];
    "2606:4700:3035::ac43:d8fa" = [ "kinox.express" ];
    "2606:4700:3037::6815:3b40" = [ "kinox.express" ];
    "172.67.150.82" = [ "kinox.tube" ];
    "104.21.79.246" = [ "kinox.tube" ];
    "2606:4700:3037::6815:4ff6" = [ "kinox.tube" ];
    "2606:4700:3035::ac43:9652" = [ "kinox.tube" ];
    "104.21.47.35" = [ "kinox.digital" ];
    "172.67.170.89" = [ "kinox.digital" ];
    "2606:4700:3034::6815:2f23" = [ "kinox.digital" ];
    "2606:4700:3030::ac43:aa59" = [ "kinox.digital" ];
    "104.21.73.188" = [ "kinox.pub" ];
    "172.67.165.109" = [ "kinox.pub" ];
    "2606:4700:3036::ac43:a56d" = [ "kinox.pub" ];
    "2606:4700:3031::6815:49bc" = [ "kinox.pub" ];
    "104.21.22.127" = [ "kinox.top" ];
    "172.67.205.9" = [ "kinox.top" ];
    "2606:4700:3030::6815:167f" = [ "kinox.top" ];
    "2606:4700:3031::ac43:cd09" = [ "kinox.top" ];
    "172.67.175.231" = [ "kinox.unblockit.ist" "newalbumreleases.unblockit.ist" ];
    "104.21.64.35" = [ "kinox.unblockit.ist" "newalbumreleases.unblockit.ist" ];
    "2606:4700:3031::ac43:afe7" = [ "kinox.unblockit.ist" "newalbumreleases.unblockit.ist" ];
    "2606:4700:3030::6815:4023" = [ "kinox.unblockit.ist" "newalbumreleases.unblockit.ist" ];
    "104.21.88.201" = [ "kinox.unblockit.ch" "newalbumreleases.unblockit.ch" ];
    "172.67.152.162" = [ "kinox.unblockit.ch" "newalbumreleases.unblockit.ch" ];
    "2606:4700:3035::6815:58c9" = [ "kinox.unblockit.ch" "newalbumreleases.unblockit.ch" ];
    "2606:4700:3030::ac43:98a2" = [ "kinox.unblockit.ch" "newalbumreleases.unblockit.ch" ];
    "104.21.81.85" = [ "kinox.unblockit.kim" ];
    "172.67.158.172" = [ "kinox.unblockit.kim" ];
    "2606:4700:3033::ac43:9eac" = [ "kinox.unblockit.kim" ];
    "2606:4700:3036::6815:5155" = [ "kinox.unblockit.kim" ];
    "172.67.208.6" = [ "kinox.unblockit.li" ];
    "104.21.69.123" = [ "kinox.unblockit.li" ];
    "2606:4700:3037::ac43:d006" = [ "kinox.unblockit.li" ];
    "2606:4700:3037::6815:457b" = [ "kinox.unblockit.li" ];
    "172.67.135.10" = [ "kinox.unblockit.onl" ];
    "104.21.6.167" = [ "kinox.unblockit.onl" ];
    "2606:4700:3036::6815:6a7" = [ "kinox.unblockit.onl" ];
    "2606:4700:3031::ac43:870a" = [ "kinox.unblockit.onl" ];
    "104.21.66.54" = [ "kinox.unblockit.tv" ];
    "172.67.201.78" = [ "kinox.unblockit.tv" ];
    "2606:4700:3036::6815:4236" = [ "kinox.unblockit.tv" ];
    "2606:4700:3037::ac43:c94e" = [ "kinox.unblockit.tv" ];
    "172.67.184.54" = [ "kinox.unblockit.uno" ];
    "104.21.36.27" = [ "kinox.unblockit.uno" ];
    "2606:4700:3031::6815:241b" = [ "kinox.unblockit.uno" ];
    "2606:4700:3033::ac43:b836" = [ "kinox.unblockit.uno" ];
    "190.115.31.19" = [ "cine.to" "cine.to" ];
    "104.26.13.95" = [ "newalbumreleases.unblockit.bet" ];
    "104.26.12.95" = [ "newalbumreleases.unblockit.bet" ];
    "172.67.71.113" = [ "newalbumreleases.unblockit.bet" ];
    "2606:4700:20::ac43:4771" = [ "newalbumreleases.unblockit.bet" ];
    "2606:4700:20::681a:c5f" = [ "newalbumreleases.unblockit.bet" ];
    "2606:4700:20::681a:d5f" = [ "newalbumreleases.unblockit.bet" ];
    "46.148.26.245" = [ "canna-power.to" "uu.canna.to" ];
    "46.148.26.194" = [ "canna.to" "canna.to" ];
  };

  extra = ''
    # http://netzsperre.liwest.at/
    ip.s.to 190.115.18.20
  '';
in {
  config = lib.mkIf config.networking.libreweb {
    networking.hosts = hosts;
    networking.extraHosts = extra;
  };

  options = {
    networking.libreweb = lib.mkEnableOption "Wether to circumvent internet blockades";
  };
}
