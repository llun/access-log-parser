line =
  ip:ip_list
  balancer:balancer _
  timestamp:timestamp _
  hostname:hostname
  request:request _
  status:$(digit+) _
  size:$(digit+) _
  referrer:quote _
  useragent:quote
{
  return {
    ip,
    balancer,
    timestamp,
    hostname,
    request,
    status,
    size,
    referrer,
    useragent
  }
}

ip_list = forwarder+
forwarder = ip:ip comma? _ { return ip }

balancer = parentheses ip:ip parentheses { return ip }

ip = ipv6 / ipv4
ipv4 = $(digit+ dot digit+ dot digit+ dot digit+)
ipv6 = $(((hex+)? ":")+ (hex+)?)

hostname = hostname:text { return hostname.trim() }
request = "\"" request:text "\"" { return request }

quote = "\"" quote:text "\"" { return quote }
text = $(symbol / digit / literal / _)+

comma = ","
dot = "."

parentheses = [()]

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
