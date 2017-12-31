const peg = require('pegjs')
const fs = require('fs')
const through2 = require('through2')

const grammar = fs.readFileSync('./syntax.pegjs', { encoding: 'utf8' })
const parser = peg.generate(grammar)

const months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
]

module.exports = function parse(file) {
  return fs
    .createReadStream(file, { autoClose: true })
    .pipe(
      // Convert chunk into line
      through2(function(chunk, enc, callback) {
        const lines = chunk.toString().split('\n')
        const lastLine = lines[lines.length - 1]
        if (this._previous) {
          lines[0] = [this._previous, lines[0]].join('')
          this._previous = ''
        }
        if (lastLine) this._previous = lines.pop()
        lines.forEach((line, index) => {
          this.push(line)
        })
        callback()
      })
    )
    .pipe(
      through2(function(line, enc, callback) {
        const decodedLine = line.toString()
        try {
          this.push(
            JSON.stringify(
              Object.assign({}, parser.parse(decodedLine), {
                valid: true,
                raw: decodedLine,
                file
              })
            )
          )
        } catch (error) {
          const matches = decodedLine.match(
            /(\[(\d{0,2})\/(\w+)\/(\d{4}):(\d+):(\d+):(\d+) \+(\d{4})\])/
          )
          const [, , day, month, year, hour, minute, second] = matches
          const time = new Date(
            parseInt(year, 10),
            months.findIndex(i => i === month),
            parseInt(day, 10),
            parseInt(hour, 10),
            parseInt(minute, 10),
            parseInt(second, 10)
          )
          const output = {
            timestamp: time.toISOString(),
            valid: false,
            raw: decodedLine,
            file
          }
          console.log(output)
          this.push(JSON.stringify(output))
        }
        callback()
      })
    )
}
