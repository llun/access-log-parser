AccessLog =
  timestamp1:Timestamp _
  caller:IPList _
  timestamp2:NginxTimeStamp _
  host:Text _
  request:Request _
  statusCode:Number _
  size:Number _
  referrer: Quote _
  userAgent: Quote _
{
  host = host.trim()

  let type = 'access'
  if (host.value === 'referral_corner') type = 'referral_corner'
  else if (host.value === 'localhost') type = 'localhost'
  else if (host.type === 'text') type = 'invalid'

  return {
  type,
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

HostName = $(_FQDNPart+ Word)
_FQDNPart = $(_FQDNFragment+)
_FQDNFragment = $(Word+ ".")

IPList = ","? _ ip:(RequestIP)+ balancer:LoadBalancerIP { return { ip, balancer }; }
RequestIP = ip:CallerIP ","? _ { return ip; }
LoadBalancerIP = "(" ip: IP ")" { return ip; }
CallerIP = IP / HostName / Unknown / NoValue
IP = IPv64 / InvalidIPv4 / IPv4 / IPv6

IPv64 = $(_IPv6Part _IPv64End)
_IPv64End = IPv4 / Hex

InvalidIPv4 = $(IPv4 ".")
IPv4 = $(Number "." Number "." Number "." Number)

IPv6 = $(_IPv6Part Hex?)
_IPv6Part = $_IPv6Fragment+
_IPv6Fragment = $(Hex? ":")

NginxTimeStamp = "[" timestamp:$(NginxDate ":" NginxTime " " NginxTimeZone) "]" { return timestamp }
NginxTimeZone = $("+" Number)
NginxTime = $(Number ":" Number ":" Number)
NginxDate = $(Number "/" Character "/" Number)

Timestamp = $(date:Date time:Time)
Date = Number "-" Number "-" Number
Time = "T" Number ":" Number ":" Number "." Number "Z"

NoValue =  "-"
Unknown = "unknown"

EncodedHex = $("\\x" Hex)
TextWithoutDot = $[`;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=\()\-$~ {}<>]+
TextWithoutSpace = $[`;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=.\()\-,$~{}<>]+
Text = $[`;a-zA-Z0-9*%#:/\\^@?!+[\]|&_'=.\()\-,$~ {}<>]+
Word = $[*0-9a-zA-Z_-]+
Hex = $[0-9a-fA-F]+
Character = $[a-zA-Z]+
Number = $[0-9]+
_ = [ \t\n]*

