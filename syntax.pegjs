Line = Access / ReferralCorner / Localhost / Invalid

Access =
  timestamp1:Timestamp _
  caller:IPList _
  timestamp2:NginxTimeStamp _
  host:Host _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer: Quote _
  userAgent: Quote _
{
  return {
  type: 'access',
  timestamp: Date.parse(timestamp1),
  time: {
    t1: timestamp1,
    t2: timestamp2
  },
  caller,
  host,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

ReferralCorner =
  timestamp1:Timestamp _
  caller:IPList _
  timestamp2:NginxTimeStamp _
  "referral_corner" _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'referral_corner',
  timestamp: Date.parse(timestamp1),
  time: {
    t1: timestamp1,
    t2: timestamp2
  },
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Localhost =
  timestamp1:Timestamp _
  caller:IPList _
  timestamp2:NginxTimeStamp _
  "localhost" _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'localhost',
  timestamp: Date.parse(timestamp1),
  time: {
    t1: timestamp1,
    t2: timestamp2
  },
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Invalid =
  timestamp1:Timestamp _
  caller:IPList _
  timestamp2:NginxTimeStamp _
  host:InvalidHost _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'invalid',
  host,
  timestamp: Date.parse(timestamp1),
  time: {
    t1: timestamp1,
    t2: timestamp2
  },
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Request = EmptyRequest / EmptyHTTPRequest / HTTPRequest / ForwardRequest / HexRequest / OtherRequest
OtherRequest = "\"" path:Text "\"" { return { type: 'invalid', path } }
HexRequest = "\"" path:TextWithoutSpace "\"" { return { type: 'hex', path } }
ForwardRequest = "\"" "X-Forwarded-For:" _ ip:IP "\"" { return { type: 'forwarded', ip }; }
HTTPRequest = "\"" method:Character _ pathname:TextWithoutSpace _ version:HTTP_VERSION "\""
{
  return { type: 'http', method, pathname, version }
}
HTTP_VERSION = "HTTP/1.1"
  / "HTTP/1.0"
  / "HTTP/2.0"
EmptyHTTPRequest = "\"" method:Character _ version:HTTP_VERSION "\""
{
  return { type: 'http', method, pathname: '', version }
}
EmptyRequest = "\"\""

Quote = "\"" quote:Text? "\"" { return quote; }

WaitDelayHost = "1 waitfor delay '0"
LookupHost = "'" lookup:[a-zA-Z0-9& |]+ "'" { return lookup.join('') }
TargetQueryHost = "target" "(" data:[a-zA-Z0-9_.\- @{}$]+ ")" { return `target(${data.join('')})` }
InvalidHost = WaitDelayHost / TargetQueryHost / LookupHost / invalid:([.0-9a-zA-Z\-()*]+) { return invalid.join(''); }
Host = HostName / IP
HostName = host:(_FQDNPart+ Word) { return host.join(''); }
_FQDNPart = part:(_FQDNFragment+) { return part.join(''); }
_FQDNFragment = fragment:(Word+ ".") { return fragment.join(''); }

IPList = ","? _ ip:(RequestIP)+ balancer:LoadBalancerIP { return { ip, balancer }; }
RequestIP = ip:CallerIP ","? _ { return ip; }
LoadBalancerIP = "(" ip: IP ")" { return ip; }
CallerIP = Unknown / IP / HostName / NoValue
IP = IPv64 / InvalidIPv4 / IPv4 / IPv6

IPv64 = ip:(_IPv6Part _IPv64End) { return ip.join(''); }
_IPv64End = IPv4 / Hex

InvalidIPv4 = invalid:(IPv4 ".") { return invalid.join('') }
IPv4 = ip:(Number "." Number "." Number "." Number) { return ip.join(''); }

IPv6 = ip:(_IPv6Part Hex?) { return ip.join(''); }
_IPv6Part = part:_IPv6Fragment+ { return part.join(''); }
_IPv6Fragment = fragment:(Hex? ":") { return fragment.join(''); }

NginxTimeStamp = "[" timestamp:(NginxDate ":" NginxTime " " NginxTimeZone) "]" { return timestamp.join(""); }
NginxTimeZone = timezone:("+" Number) { return timezone.join(""); }
NginxTime = time:(Number ":" Number ":" Number) { return time.join("") }
NginxDate = date:(Number "/" Character "/" Number) { return date.join("") }

Timestamp = date:Date time:Time { return date.concat(time).join(''); }
Date = Number "-" Number "-" Number
Time = "T" Number ":" Number ":" Number "." Number "Z"

NoValue =  "-"
Unknown = "unknown"

EncodedHex = encodedHex:("\\x" Hex) { return encodedHex.join(''); }
TextWithoutSpace = text:[`;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=.\()\-,$~{}<>]+ { return text.join(''); }
Text = text:[`;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=.\()\-,$~ {}<>]+ { return text.join(''); }
Word = word:[*0-9a-zA-Z_-]+ { return word.join(''); }
Hex = hex:[0-9a-fA-F]+ { return hex.join(''); }
Character = character:[a-zA-Z]+ { return character.join(''); }
Number = digits:[0-9]+ { return digits.join(''); }
_ = [ \t\n]*
