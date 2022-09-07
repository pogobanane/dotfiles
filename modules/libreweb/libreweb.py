
# http://netzsperre.liwest.at/
at = [
  "kinox.to",
  "movie4k.to",
  "kinox.tv",
  "kinox.am",
  "kinox.nu",
  "kinox.pe",
  "kinox.me",
  "movie4k.tv",
  "movie4k.me",
  "movie.to",
  "movie2k.pe",
  "movie2k.cm",
  "szene-streams.com",
  "filme-streamz.com",
  "kkiste.to",
  "thepiratebay.gd",
  "thepiratebay.la",
  "thepiratebay.mn",
  "thepiratebay.mu",
  "thepiratebay.sh",
  "thepiratebay.tw",
  "thepiratebay.fm",
  "thepiratebay.ms",
  "thepiratebay.vg",
  "thepiratebay.se",
  "isohunt.to",
  "h33t.to",
  "1337x.to",
  "thepiratebay.org",
  "thepiratebay.red",
  "piratebayblocked.com",
  "pirateproxy.cam",
  "proxydl.cf",
  "1337x.st",
  "x1337x.ws",
  "kinox.sg",
  "movie4k.org",
  "movie4k.am",
  "movie4k.pe",
  "libgen.unblocked.win",
  "libgen.unblocked.lc",
  "libgen.unblocked.vet",
  "libgen.unblocked.la",
  "libgen.unblocked.li",
  "libgen.unblocked.red",
  "libgen.unblocked.tv",
  "libgen.unblocked.cat",
  "libgen.unblocked.uno",
  "libgen.unblocked.ink",
  "libgen.unblocked.at",
  "libgen.unblocked.pro",
  "libgen.unblocked.mx",
  "libgen.unblocked.sh",
  "libgen.unblocked.gdn",
  "libgen.unblocked.pet",
  "gen.lib.rus.ec",
  "sci-hub.tw",
  "sci-hub.se",
  "sci-hub.ren",
  "sci-hub.shop",
  "scihub.unblocked.lc",
  "scihub.unblocked.vet",
  "bs.to",
  "burning-series.net",
  "s.to",
  "serienstream.be",
  "streamkiste.tv",
  "serienjunkies.org",
  "kinos.to",
  "kinox.si",
  "kinox.io",
  "kinox.sx",
  "kinox.sh",
  "kinox.gratis",
  "kinox.mobi",
  "kinox.cloud",
  "kinox.lol",
  "kinox.wtf",
  "kinox.fun",
  "kinox.fyi",
  "movie4k.sg",
  "movie4k.lol",
  "movie2k.nu",
  "movie4k.sh",
  "www.rt.com",
  "de.rt.com",
  "francais.rt.com",
  "actualidad.rt.com",
  "sputniknews.com",
  "deutsch.rt.com",
  "fr.rt.com",
  "radiosputnik.ria.ru",
  "www.rtr-planeta.com",
  "www.vesti.ru",
  "www.tvc.ru",
  "burningseries.co",
  "burningseries.tw",
  "burningseries.sx",
  "burningseries.ac",
  "burningseries.vc",
  "burningseries.nz",
  "burningseries.se",
  "serienstream.to",
  "serien.cam",
  "ffmovies.biz",
  "fmovies.coffee",
  "fmovies.kim",
  "fmovies.media",
  "fmovies.ps",
  "fmovies.taxi",
  "fmovies.to",
  "fmovies.town",
  "fmovies.world",
  "fmovies.wtf",
  "fmovies.cx",
  "fmovies.cafe",
  "fmovies.pub",
  "fmovies.mom",
  "ww2.fmovies.cab",
  "fmoviesto.cc",
  "fmovies.hn",
  "fmovies.solar",
  "fmovies.ink",
  "fmoviesf.co",
  "seasonvar.ru",
  "kinokiste.me",
  "kinokiste.club",
  "kinokiste.ru",
  "kkiste.ru",
  "kkiste.club",
  "kkiste.ac",
  "movie2k.ag",
  "streamcloud.cam",
  "streamcloud-de.com",
  "primekiste.com",
  "filmpalast.to",
  "kinoz.to",
  "www13.kinoz.to",
  "movie4k.tv",
  "movie4k.me",
  "kinox.express",
  "kinox.click",
  "kinox.tube",
  "kinox.club",
  "kinox.digital",
  "kinox.direct",
  "kinox.pub",
  "kinox.space",
  "kinox.bz",
  "kinox.top",
  "kinox.am",
  "kinox.unblockit.ist",
  "kinox.unblockit.buzz",
  "kinox.unblockit.bz",
  "kinox.unblockit.cam",
  "kinox.unblockit.ch",
  "kinox.unblockit.club",
  "kinox.unblockit.kim",
  "kinox.unblockit.li",
  "kinox.unblockit.link",
  "kinox.unblockit.onl",
  "kinox.unblockit.tv",
  "kinox.unblockit.uno",
  "kinox.unblockit.ws",
  "kinox.unblockit.blue",
  "cine.to",
  "newalbumreleases.net",
  "newalbumreleases.unblockit.bet",
  "newalbumreleases.unblockit.ist",
  "newalbumreleases.unblockit.buzz",
  "newalbumreleases.unblockit.ch",
  "newalbumreleases.unblockit.club ",
  "newalbumreleases.unblockit.li ",
  "newalbumreleases.unblockit.link",
  "newalbumreleases.unblockit.onl ",
  "newalbumreleases.unblocked.co ",
  "newalbumreleases.unblockit.uno ",
  "canna-power.to",
  "canna.to",
  "uu.canna.to",
];
de = [
  # https://cuii.info/empfehlungen/
  "serienjunkies.org",
  "cine.to",
  "kinox.to",
  "streamkiste.tv",
  "bs.to",
  "newalbumreleases.net",
  "NSW2U.com",
  "canna.to",
  "s.to",
];

everything = []
everything += at
everything += de

import dns.resolver

resolver = dns.resolver.Resolver()
resolver.nameservers = [ "1.1.1.1" ]

hosts = dict()

def addHost(ip: str, hostname: str):
    try:
        hosts[ip]
    except KeyError:
        hosts[ip] = []

    hosts[ip] += [hostname]

for a in everything:
    try:
        result = resolver.resolve(a, 'A')
        for ipval in result:
            addHost(ipval.to_text(), a)
            # hosts[str(ipval.to_text())] = []
            print(f"\"{ipval.to_text()}\" = [ \"{a}\" ];")
    except dns.resolver.NoAnswer:
        pass
    except dns.resolver.NXDOMAIN:
        print(f"Doesnt exist: {a}")

    try:
        result = resolver.resolve(a, 'AAAA')
        for ipval in result:
            addHost(ipval.to_text(), a)
            print(f"\"{ipval.to_text()}\" = [ \"{a}\" ];")
    except dns.resolver.NoAnswer:
        pass
    except dns.resolver.NXDOMAIN:
        print(f"Doesnt exist: {a}")

print("")
print("========= Deduplicated: ============");

for key in hosts.keys():
    array = "[ "
    for host in hosts[key]:
        array += "\""
        array += host
        array += "\" "
    array += "]"
    print(f"\"{key}\" = {array};")
