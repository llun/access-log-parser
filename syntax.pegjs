Line = Access / ReferralCorner / Localhost / Invalid

Access =
  timestamp:Timestamp _
  caller:IPList _
  NginxTimeStamp _
  host:Host _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer: Quote _
  userAgent: Quote _
{
  return {
  type: 'access',
  timestamp,
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
  timestamp:Timestamp _
  caller:IPList _
  NginxTimeStamp _
  "referral_corner" _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'referral_corner',
  timestamp,
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Localhost =
  timestamp:Timestamp _
  caller:IPList _
  NginxTimeStamp _
  "localhost" _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'localhost',
  timestamp,
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Invalid =
  timestamp:Timestamp _
  caller:IPList _
  NginxTimeStamp _
  InvalidHost _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer:Quote _
  userAgent:Quote _
{
  return {
  type: 'invalid',
  timestamp,
  caller,
  request,
  statusCode,
  size,
  referrer,
  userAgent
  }
}

Request = ForwardRequest / HTTPRequest / HexRequest
HexRequest = "\"" path:_HexRequestPath+ "\"" { return { type: 'hex', path: path.join('') } }
_HexRequestPath = EncodedHex / Text / [ ^`]

ForwardRequest = "\"" "X-Forwarded-For:" _ ip:IP "\"" { return { type: 'forwarded', ip }; }
HTTPRequest = "\"" method:Character _ pathname:Text _ version:HTTP_VERSION "\""
{
  return { type: 'http', method, pathname, version }
}
HTTP_VERSION = "HTTP/1.1"
  / "HTTP/1.0"
  / "HTTP/2.0"

Quote = "\"" quote:Text? "\"" { return quote; }

InvalidHost = "-c"
Host = HostName / IP
HostName = host:(_FQDNPart+ Word) { return host.join(''); }
_FQDNPart = part:(_FQDNFragment+) { return part.join(''); }
_FQDNFragment = fragment:(Word+ ".") { return fragment.join(''); }

IPList = ip:(RequestIP)+ balancer:LoadBalancerIP { return { ip, balancer }; }
RequestIP = ip:CallerIP ","? _ { return ip; }
LoadBalancerIP = "(" ip: IP ")" { return ip; }
CallerIP = Unknown / IP / HostName / NoValue
IP = IPv4 / IPv6
IPv4 = ip:(Number "." Number "." Number "." Number) { return ip.join(''); }

IPv6 = ip:(Hex ":" _IPv6Part Hex?) { return ip.join(''); }
_IPv6Part = part:_IPv6Fragment+ { return part.join(''); }
_IPv6Fragment = fragment:(Hex? ":") { return fragment.join(''); }

NginxTimeStamp = timestamp:("[" date:NginxDate ":" time:NginxTime " " NginxTimeZone "]") { return timestamp.join(""); }
NginxTimeZone = timezone:("+" Number) { return timezone.join(""); }
NginxTime = time:(Number ":" Number ":" Number) { return time.join("") }
NginxDate = date:(Number "/" Character "/" Number) { return date.join("") }

Timestamp = date:Date time:Time { return Date.parse(date.concat(time).join('')); }
Date = Number "-" Number "-" Number
Time = "T" Number ":" Number ":" Number "." Number "Z"

NoValue =  "-"
Unknown = "unknown"

EncodedHex = encodedHex:("\\x" Hex) { return encodedHex.join(''); }
Text = text:[;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=.\()\-,$~ {}<>]+ { return text.join(''); }
Word = word:[0-9a-zA-Z_-]+ { return word.join(''); }
Hex = hex:[0-9a-fA-F]+ { return hex.join(''); }
Character = character:[a-zA-Z]+ { return character.join(''); }
Number = digits:[0-9]+ { return digits.join(''); }
_ = [ \t\n]*

