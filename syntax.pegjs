line =
  ip:ip_list
  balancer:balancer _
  timestamp:timestamp _
  hostname:hostname
  request:request _
  status:$(digit+) _
  size:$(digit+) _
  referrer:quote _
  useragent:quote _?
{
  return {
    ip,
    balancer,
    timestamp,
    hostname: hostname.trim(),
    request,
    status,
    size,
    referrer,
    useragent
  }
}

ip_list = forwarder+ / (novalue:novalue _ { return [novalue] })
forwarder = ip:ip comma? _ { return ip }

balancer = "(" ip:ip ")" { return ip }

ip = ipv6 / ipv4
ipv4 = $(digit+ dot digit+ dot digit+ dot digit+)
ipv6 = $(((hex+)? ":")+ (hex+)?)

hostname = $(text / _)+
request = http_request / other_request
other_request = "\"" request:$((text / _)+) "\""
{
  return {
    type: 'other',
    request
  }
}
http_request = "\"" method:$(literal+) _ path:$(text+) _ version:$(text+) "\""
{
  return {
    type: 'http',
    method,
    path,
    version
  }
}

quote = "\"" quote:$((text / _)+) "\"" { return quote }
text = $(symbol / digit / literal )

novalue = "-"
comma = ","
dot = "."

symbol = [\x21\x23-x2F\x3A-\x40\x5B-\x60\x7B-\x7E]
literal = [a-zA-Z]
_ = [ \n\t]
digit = [0-9]
hex = digit / [a-fA-F]

timestamp = "[" time:datetime "]" { return time }
datetime =
  day:$(digit+) "/"
  month:month "/"
  year:$(digit+) ":"
  hour:$(digit+) ":"
  minute:$(digit+) ":"
  second:$(digit+) _ "+"
  timezone:$(digit+)
{
  const time = new Date(
    parseInt(year, 10),
    month,
    parseInt(day, 10),
    parseInt(hour, 10),
    parseInt(minute, 10),
    parseInt(second, 10))
  return time.toISOString()
}
month = january
  / february
  / march
  / april
  / may
  / june
  / july
  / august
  / september
  / october
  / november
  / december
january = 'Jan' { return 0 }
february = 'Feb' { return 1 }
march = 'Mar' { return 2 }
april = 'Apr' { return 3 }
may = 'May' { return 4 }
june = 'Jun' { return 5 }
july = 'Jul' { return 6 }
august = 'Aug' { return 7 }
september = 'Sep' { return 8 }
october = 'Oct' { return 9 }
november = 'Nov' { return 10 }
december = 'Dec' { return 11 }

