const peg = require('pegjs')
const fs = require('fs')
const through2 = require('through2')

const grammar = fs.readFileSync('./syntax.pegjs', { encoding: 'utf8' })
const parser = peg.generate(grammar)

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
                raw: decodedLine
              })
            )
          )
        } catch (error) {
          const timestamp = decodedLine.split(' ')[0]
          const output = {
            valid: false,
            raw: decodedLine,
            file,
            timestamp: Date.parse(timestamp),
            time: {
              t1: timestamp
            }
          }
          console.log(output)
          this.push(JSON.stringify(output))
        }
        callback()
      })
    )
}
